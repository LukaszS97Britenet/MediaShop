trigger MS_ProductRating on Product_Rating__c (before insert) {
    List<String> listUserIds = new List<Id>();
    List<String> listProductIds = new List<Id>();
    for(Product_Rating__c productRating: Trigger.new) {
        listUserIds.add(productRating.UserId__c);
        listProductIds.add(productRating.ProductId__c);
    }
    List<Product_Rating__c> listofComments = [SELECT Id, Is_Latest__c FROM Product_Rating__c WHERE Is_Latest__c = true AND UserId__c =: listUserIds AND ProductId__c =:listProductIds];
    for(Product_Rating__c product : listofComments) {
        product.Is_Latest__c = false;
    }
    update listofComments;
}