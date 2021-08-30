public with sharing class MS_Product2Service {

    @AuraEnabled
    public static void deleteFiles(String filesIdArrStr) {
        List<ContentDocument> contentDocumentToDelete = new List<ContentDocument>();
        Set<Id> filesIdSet = new Set<Id>();
        if (filesIdArrStr != null && filesIdArrStr != '') {
            filesIdSet = (Set<Id>) JSON.deserialize(filesIdArrStr, Set<Id>.class);
        }
        if (filesIdSet != null && !filesIdSet.isEmpty()) {
            contentDocumentToDelete = [Select id From ContentDocument Where Id IN :filesIdSet];
            if (contentDocumentToDelete != null && !contentDocumentToDelete.isEmpty()) {
                try {
                    delete contentDocumentToDelete;
                } catch (Exception ex) {
                    System.debug('Exception--' + ex.getMessage());
                }
            }
        }
    }

    @AuraEnabled
    public static List<ContentDocument> getAllFilesOnsObjectRecord(Id sObjectId) {
        List<ContentDocument> contentDocumentListToReturn = new List<ContentDocument>();
        List<ContentDocumentLink> contentDocLinkOnsObjectList = new List<ContentDocumentLink>();
        contentDocLinkOnsObjectList = [Select id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId = :sObjectId];
        Set<Id> contentDocIdSet = new Set<Id>();
        if (contentDocLinkOnsObjectList != null && !contentDocLinkOnsObjectList.isEmpty()) {
            for (ContentDocumentLink conDocLink : contentDocLinkOnsObjectList) {
                contentDocIdSet.add(conDocLink.ContentDocumentId);
            }
        }
        if (contentDocIdSet != null && !contentDocIdSet.isEmpty()) {
            contentDocumentListToReturn = [Select id, Title From ContentDocument Where ID IN :contentDocIdSet];
        }
        if (contentDocumentListToReturn != null && !contentDocumentListToReturn.isEmpty()) {
            return contentDocumentListToReturn;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static Id addProduct(String payloadJson) {
        ProductWrapper payload = (ProductWrapper) JSON.deserialize(payloadJson, ProductWrapper.class);
        System.debug(payload);
        Product2 product = new Product2();
        try {
            Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
            if (String.isNotBlank(payload.id)) {
                System.debug(payload.id);
                PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :payload.id AND Pricebook2.Name = 'Standard Price Book'];
                pricebookEntry.UnitPrice = Decimal.valueOf(payload.cost);
                update pricebookEntry;
                product.Id = payload.id;
                product = convertWrapperToProduct(product, payload);
                update product;
                return product.Id;
            } else {
                product = convertWrapperToProduct(product, payload);
                insert product;
                PricebookEntry pricebookEntry = new PricebookEntry();
                pricebookEntry.Pricebook2Id = standardPricebook.Id;
                pricebookEntry.UnitPrice = Decimal.valueOf(payload.cost);
                pricebookEntry.Product2Id = product.Id;
                insert pricebookEntry;
                return product.Id;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());

            return null;
        }
    }

    @AuraEnabled
    public static PricebookEntryDetails getProduct(Id id) {
        try {
            PricebookEntryDetails wrapper = new PricebookEntryDetails();
            wrapper.result = [
                    SELECT Id,Name,UnitPrice,Product2.Id,Product2.Name,Product2.Description,Product2.Current_Inventory__c, Product2.ProductCode, Product2.Brand__c,Product2.Category__c, Product2.Color__c, Product2.Installment__c, Product2.MainImageId__c, Product2.Model__c, Product2.IsActive
                    FROM PricebookEntry
                    WHERE Product2Id = :id AND Pricebook2.Name = 'Standard Price Book'
                    LIMIT 1
            ];
            System.debug(wrapper);
            return wrapper;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static PricebookEntryResults getProducts(String payloadJson) {
        System.debug('jestem');
        SearchWrapper payload = (SearchWrapper) JSON.deserialize(payloadJson, SearchWrapper.class);
        PricebookEntryResults searchWrapperResults = new PricebookEntryResults();
        try {
            searchWrapperResults.results = Database.query(queryGenerator(payload));
            return searchWrapperResults;
        } catch (Exception e) {
            System.debug(e.getMessage());
            if (e.getMessage().contains('<EOF>')) {
                System.debug('whodze');
                searchWrapperResults.results = [SELECT Id,Name,UnitPrice,Product2Id,Pricebook2Id, Product2.MainImageId__c FROM PricebookEntry WHERE Pricebook2.isStandard = true];
                return searchWrapperResults;
            }
            return null;
        }
    }

    @AuraEnabled
    public static Boolean addMainImageToProduct(String payloadJson) {
        MainImage payload = (MainImage) JSON.deserialize(payloadJson, MainImage.class);
        try {
            Product2 product = new Product2();
            product.Id = payload.objectId;
            product.MainImageId__c = payload.imageId;
            System.debug(product);
            update product;
        } catch (Exception e) {
            return false;
        }
        return true;
    }

    public static String queryGenerator(SearchWrapper params) {
        String searchQuery = '';
        searchQuery = 'SELECT Id,Name,UnitPrice,Product2Id,Pricebook2Id, Product2.MainImageId__c FROM PricebookEntry WHERE ';
        searchQuery += String.join(generateListOfPartQueries(params), ' AND ');
        return searchQuery;
    }

    public static List<String> generateListOfPartQueries(SearchWrapper params) {
        String partOfQuery;
        List<String> listOfPartsOfQueries = new List<String>();
        if (!String.isBlank(params.productName)) {
            partOfQuery = 'Name LIKE \'%' + escapeSingleQuotes(params.productName) + '%\'';
            listOfPartsOfQueries.add(partOfQuery);
        } if (!String.isBlank(params.category)) {
            partOfQuery = 'Product2.Category__c LIKE \'%' + escapeSingleQuotes(params.category) + '%\'';
            listOfPartsOfQueries.add(partOfQuery);
        } if (!String.isBlank(params.costFrom)) {
            partOfQuery = 'UnitPrice >= ' + escapeSingleQuotes(params.costFrom) + '';
            listOfPartsOfQueries.add(partOfQuery);
        } if (!String.isBlank(params.costTo)) {
            partOfQuery = 'UnitPrice <= ' + escapeSingleQuotes(params.costTo) + '';
            listOfPartsOfQueries.add(partOfQuery);
        }
        listOfPartsOfQueries.add('Pricebook2.isStandard = true');
        return listOfPartsOfQueries;
    }

    public static String escapeSingleQuotes(String value) {
        return String.escapeSingleQuotes(value);
    }

    public static Product2 convertWrapperToProduct(Product2 product, ProductWrapper wrapper) {
        product.Name = wrapper.name;
        product.Brand__c = wrapper.brand;
        product.Model__c = wrapper.model;
        product.Color__c = wrapper.color;
        product.ProductCode = wrapper.productCode;
        if (String.isNotBlank(wrapper.category)) {
            product.Category__c = String.valueOf(wrapper.category);
        }
        if (String.isNotBlank(wrapper.currentInventory)) {
            product.Current_Inventory__c = Decimal.valueOf(wrapper.currentInventory);
        }
        if (String.isNotBlank(wrapper.installment)) {
            System.debug(wrapper.installment);
            product.Installment__c = Boolean.valueOf(wrapper.installment);
        }
        if (String.isNotBlank(wrapper.active)) {
            System.debug(wrapper.active);
            product.IsActive = Boolean.valueOf(wrapper.active);
        }
        product.Description = wrapper.description;
        return product;
    }

    public class ProductWrapper {
        public String id;
        public String category;
        public String name;
        public String brand;
        public String model;
        public String color;
        public String productCode;
        public String cost;
        public String currentInventory;
        public String installment;
        public String active;
        public String description;
    }

    public class SearchWrapper {
        public String productName;
        public String category;
        public String costFrom;
        public String costTo;
    }

    public class SearchWrapperResults {
        @AuraEnabled public List<Product2> results;
    }

    public class SearchWrapperResult {
        @AuraEnabled public Product2 result;
    }

    public class MainImage {
        public String objectId;
        public String imageId;
    }

    public class PricebookEntryDetails {
        @AuraEnabled public PricebookEntry result;
    }

    public class PricebookEntryResults {
        @AuraEnabled public List<PricebookEntry> results;
    }
}