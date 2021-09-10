public with sharing class MS_RecentlyViewed {

    @AuraEnabled
    public static List<PricebookEntry> getRecentlyViewed() {
        MS_ShoppingCart.Cart productFromCart = new MS_ShoppingCart.Cart();
        try {
            productFromCart = MS_ShoppingCart.getCart();
            System.debug(productFromCart);
        } catch (Exception e) {

        }
        Boolean isClubUser = false;
        List<RecentlyViewed> recViewed = [SELECT Id, Name FROM RecentlyViewed WHERE Type IN ('Product2') ORDER BY LastViewedDate DESC LIMIT 9];
        List<AggregateResult> listResults = [SELECT Product__c, SUM(Products_Amount__c) amount FROM Warehouse_Line_Item__c GROUP BY Product__c];
        Map<Id, Decimal> mapOfCountFromWarehouse = new Map<Id, Decimal>();
        for (AggregateResult result : listResults) {
            mapOfCountFromWarehouse.put((Id) result.get('Product__c'), (Decimal) result.get('amount'));
        }
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
            if(mapOfCountFromWarehouse.get(pricebook.Product2Id) > 0) {
                pricebook.Product2.Amount_From_Warehouses__c = mapOfCountFromWarehouse.get(pricebook.Product2Id);
            } else {
                pricebook.Product2.Amount_From_Warehouses__c = 0;
            }
        }
        if(productFromCart.products.size() > 0) {
            Map<Id, Decimal> mapOfProductsFromCart = new Map<Id, Decimal>();
            for (MS_ShoppingCart.Product product : productFromCart.products) {
                mapOfProductsFromCart.put(product.product.Product2Id, product.quantity);
            }
            for (PricebookEntry pricebook : products) {
                if (mapOfProductsFromCart.get(pricebook.Product2Id) > 0) {
                    System.debug(mapOfProductsFromCart.get(pricebook.Product2Id));
                    pricebook.Product2.Amount_From_Warehouses__c -= mapOfProductsFromCart.get(pricebook.Product2Id);
                }
            }
        }
        for(Id productId : productsIds) {
            sortedProducts.add(mapOfProducts.get(productId));
        }
        return sortedProducts;
    }
}