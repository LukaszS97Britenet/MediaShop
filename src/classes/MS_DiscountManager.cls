public with sharing class MS_DiscountManager {

    @AuraEnabled
    public static PricebookEntryWrapperResults getAllProducts() {
        PricebookEntryWrapperResults productsWrapper = new PricebookEntryWrapperResults();
        try {
            List<Product2> products = [SELECT Id FROM Product2];
            List<Id> productsId = new List<Id>();
            for (Product2 product : products) {
                productsId.add(product.Id);
            }
            productsWrapper.results = [
                    SELECT Id,Name,UnitPrice,Product2Id,Pricebook2Id, Product2.MainImageId__c
                    FROM PricebookEntry
                    WHERE Pricebook2.Name = 'Standard Price Book'
                    ORDER BY UnitPrice ASC
            ];
            return productsWrapper;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static PricebookWrapperResults getAllPriceBooks() {
        PricebookWrapperResults results = new PricebookWrapperResults();
        try {
            results.results = [SELECT Id, IsActive, Name FROM Pricebook2];
            return results;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static Boolean savePricebookEntry(String payloadJson) {
        PricebookEntryWrapper payload = (PricebookEntryWrapper) JSON.deserialize(payloadJson, PricebookEntryWrapper.class);
        PricebookEntryWrapper productsWrapper = new PricebookEntryWrapper();
        try {
            Pricebook2 newPricebook = new Pricebook2();
            newPricebook.Name = payload.pricebookName;
            newPricebook.IsActive = false;
            insert newPricebook;
            List<PricebookEntry> pricebooks = [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2.Name = 'Standard Price Book'];
            List<PricebookEntry> productEntries = new List<PricebookEntry>();
            PricebookEntry pricebookEntry;
            for (PricebookEntry pricebook : pricebooks) {
                pricebookEntry = new PricebookEntry();
                pricebookEntry.Pricebook2Id = newPricebook.Id;
                pricebookEntry.Product2Id = pricebook.Product2Id;
                pricebookEntry.PercentDiscount__c = Decimal.valueOf(payload.percentageOfPromotion);
                Decimal price = (pricebook.UnitPrice * Decimal.valueOf(payload.percentageOfPromotion)) / 100;
                pricebookEntry.UnitPrice = pricebook.UnitPrice - price;
                productEntries.add(pricebookEntry);
            }
            insert productEntries;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static PricebookEntryWrapperResults getPriceBookEntries(Id pricebookId) {
        PricebookEntryWrapperResults productsWrapper = new PricebookEntryWrapperResults();
        try {
            productsWrapper.results = [SELECT Id,Name,UnitPrice,Product2Id,Pricebook2Id, Product2.MainImageId__c, PercentDiscount__c FROM PricebookEntry WHERE Pricebook2Id = :pricebookId];
            return productsWrapper;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static Boolean pricebookDelete(Id pricebookId) {
        try {
            List<PricebookEntry> listPricebookEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :pricebookId];
            Pricebook2 pricebook = new Pricebook2();
            pricebook.Id = pricebookId;
            delete listPricebookEntries;
            delete pricebook;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static PricebookDetails getPricebook(Id pricebookId) {
        PricebookDetails pricebook = new PricebookDetails();
        try {
            pricebook.pricebookEntries = [SELECT Id, UnitPrice, PercentDiscount__c, Pricebook2Id, Product2Id, Pricebook2.Name FROM PricebookEntry WHERE Pricebook2Id = :pricebookId];
            pricebook.pricebookId = pricebookId;
            pricebook.pricebookName = pricebook.pricebookEntries.get(0).Pricebook2.Name;
            return pricebook;
        } catch (Exception e) {
            return pricebook;
        }
    }

    @AuraEnabled
    public static Boolean editPricebookProducts(String payloadJson) {
        try {
            ManagedPhotosPricebook payload = (ManagedPhotosPricebook) JSON.deserialize(payloadJson, ManagedPhotosPricebook.class);
            List<PricebookEntry> listOfProductsStandard = [SELECT Product2Id, UnitPrice, PercentDiscount__c FROM PricebookEntry WHERE Pricebook2.Name = 'Standard Price Book' AND Product2Id = :payload.productsIds];
            List<PricebookEntry> listOfProductsCustom = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :payload.pricebookId];
            Map<String, PricebookEntry> mapOfProductsStandard = new Map<String, PricebookEntry>();
            Map<String, PricebookEntry> mapOfProductsCustom = new Map<String, PricebookEntry>();
            PricebookEntry pricebookEntry;
            List<PricebookEntry> newPricebooks = new List<PricebookEntry>();
            for (PricebookEntry pricebookEntryStandard : listOfProductsStandard) {
                mapOfProductsStandard.put(pricebookEntryStandard.Product2Id, pricebookEntryStandard);
            }
            for (PricebookEntry pricebookEntryCustom : listOfProductsCustom) {
                mapOfProductsCustom.put(pricebookEntryCustom.Product2Id, pricebookEntryCustom);
            }
            for (String productId : payload.productsIds) {
                if (mapOfProductsCustom.get(productId) == null) {
                    PricebookEntry elFromMap = mapOfProductsStandard.get(productId);
                    pricebookEntry = new PricebookEntry();
                    pricebookEntry.PercentDiscount__c = elFromMap.PercentDiscount__c;
                    pricebookEntry.UnitPrice = elFromMap.UnitPrice;
                    pricebookEntry.Product2Id = elFromMap.Product2Id;
                    pricebookEntry.Pricebook2Id = payload.pricebookId;
                    newPricebooks.add(pricebookEntry);
                }
            }
            insert newPricebooks;
            List<PricebookEntry> listOfProductsCustomToDelete = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :payload.pricebookId AND Product2Id NOT IN :payload.productsIds];
            delete listOfProductsCustomToDelete;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean savePricebookEntryCustom(String payloadJson) {
        PricebookEntryWrapperCustom payload = (PricebookEntryWrapperCustom) JSON.deserialize(payloadJson, PricebookEntryWrapperCustom.class);
        PricebookEntryWrapper productsWrapper = new PricebookEntryWrapper();
        try {
            Pricebook2 newPricebook = new Pricebook2();
            newPricebook.Name = payload.pricebookName;
            newPricebook.IsActive = false;
            insert newPricebook;
            Map<String, String> mapOfPercents = new Map<String, String>();
            List<String> listOfId = new List<String>();
            for(ProductsWithPercents product : payload.productsId) {
                listOfId.add(product.id);
                mapOfPercents.put(product.id, product.percentDiscount);
            }
            List<PricebookEntry> pricebooks = [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2.Name = 'Standard Price Book' AND Product2Id = :listOfId];
            List<PricebookEntry> productEntries = new List<PricebookEntry>();
            PricebookEntry pricebookEntry;
            for (PricebookEntry pricebook : pricebooks) {
                pricebookEntry = new PricebookEntry();
                pricebookEntry.Pricebook2Id = newPricebook.Id;
                pricebookEntry.Product2Id = pricebook.Product2Id;
                if(mapOfPercents.get(pricebook.Product2Id) != 'null') {
                    pricebookEntry.PercentDiscount__c = Decimal.valueOf(mapOfPercents.get(pricebook.Product2Id));
                    Decimal price = (pricebook.UnitPrice * Decimal.valueOf(mapOfPercents.get(pricebook.Product2Id))) / 100;
                        pricebookEntry.UnitPrice = pricebook.UnitPrice - price;
                } else {
                    pricebookEntry.PercentDiscount__c = Decimal.valueOf(payload.percentageOfPromotion);
                    Decimal price = (pricebook.UnitPrice * Decimal.valueOf(payload.percentageOfPromotion)) / 100;
                        pricebookEntry.UnitPrice = pricebook.UnitPrice - price;
                }
                productEntries.add(pricebookEntry);
            }
            insert productEntries;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean editPercentageOfProducts(String payloadJson) {
        PricebookEntryWrapper payload = (PricebookEntryWrapper) JSON.deserialize(payloadJson, PricebookEntryWrapper.class);
        try {
            List<PricebookEntry> listOfProductsStandard;
            List<PricebookEntry> listOfProductsCustom;
            if(payload.productsId != null) {
                listOfProductsStandard = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'Standard Price Book' AND Product2Id =: payload.productsId];
                listOfProductsCustom = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = :payload.pricebookName AND Product2Id =: payload.productsId];
            } else {
                listOfProductsStandard = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = 'Standard Price Book'];
                listOfProductsCustom = [SELECT Id, Name, UnitPrice, Product2Id FROM PricebookEntry WHERE Pricebook2.Name = :payload.pricebookName];
            }
            for(PricebookEntry pricebookStandard:listOfProductsStandard) {
                for(PricebookEntry pricebookCustom:listOfProductsCustom) {
                    if(pricebookCustom.Product2Id == pricebookStandard.Product2Id) {
                        pricebookCustom.PercentDiscount__c = Decimal.valueOf(payload.percentageOfPromotion);
                        Decimal price = (pricebookStandard.UnitPrice * Decimal.valueOf(payload.percentageOfPromotion)) / 100;
                        pricebookCustom.UnitPrice = pricebookStandard.UnitPrice - price;
                    }
                }
            }
            update listOfProductsCustom;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public class PricebookEntryWrapper {
        public List<String> productsId;
        public String pricebookName;
        public String percentageOfPromotion;
    }

    public class PricebookEntryWrapperCustom {
        public List<ProductsWithPercents> productsId;
        public String pricebookName;
        public String percentageOfPromotion;
    }
    public class ProductsWithPercents {
        public String id;
        public String percentDiscount;
    }

    public class ManagedPhotosPricebook {
        public List<String> productsIds;
        public String pricebookId;
    }

    public class PricebookEditWrapper {
        public String pricebookName;
        public String pricebookId;
        public String pricebookPercents;
    }

    public class PricebookWrapperResults {
        @AuraEnabled public List<Pricebook2> results;
    }

    public class PricebookEntryWrapperResults {
        @AuraEnabled public List<PricebookEntry> results;
    }

    public class PricebookDetails {
        @AuraEnabled public List<PricebookEntry> pricebookEntries;
        @AuraEnabled public String pricebookName;
        @AuraEnabled public String pricebookId;
    }
}