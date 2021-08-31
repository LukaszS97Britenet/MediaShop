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
    public static Id createOrder() {
        System.debug('createORder');
        Order newOrder = new Order();
        newOrder.Status = 'Draft';
        newOrder.OwnerId = UserInfo.getUserId();
        newOrder.AccountId = [SELECT Id FROM Account WHERE Name='Personal'].Id;
        newOrder.EffectiveDate = Date.today();
        newOrder.BillToContactId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        System.debug(newOrder);
        insert newOrder;
        List<OrderItem> items = new List<OrderItem>();
        OrderItem item;
        Cart shoppingCart = getCart();
        for(Product prod : shoppingCart.products) {
            item = new OrderItem();
            item.OrderId = newOrder.Id;
            item.Product2Id = prod.product.Product2Id;
            item.Quantity = prod.quantity;
            item.UnitPrice = prod.product.UnitPrice;
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
        public String street;
        public String city;
        public String state;
        public String postalCode;
        public String country;
        public String paymentMethod;
        public String deliveryMethod;
    }
}