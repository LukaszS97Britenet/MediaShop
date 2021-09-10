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
        // ===============================

        List<OrderItem> orderItems = [SELECT Product2Id, Quantity FROM OrderItem WHERE OrderId = :payload.orderId];

        List<Id> ids = new List<Id>();
        for (OrderItem o : orderItems) {
            ids.add(o.Product2Id);
        }

        List<Warehouse_Line_Item__c> warehouseLineItems = [SELECT Id,Warehouse__r.Id, Warehouse__r.Occupied_Capacity__c, Products_Amount__c, Product__r.Capacity__c, Product__c FROM Warehouse_Line_Item__c WHERE Product__c IN :ids];

        Map<Id, List<Warehouse_Line_Item__c>> mapOfSameItems = new Map<Id, List<Warehouse_Line_Item__c>>();
        for (Warehouse_Line_Item__c w : warehouseLineItems) {
            if(mapOfSameItems.get(w.Product__c) != null) {
                mapOfSameItems.get(w.Product__c).add(w);
            } else {
                List<Warehouse_Line_Item__c> listOfItems = new List<Warehouse_Line_Item__c>();
                listOfItems.add(w);
                mapOfSameItems.put(w.Product__c, listOfItems);
                listOfItems = new List<Warehouse_Line_Item__c>();
            }
        }

        List<Warehouse_Line_Item__c> listToUpdate = new List<Warehouse_Line_Item__c>();
        for(OrderItem o : orderItems) {
            System.debug(o);
            Decimal quantity = o.Quantity;
            for(Warehouse_Line_Item__c w : mapOfSameItems.get(o.Product2Id)) {
                System.debug(w);
                if(quantity >= 0) {
                    Decimal amount = w.Products_Amount__c;
                    System.debug(amount);
                    w.Products_Amount__c -= quantity;
                    w.Product_Amount_Difference__c = quantity;
                    quantity -= amount;
                    if(w.Products_Amount__c < 0) {
                        w.Products_Amount__c = 0;
                        w.Product_Amount_Difference__c = amount;
                    }
                }
                System.debug(w);
                listToUpdate.add(w);
            }
        }

        List<Id> idsOfWarehouses = new List<Id>();
        for (Warehouse_Line_Item__c w : listToUpdate) {
            if (idsOfWarehouses.contains(w.Warehouse__r.Id)) {
            } else {
                idsOfWarehouses.add(w.Warehouse__r.Id);
            }
        }

        System.debug(idsOfWarehouses);

        List<Warehouse__c> warehouses = [SELECT Id, Occupied_Capacity__c FROM Warehouse__c WHERE Id IN :idsOfWarehouses];
        Map<Id, Warehouse__c> mapOfWarehouses = new Map<Id, Warehouse__c>();
        for (Warehouse__c w : warehouses) {
            mapOfWarehouses.put(w.Id, w);
        }

        System.debug(listToUpdate);

        for (Warehouse_Line_Item__c w : listToUpdate) {
            mapOfWarehouses.get(w.Warehouse__r.Id).Occupied_Capacity__c -= w.Product_Amount_Difference__c*w.Product__r.Capacity__c;
            w.Product_Amount_Difference__c = 0;
        }
        System.debug(mapOfWarehouses);
        warehouses = new List<Warehouse__c>();
        for (Id i : idsOfWarehouses) {
            warehouses.add(mapOfWarehouses.get(i));
        }
        update warehouses;
        update listToUpdate;
        // ===================================================
        update orderToUpdate;
    }

    @AuraEnabled
    public static Id createOrder() {
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
        newOrder.Contact__c = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        newOrder.Pricebook2Id = shoppingCart.products.get(0).product.Pricebook2Id;
        insert newOrder;
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
        return newOrder.Id;
    }

    @AuraEnabled
    public static OrderWrapper getContactDetails() {
        OrderWrapper orderWrapper = new OrderWrapper();
        String idContact = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        Contact contact = [SELECT OtherPostalCode, OtherStreet, OtherCountry, OtherCity, OtherState FROM Contact WHERE id = :idContact LIMIT 1];
        orderWrapper.city = contact.OtherCity;
        orderWrapper.state = contact.OtherState;
        orderWrapper.street = contact.OtherStreet;
        orderWrapper.postalCode = contact.OtherPostalCode;
        orderWrapper.country = contact.OtherCountry;
        return orderWrapper;
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
        @AuraEnabled public String orderId;
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String country;
        @AuraEnabled public String paymentMethod;
        @AuraEnabled public String deliveryMethod;
    }
}