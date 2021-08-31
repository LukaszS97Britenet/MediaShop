public with sharing class MS_ProductImages {

    @AuraEnabled
    public static List<String> getAllFilesOnsObjectRecord(Id sObjectId){
        List<ContentDocument> contentDocumentListToReturn = new List<ContentDocument>();
        List<ContentDocumentLink> contentDocLinkOnsObjectList = new List<ContentDocumentLink>();

        contentDocLinkOnsObjectList = [Select id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId =: sObjectId];
        Set<Id> contentDocIdSet = new Set<Id>();

        if(contentDocLinkOnsObjectList != null && !contentDocLinkOnsObjectList.isEmpty()){
            for(ContentDocumentLink conDocLink : contentDocLinkOnsObjectList){
                contentDocIdSet.add(conDocLink.ContentDocumentId);
            }
        }

        if(contentDocIdSet != null && !contentDocIdSet.isEmpty()){
            contentDocumentListToReturn = [Select id From ContentDocument Where ID IN :contentDocIdSet];
        }

        if(contentDocumentListToReturn != null && !contentDocumentListToReturn.isEmpty()){
            List<String> imageId = new List<String>();
            for (ContentDocument doc : contentDocumentListToReturn) {
                imageId.add(doc.Id);
            }
            return imageId;
        } else{
            return null;
        }
    }

    @AuraEnabled
    public static String getMainImageId(Id sObjectId) {
        try {
            Product2 product = [SELECT 	MainImageId__c FROM Product2 WHERE Id=: sObjectId];
            return product.MainImageId__c;
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}