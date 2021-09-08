public with sharing class ContactController {

    @AuraEnabled
    public static Contact getContact() {
        Id contactId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        Contact con = [SELECT Id, FirstName, LastName, Interested__c, KnowAboutUs__c, IsSendEmailAllowed__c, Is_In_Club__c FROM Contact WHERE Id =: contactId];
        return con;
    }

    @AuraEnabled
    public static List<User> getUsers() {
        List<User> users = [SELECT Contact.Name, Contact.Id,Contact.Is_In_Club__c, PictureUrl__c FROM User WHERE Contact.Is_In_Club__c=TRUE];
        return users;
    }

    @AuraEnabled
    public static Contact upsertContact(Contact con) {
        con.Is_In_Club__c = true;
        update con;
        return con;
    }

    @AuraEnabled
    public static Contact leaveClub(Contact con) {
        con.Is_In_Club__c = false;
        update con;
        return con;
    }
}