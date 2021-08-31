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
        System.debug(payload);
        Cart shoppingCart = getCart();
        System.debug(shoppingCart);
    }

    @AuraEnabled
    public static void createOrder() {
        Order newOrder = new Order();
        newOrder.Status = 'Draft';
        newOrder.OwnerId = UserInfo.getUserId();
        newOrder.BillToContactId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].Id;
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
        public String street;
        public String city;
        public String state;
        public String postalCode;
        public String country;
        public String paymentMethod;
        public String deliveryMethod;
    }
}