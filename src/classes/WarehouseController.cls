public with sharing class WarehouseController {

    @AuraEnabled
    public static List<Warehouse__c> searchByPhrase(String phrase) {
        List<Warehouse__c> warehouses = [SELECT Id, Name, Geolocation__c, Capacity__c FROM Warehouse__c WHERE Name LIKE :'%'+phrase+'%'];
        return warehouses;
    }

    @AuraEnabled
    public static List<Warehouse__c> searchWarehouse(String id) {
        List<Warehouse__c> warehouses = [SELECT Id, Name, Geolocation__c, Capacity__c FROM Warehouse__c WHERE Id = :id];
        return warehouses;
    }

    @AuraEnabled
    public static List<Product2> searchProducts(String phrase) {
        List<Product2> products = [SELECT Id, Name, MainImageId__c, Capacity__c FROM Product2 WHERE Name LIKE :'%'+phrase+'%'];
        return products;
    }

    @AuraEnabled
    public static List<Warehouse_Line_Item__c> searchWarehouseLineItems(String phrase, String warehouseId) {
        List<Warehouse_Line_Item__c> warehouseLineItems = [SELECT Id, Product__r.MainImageId__c, Product__r.Name, Products_Amount__c, Product__r.Capacity__c, Warehouse__r.Id, Warehouse__r.Occupied_Capacity__c FROM Warehouse_Line_Item__c WHERE Product__r.Name LIKE :'%'+phrase+'%' AND Products_Amount__c>0 AND Warehouse__c = :warehouseId];
        return warehouseLineItems;
    }

    @AuraEnabled
    public static Boolean deleteWarehouseLineItem(Warehouse_Line_Item__c warehouseLineItem) {
        Warehouse__c warehouse = new Warehouse__c();
        warehouse.Id = warehouseLineItem.Warehouse__r.Id;
        warehouse.Occupied_Capacity__c = warehouseLineItem.Warehouse__r.Occupied_Capacity__c - (warehouseLineItem.Products_Amount__c*warehouseLineItem.Product__r.Capacity__c);
        try {
            update warehouse;
            delete warehouseLineItem;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static String addWarehouseItem(String amount, String warehouseId, Product2 product) {
        Warehouse_Line_Item__c warehouseLineItem;
        Warehouse__c warehouse = [SELECT Id, Capacity__c, Occupied_Capacity__c FROM Warehouse__c WHERE Id= :warehouseId LIMIT 1];
        try {
            warehouseLineItem = [SELECT Id, Product__r.Capacity__c, Products_Amount__c FROM Warehouse_Line_Item__c WHERE Product__c = :product.Id AND Warehouse__c = :warehouseId];
            if((warehouseLineItem.Products_Amount__c + Decimal.valueOf(amount)) < 0) {
                return 'Remove_Error';
            }
            if(warehouse.Capacity__c < (warehouseLineItem.Product__r.Capacity__c*Decimal.valueOf(amount)) + warehouse.Occupied_Capacity__c) {
                return 'Capacity_Error';
            } else {
                warehouseLineItem.Products_Amount__c += Decimal.valueOf(amount);
                warehouse.Occupied_Capacity__c += Decimal.valueOf(amount)*warehouseLineItem.Product__r.Capacity__c;
                update warehouseLineItem;
                update warehouse;
                return 'Success';
            }
        } catch (Exception e) {
            warehouseLineItem = new Warehouse_Line_Item__c();
            warehouseLineItem.Warehouse__c = warehouseId;
            warehouseLineItem.Product__c = product.Id;
            warehouseLineItem.Products_Amount__c = Decimal.valueOf(amount);
            if(warehouseLineItem.Products_Amount__c < 0) {
                return 'Remove_Error';
            }
            if(warehouse.Occupied_Capacity__c == null) {
                warehouse.Occupied_Capacity__c = 0;
            }
            if(warehouse.Capacity__c < (product.Capacity__c*Decimal.valueOf(amount)) + warehouse.Occupied_Capacity__c) {
                return 'Capacity_Error';
            } else {
                warehouse.Occupied_Capacity__c += Decimal.valueOf(amount)*product.Capacity__c;
                insert warehouseLineItem;
                update warehouse;
                return 'Success';
            }
        }
    }
}