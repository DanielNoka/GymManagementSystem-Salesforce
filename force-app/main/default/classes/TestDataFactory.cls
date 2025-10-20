@isTest
public with sharing class TestDataFactory {

     public static User createTestUser(String profile) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profile LIMIT 1].Id;
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test' + System.currentTimeMillis() + '@example.com',
            Username = 'test' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Europe/London',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            ProfileId = profileId
        );
        insert u;
        return u;
    }


    //create a session
    public static Session__c createTestSession(Id contactId) {
        Session__c session = new Session__c(
            Start_Time__c = Datetime.now().addHours(1),
            Duration_min__c = '60',
            Member__c = contactId
        );
        
         return session;
    }

    public static List<Session__c> createTestSessionBulk(Id contactId, Integer numberOfSessions) {
        List<Session__c> newSessions = new List<Session__c>();
        for (Integer i = 0; i < numberOfSessions; i++) {
            newSessions.add(createTestSession(contactId));
        }
        
         return newSessions;
    }

     // create a contact
    public static Contact createTestContact() {
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test' + System.currentTimeMillis() + '@example.com'
        );
        return con;
    }
   
}