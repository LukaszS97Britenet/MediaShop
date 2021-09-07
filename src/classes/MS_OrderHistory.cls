public without sharing class MS_OrderHistory {

    @AuraEnabled
    public static OrderWrapper getUserOrders() {
        OrderWrapper wrapper = new OrderWrapper();
        Id contactId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        System.debug(contactId);
        wrapper.results = [SELECT Id, Status, EffectiveDate, TotalAmount, Payment_Method__c, DeliveryMethod__c, OrderNumber FROM Order WHERE Contact__c =: contactId AND Status = 'Paid' ORDER BY CreatedDate Desc];
        System.debug(wrapper.results.size());
        return wrapper;
    }

    public class OrderWrapper {
        @AuraEnabled public List<Order> results;
    }
}