public with sharing class MS_OrderSubmit {

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
    public static void submitOrder(String payloadJson) {
        OrderWrapper payload = (OrderWrapper) JSON.deserialize(payloadJson, OrderWrapper.class);
        Contact con = new Contact();
        con.Id = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        con.OtherPostalCode = payload.postalCode;
        con.OtherStreet = payload.street;
        con.OtherCountry = payload.country;
        con.OtherCity = payload.city;
        con.OtherState = payload.state;
        update con;
        Order orderToUpdate = new Order();
        orderToUpdate.Id = payload.orderId;
        orderToUpdate.DeliveryMethod__c = payload.deliveryMethod;
        orderToUpdate.Payment_Method__c = payload.paymentMethod;
        orderToUpdate.Status = 'Paid';
        update orderToUpdate;
    }

    @AuraEnabled
    public static Id createOrder() {
        System.debug('createORder');
        Cart shoppingCart = getCart();
        String partitionInput = 'local.ShoppingCart';
        String counterKeyInput = 'Cart';
        Cache.SessionPartition sessionPartition = Cache.Session.getPartition(partitionInput);
        sessionPartition.put(counterKeyInput, JSON.serialize(new Cart()));
        Order newOrder = new Order();
        newOrder.Status = 'Draft';
        newOrder.OwnerId = UserInfo.getUserId();
        newOrder.AccountId = [SELECT Id FROM Account WHERE Name='Personal'].Id;
        newOrder.EffectiveDate = Date.today();
        newOrder.BillToContactId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        newOrder.Pricebook2Id = shoppingCart.products.get(0).product.Pricebook2Id;
        System.debug(newOrder);
        insert newOrder;
        System.debug(newOrder);
        List<OrderItem> items = new List<OrderItem>();
        OrderItem item;
        for(Product prod : shoppingCart.products) {
            item = new OrderItem();
            item.OrderId = newOrder.Id;
            item.Product2Id = prod.product.Product2Id;
            item.Quantity = prod.quantity;
            item.UnitPrice = prod.product.UnitPrice;
            item.PricebookEntryId = prod.product.Id;
            items.add(item);
        }
        insert items;
        System.debug(items);
        return newOrder.Id;
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

    public class OrderWrapper {
        public String orderId;
        public String street;
        public String city;
        public String state;
        public String postalCode;
        public String country;
        public String paymentMethod;
        public String deliveryMethod;
    }
}