public with sharing class MS_ShoppingCart {

    @AuraEnabled
    public static Boolean addToCart(PricebookEntry product, String quantity) {
        try {
            Product productWrapper = new Product();
            productWrapper.product = product;
            productWrapper.quantity = Decimal.valueOf(quantity);
            String partitionInput = 'local.ShoppingCart';
            String counterKeyInput = 'Cart';
            Cache.SessionPartition sessionPartition = Cache.Session.getPartition(partitionInput);
            if (sessionPartition.contains(counterKeyInput)) {
                String message = (String) sessionPartition.get(counterKeyInput);
                Cart cartFromSession = (Cart) JSON.deserialize(message, Cart.class);
                for(Product productFromCart : cartFromSession.products) {
                    if(productFromCart.product.Product2Id == productWrapper.product.Product2Id) {
                        productFromCart.quantity += Decimal.valueOf(quantity);
                        sessionPartition.put(counterKeyInput, JSON.serialize(cartFromSession));
                        return true;
                    }
                }
                cartFromSession.products.add(productWrapper);
                sessionPartition.put(counterKeyInput, JSON.serialize(cartFromSession));
            } else {
                Cart newCart = new Cart();
                newCart.products.add(productWrapper);
                sessionPartition.put(counterKeyInput, JSON.serialize(newCart));
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Cart getCart() {
            try {
            Order orderItem = [SELECT Id, OwnerId FROM Order WHERE OwnerId =: UserInfo.getUserId() AND Status = 'Draft' ORDER BY CreatedDate DESC LIMIT 1];
            List<OrderItem> items = [SELECT Id, UnitPrice, Quantity, Product2Id, PricebookEntry.Pricebook2Id, Product2.Name, Product2.MainImageId__c FROM OrderItem WHERE OrderId =: orderItem.Id];
            PricebookEntry priceEnt;
            for(OrderItem ord : items) {
                priceEnt = new PricebookEntry();
                Product2 prod = new Product2();
                prod.Name = ord.Product2.Name;
                prod.MainImageId__c = ord.Product2.MainImageId__c;
                prod.Id = ord.Product2Id;
                priceEnt.Product2Id = ord.Product2Id;
                priceEnt.UnitPrice = ord.UnitPrice;
                priceEnt.Pricebook2Id = ord.PricebookEntry.Pricebook2Id;
                priceEnt.Id = ord.PricebookEntryId;
                priceEnt.Product2 = prod;
                addToCart(priceEnt, String.valueOf(ord.Quantity));
            }
            delete items;
            delete orderItem;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        String partitionInput = 'local.ShoppingCart';
        String counterKeyInput = 'Cart';
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition(partitionInput);
        String message = (String) sessionPartition.get(counterKeyInput);
        Cart cartFromSession = (Cart) JSON.deserialize(message, Cart.class);
        return cartFromSession;
    }

    @AuraEnabled
    public static Decimal getAmountOfProducts() {
        String partitionInput = 'local.ShoppingCart';
        String counterKeyInput = 'Cart';
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition(partitionInput);
        String message = (String) sessionPartition.get(counterKeyInput);
        Cart cartFromSession = (Cart) JSON.deserialize(message, Cart.class);
        Decimal amount = 0;
        for (Product product: cartFromSession.products) {
            amount += product.quantity;
        }
        return amount;
    }

    @AuraEnabled
    public static Cart deleteProductFromCart(String id) {
        String partitionInput = 'local.ShoppingCart';
        String counterKeyInput = 'Cart';
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition(partitionInput);
        String message = (String) sessionPartition.get(counterKeyInput);
        Cart cartFromSession = (Cart) JSON.deserialize(message, Cart.class);
        Integer i = 0;
        while (i < cartFromSession.products.size()){
            if(cartFromSession.products.get(i).product.Product2Id == id){
                cartFromSession.products.remove(i);
                sessionPartition.put(counterKeyInput, JSON.serialize(cartFromSession));
            } else {
                i++;
            }
        }
        return cartFromSession;
    }

    @AuraEnabled
    public static Cart changeQuantityValue(String id, String quantity) {
        String partitionInput = 'local.ShoppingCart';
        String counterKeyInput = 'Cart';
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition(partitionInput);
        String message = (String) sessionPartition.get(counterKeyInput);
        Cart cartFromSession = (Cart) JSON.deserialize(message, Cart.class);
        Integer i = 0;
        while (i < cartFromSession.products.size()){
            if(cartFromSession.products.get(i).product.Product2Id == id){
                cartFromSession.products.get(i).quantity += Decimal.valueOf(quantity);
                if(cartFromSession.products.get(i).quantity == 0) {
                    cartFromSession.products.remove(i);
                }
                sessionPartition.put(counterKeyInput, JSON.serialize(cartFromSession));
                return cartFromSession;
            } else {
                i++;
            }
        }
        return cartFromSession;
    }

    public class Product {
        @AuraEnabled public PricebookEntry product;
        @AuraEnabled public Decimal quantity;
    }

    public class Cart {
        @AuraEnabled public List<Product> products;

        public Cart() {
            products = new List<Product>();
        }
    }
}