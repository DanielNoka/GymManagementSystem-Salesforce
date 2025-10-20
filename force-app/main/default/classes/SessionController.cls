public with sharing class SessionController {
    
    @AuraEnabled(cacheable=true)
    public static  List<Session__c>  getSessionsByTrainerAndDate(Date selectedDate, Id trainerId){

    try {
        if(selectedDate == null){
                throw new AuraHandledException('Date null not allowed'); //for testing coverage
        }

        String baseQuery = 
        'SELECT Id, Name, Start_Time__c, Member_Name__c, Member_Email__c, Duration_min__c, Trainer__c, Member__c, Trainer__r.Name ' +
        'FROM Session__c ' +
        'WHERE DAY_ONLY(Start_Time__c) = :selectedDate';

        if(trainerId != null){//will be used in admin dashboard if all trainers is selected
            baseQuery += ' AND Trainer__c = :trainerId';
        }
        List<Session__c> result = Database.query(baseQuery);
        return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
     public static List<User> getTrainers(){
       return [
            SELECT Id, Name, Email
            FROM User
            WHERE Profile.Name = 'Trainer'];
     }

    @AuraEnabled(cacheable=true)
    public static string getUserProfile(){
        try {
            User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            return currentUser.Profile.Name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String generatePDF(Id sessionId) {
        // Get the Visualforce page
        PageReference pdfPage = Page.SessionPdf;
        pdfPage.getParameters().put('id', sessionId);

         if (Test.isRunningTest()) {
        return 'TEST_BASE64_PDF';
         }
        
        // Convert to PDF
        Blob pdfBlob = pdfPage.getContentAsPDF();
        
        return EncodingUtil.base64Encode(pdfBlob);
    }
}