public with sharing class MS_RecentlyViewed {

    @AuraEnabled
    public static List<PricebookEntry> getRecentlyViewed() {
        List<RecentlyViewed> recViewed = [SELECT Id, Name FROM RecentlyViewed WHERE Type IN ('Product2') ORDER BY LastViewedDate DESC LIMIT 9];
        List<Id> productsIds = new List<Id>();
        for (RecentlyViewed rec : recViewed) {
            productsIds.add(rec.Id);
        }
        List<PricebookEntry> products = [SELECT Id ,Name,UnitPrice,Product2Id,Pricebook2Id, Product2.MainImageId__c FROM PricebookEntry WHERE Product2Id =: productsIds AND Pricebook2.isStandard = true];
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