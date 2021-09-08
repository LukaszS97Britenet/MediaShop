public with sharing class MS_RecentlyViewed {

    @AuraEnabled
    public static List<PricebookEntry> getRecentlyViewed() {
        Boolean isClubUser = false;
        List<RecentlyViewed> recViewed = [SELECT Id, Name FROM RecentlyViewed WHERE Type IN ('Product2') ORDER BY LastViewedDate DESC LIMIT 9];
        List<Id> productsIds = new List<Id>();
        for (RecentlyViewed rec : recViewed) {
            productsIds.add(rec.Id);
        }
        List<PricebookEntry> products;
        try {
            Id contactId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].ContactId;
            isClubUser = [SELECT Id, FirstName, LastName, Interested__c, KnowAboutUs__c, IsSendEmailAllowed__c, Is_In_Club__c FROM Contact WHERE Id =: contactId].Is_In_Club__c;
        } catch (Exception e) {

        }
        if(isClubUser) {
            products = [SELECT Id ,Name,UnitPrice,Product2Id,Pricebook2Id, Product2.MainImageId__c, PercentDiscount__c FROM PricebookEntry WHERE Product2Id =: productsIds AND Pricebook2.Name = 'Club'];
        } else {
            products = [SELECT Id ,Name,UnitPrice,Product2Id,Pricebook2Id, Product2.MainImageId__c FROM PricebookEntry WHERE Product2Id =: productsIds AND Pricebook2.isStandard = true];
        }
        List<PricebookEntry> sortedProducts = new List<PricebookEntry>();
        Map<Id, PricebookEntry> mapOfProducts = new Map<Id, PricebookEntry>();
        for (PricebookEntry pricebook : products) {
            mapOfProducts.put(pricebook.Product2Id, pricebook);
        }
        for(Id productId : productsIds) {
            sortedProducts.add(mapOfProducts.get(productId));
        }
        return sortedProducts;
    }
}