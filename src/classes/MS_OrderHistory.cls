public with sharing class MS_OrderHistory {

    @AuraEnabled
    public static OrderWrapper getUserOrders() {
        OrderWrapper wrapper = new OrderWrapper();
        wrapper.results = [SELECT Id, Status, EffectiveDate, TotalAmount, Payment_Method__c, DeliveryMethod__c, OrderNumber FROM Order WHERE OwnerId =: UserInfo.getUserId() AND Status = 'Paid' ORDER BY CreatedDate Desc];
        return wrapper;
    }

    public class OrderWrapper {
        @AuraEnabled public List<Order> results;
    }
}