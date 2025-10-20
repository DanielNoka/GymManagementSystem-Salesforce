public with sharing class EmailTrainersDaily  implements Schedulable{

    public void execute(SchedulableContext sc) {
        sendEmails();
    }

    public static void  sendEmails(){

    Date today = Date.today();
    Datetime startOfDay = Datetime.newInstance(today, Time.newInstance(0,0,0,0));
    Datetime endOfDay = Datetime.newInstance(today, Time.newInstance(23,59,59,999));

    //get all sessions today
    List<Session__c> sessions = [SELECT Id, Trainer__c, Start_Time__c, End_Time__c, Duration_min__c FROM Session__c 
    WHERE Start_Time__c >= :startOfDay AND Start_Time__c <= :endOfDay] ;
    //map sessions by trainer
    Map<Id,List<Session__c>> mapUserSessions = new Map<Id,List<Session__c>>();
   
    for(Session__c session : sessions){
         if(!mapUserSessions.containsKey(session.Trainer__c)){
             mapUserSessions.put(session.Trainer__c,new List<Session__c>());
         }
             mapUserSessions.get(session.Trainer__c).add(session);
         }
     
     //get user email
     Map<Id,User> mapUser = new Map<Id,User>([Select Id,Name,Email FROM User WHERE Id IN :mapUserSessions.keySet()]);

     List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

     for(Id trainerId : mapUserSessions.keySet()){
        List<Session__c> trainerSessions = mapUserSessions.get(trainerId);
        User user = mapUser.get(trainerId);
    
         //send email to trainer
        String body = 'Hello ' + user.Name + ',<br/><br/>';
        body += 'Here are your training sessions for today (' + today.format() + '):<br/><br/>';

        for (Session__c s : trainerSessions) {
                body += ' | Start: ' + s.Start_Time__c.format() + 
                        ' | Duration: ' + s.Duration_min__c + ' min<br/>';
            }

        body += '<br/>Best regards,<br/>Training Team';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{user.Email});
        email.setSubject('Your Training Sessions for ' + today.format());
        email.setHtmlBody(body);

        emails.add(email);

     }
   
      if (!emails.isEmpty() && (!Test.isRunningTest())) {
            Messaging.sendEmail(emails);
        }
    
    }
}
