@isTest
public with sharing class SessionControllerTest {
    
    @isTest
    static void testGetSessionsByDate(){

      Date selectedDate = Date.today().addDays(1);
      User testUser = TestDataFactory.createTestUser('Trainer');

      System.runAs(testUser){
        Contact con = TestDataFactory.createTestContact();
        insert con;
        List<Session__c> sessions = TestDataFactory.createTestSessionBulk(con.Id, 50);
        
        for(Session__c session : sessions){
            session.Start_Time__c = Date.today().addDays(1);
            }
        insert sessions;

        Test.startTest();
        List<Session__c> result = SessionController.getSessionsByTrainerAndDate(selectedDate, testUser.Id);
        Test.stopTest();

        System.Assert.areEqual(50, result.size());
          }
    }

       @isTest
    static void testGetSessionsByDateException() {
          Test.startTest();
        try {
            List<Session__c> result = SessionController.getSessionsByTrainerAndDate(null,null); //an exception should be thrown
        } catch (AuraHandledException e) {   
            Assert.isNotNull(e);
        }
           Test.stopTest();
    }

  @isTest
  static void testGetSessionsByTrainerAndDateWithNullTrainer(){
      Date selectedDate = Date.today().addDays(1);

      Contact con = TestDataFactory.createTestContact();
      insert con;

      List<Session__c> sessions = TestDataFactory.createTestSessionBulk(con.Id, 5);
      for(Session__c s : sessions){
          s.Start_Time__c = Date.today().addDays(1);
      }
      insert sessions;

      Test.startTest();
      List<Session__c> result = SessionController.getSessionsByTrainerAndDate(selectedDate, null);
      Test.stopTest();

      System.assertEquals(5, result.size());
  }

    @IsTest
    static void testGeneratePDF() {
      
      Contact con = TestDataFactory.createTestContact();
      insert con;

      Session__c s = TestDataFactory.createTestSession(con.Id);  
   
      Test.startTest();
      String base64PDF = SessionController.generatePDF(s.Id);
      Test.stopTest();
        
      System.assertNotEquals(null, base64PDF, 'The returned value should not be null');
    }

    @isTest
    static void testUserProfile(){
          User testUser = TestDataFactory.createTestUser('Trainer');

          System.runAs(testUser){
          Test.startTest();
          String userProfile = SessionController.getUserProfile();
          Test.stopTest();

          System.Assert.areEqual('Trainer', userProfile);
          }

    }

  @isTest
  static void testgetTrainers(){
          User admin = TestDataFactory.createTestUser('System Administrator');
          User trainer = TestDataFactory.createTestUser('Trainer');

          System.runAs(admin){
          List<User> trainers = SessionController.getTrainers();
         
          System.assertNotEquals(0, trainers.size(), 'Trainers list should not be empty');
          }

          
    }

 }
    
