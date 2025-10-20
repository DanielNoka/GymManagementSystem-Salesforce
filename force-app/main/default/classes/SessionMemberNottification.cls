public with sharing class SessionMemberNottification implements Queueable{
    
    private List<Session__c> sessions;
    private String emailType;

    public SessionMemberNottification(List<Session__c> sessions, String emailType) {
        this.sessions = sessions;
        this.emailType = emailType;
    }
 
    public void execute(QueueableContext context){
        // Set<Id> memberIds = new  Set<Id>();
        // for(Session__c s : sessions){
        //     memberIds.add(s.Member__c);
        // }

        // List<Session__c> session = [SELECT Id, Member__c, Start_Time__c, Duration_min__c, Member__r.Email,Member__r.Name,Trainer__r.Name
        //  FROM Session__c WHERE Member__c IN :memberIds];

        EmailTemplate template = [ SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName = :emailType LIMIT 1];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        System.debug('template: ' + template.DeveloperName);

        for(Session__c s: sessions){
            if (s.Member__c != null) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(template.Id);      
                email.setTargetObjectId(s.Member__c); 
                if(emailType !='Email_Session_Deleted'){
                email.setWhatId(s.Id);       
                }
                emails.add(email);//for create and update because on delete we dont have a whatId
            
        }}

        if (!emails.isEmpty() && (!Test.isRunningTest())) {
            Messaging.sendEmail(emails);
            System.debug(emails.size());
        }
        
    }
}