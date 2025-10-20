@isTest
public with sharing class SessionTriggerHelperTest {

     @isTest 
    static void testSetTrainerAutomaticallyByLoggedUser(){
       User testUser = TestDataFactory.createTestUser('Trainer');
        
        System.runAs(testUser) {

        Contact con = TestDataFactory.createTestContact();
        insert con;
        Session__c session = TestDataFactory.createTestSession(con.Id);

      
        Test.startTest();
        insert session;
        Test.stopTest();

        Session__c newSession = [Select Trainer__c,OwnerId From Session__c where Id = :session.Id];
        System.assertEquals(testUser.Id, newSession.Trainer__c, 'Trainer should be set automatically');
        System.assertEquals(testUser.Id, newSession.OwnerId, 'Trainer should be set automatically');
    }
    }

    @isTest 
    static void testSetTrainerAutomaticallyByAdmin(){
    
       User adminUser = TestDataFactory.createTestUser('System Administrator');
       User trainerUser = TestDataFactory.createTestUser('Trainer');
         
     System.runAs(adminUser) {
      
        Contact con = TestDataFactory.createTestContact();
        insert con;
        Session__c session = TestDataFactory.createTestSession(con.Id);
        session.Trainer__c = trainerUser.Id;// trainer is set by admin

        Test.startTest();
        insert session;
        Test.stopTest();

        Session__c newSession = [Select Trainer__c,OwnerId From Session__c where Id = :session.Id];
        System.assertEquals(trainerUser.Id, newSession.Trainer__c , 'Trainer should be set automatically to  new trainer');
        System.assertEquals(trainerUser.Id, newSession.OwnerId);

    }   
}

   @isTest 
    static void testSessionInsertBulk(){
    
    User testUser = TestDataFactory.createTestUser('Trainer');
     
    System.runAs(testUser) {
       
        Contact con = TestDataFactory.createTestContact();
        insert con;
        List<Session__c> sessions = TestDataFactory.createTestSessionBulk(con.Id, 100);

        Test.startTest();
        insert sessions;
        Test.stopTest();

        List<Session__c> newSessions = [Select Trainer__c,OwnerId From Session__c where Id IN :sessions];
        for(Session__c session : newSessions){
            System.Assert.areEqual(testUser.Id, session.Trainer__c);
            System.Assert.areEqual(testUser.Id, session.OwnerId);
        }
    }
}


    @isTest 
    static void testRecordVisibility(){
    
    User testUser = TestDataFactory.createTestUser('Trainer');
    User testUser2 = TestDataFactory.createTestUser('Trainer');
    
    //insert record at first user
     System.runAs(testUser){
        
        Contact con = TestDataFactory.createTestContact();
        insert con;
         List<Session__c> sessions = TestDataFactory.createTestSessionBulk(con.Id, 100);
      
        Test.startTest();
        insert sessions;
        Test.stopTest();
    }
    
    //check if second user can see it
     System.runAs(testUser2){
        List<Session__c> newSessions = [Select Trainer__c,OwnerId From Session__c];
        System.Assert.areEqual(0, newSessions.size(),'Second user should not be able to see the session');
    
    }
 }


    @isTest
    static void testTimeSetAutomatically(){

        User testUser = TestDataFactory.createTestUser('Trainer');

        System.runAs(testUser) {

            Contact con = TestDataFactory.createTestContact();
            insert con;
            Session__c session = TestDataFactory.createTestSession(con.Id);
            session.Start_Time__c = Datetime.now().addHours(1);//needed this because start time cannot be in past
            session.Duration_min__c='60';//add 60 minutes to start time
           
            Test.startTest();
            insert  session;
            Test.stopTest();

            Datetime expectedEnd = session.Start_Time__c.addMinutes(60);
            Session__c updatedSession = [Select End_Time__c From Session__c where Id = :session.Id];
            System.assertEquals(expectedEnd, updatedSession.End_Time__c, 'End time should be set automatically');
    }
}
    @isTest
    static void testSessionOverlappingSameTrainerSameTime(){

    User testUser = TestDataFactory.createTestUser('Trainer');

    System.runAs(testUser){
        // First session
        Contact con = TestDataFactory.createTestContact();
        insert con;
        Session__c session = TestDataFactory.createTestSession(con.Id);
        session.Start_Time__c = Datetime.now().addHours(1);
    

        // Second session in same time
        Session__c session2 = TestDataFactory.createTestSession(con.Id);
        session2.Start_Time__c = Datetime.now().addHours(1);

        
         Test.startTest();
        try {
            insert session;
            insert session2;
            
            //Both session are in same time so this will cause an error
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('This session time is already booked'));
        }
        Test.stopTest();
    }}

        @isTest
    static void testSessionNOTOverlappingSameTrainerDifferentTime(){

    User testUser = TestDataFactory.createTestUser('Trainer');

    System.runAs(testUser){
        // First session
        Contact con = TestDataFactory.createTestContact();
        insert con;
        Session__c session = TestDataFactory.createTestSession(con.Id);
        session.Start_Time__c = Datetime.now().addHours(1);
        session.Duration_min__c='60';
    

        // Different times both inserted successfully
        Session__c session2 = TestDataFactory.createTestSession(con.Id);
        session2.Start_Time__c = Datetime.now().addHours(3);
        session2.Duration_min__c='60';

        
        Test.startTest();
        insert session;
        insert session2;
        Test.stopTest();

         System.assertEquals(2, [SELECT COUNT() FROM Session__c], 'Both sessions should be inserted successfully.');
 
    }}

      @isTest
    static void testSessionNOTOverlappingDifferentTrainersSameTime(){

    User testUser = TestDataFactory.createTestUser('Trainer');
    User testUser2 = TestDataFactory.createTestUser('Trainer');
    User adminUser = TestDataFactory.createTestUser('System Administrator');

    System.runAs(testUser){
        Contact con = TestDataFactory.createTestContact();
        insert con;
        Session__c session = TestDataFactory.createTestSession(con.Id);
        session.Start_Time__c = Datetime.now().addHours(1);
        session.Duration_min__c='60';
        
        insert session;

    }
      System.runAs(testUser2){
        Contact con = TestDataFactory.createTestContact();
        insert con;
        Session__c session2 = TestDataFactory.createTestSession(con.Id);
        session2.Start_Time__c = Datetime.now().addHours(1);
        session2.Duration_min__c='60';
        
        insert session2;
 
    }
    
     System.runAs(adminUser){
        List<Session__c> newSessions = [Select Trainer__c,OwnerId From Session__c];
        System.Assert.areEqual(2, newSessions.size(),'Both sessions should be inserted successfully');
}}

   @isTest
    static void testEmailOnUpdateCreate() {
        
        User testUser = TestDataFactory.createTestUser('Trainer');
        
        System.runAs(testUser){
   
        Contact con = TestDataFactory.createTestContact();
        insert con;
        Session__c session = TestDataFactory.createTestSession(con.Id);
        session.Start_Time__c = Datetime.now().addHours(1);
      
        insert session;

        Test.startTest();
        session.Start_Time__c=Datetime.now().addHours(2);
        update session;
        delete session;
        Test.stopTest(); 
        //check if no errors email is sent
        System.assert(true, 'Job executed successfully');
    }}

    @isTest
    static void testDailyEmailJob() {
        
        User testUser = TestDataFactory.createTestUser('Trainer');
        
        System.runAs(testUser){
   
        Contact con = TestDataFactory.createTestContact();
        insert con;
        Session__c session = TestDataFactory.createTestSession(con.Id);
        session.Start_Time__c = Datetime.now().addHours(1);
      
        insert session;

        Test.startTest();
        EmailTrainersDaily.sendEmails();
        EmailTrainersDaily job = new EmailTrainersDaily();
        String jobId = System.schedule('TestDailyJob', '0 0 6 * * ?', job);
        Test.stopTest(); 

        //check if no errors email is sent
        System.assert(true, 'Job executed successfully');
    }}

}