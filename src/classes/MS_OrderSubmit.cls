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