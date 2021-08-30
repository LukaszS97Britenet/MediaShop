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
                        productFromCart.quantity += 1;
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
            System.debug(e.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static Cart getCart() {
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