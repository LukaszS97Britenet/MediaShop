public with sharing class ContactController {

    @AuraEnabled(Cacheable=true)
    public static Contact getContact() {
        Id contactId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        return [SELECT Id, FirstName, LastName, Interested__c, KnowAboutUs__c, IsSendEmailAllowed__c, Is_In_Club__c FROM Contact WHERE Id =: contactId];
    }

    @AuraEnabled
    public static Contact upsertContact(Contact con) {
        con.Is_In_Club__c = true;
        upsert con;
        return con;
    }

    @AuraEnabled
    public static Contact leaveClub(Contact con) {
        con.Is_In_Club__c = false;
        upsert con;
        return con;
    }
}