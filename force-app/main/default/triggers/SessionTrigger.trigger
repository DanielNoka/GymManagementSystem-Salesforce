trigger SessionTrigger on Session__c (before insert, before update, after insert, after update, after delete) {

    //set trainer automatically
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        SessionTriggerHelper.setTrainerAutomatically(Trigger.new);
        SessionTriggerHelper.setEndTimeAutomatically(Trigger.new); 
        SessionTriggerHelper.preventOverlappingSessions(Trigger.new);
    }
    
    if (Trigger.isAfter ) {
        if (Trigger.isInsert ) {
        System.enqueueJob(new SessionMemberNottification(Trigger.new,'Email_Session_Created'));
        } 
         if (Trigger.isUpdate) {
        System.enqueueJob(new SessionMemberNottification(Trigger.new,'Email_Session_Updated'));
        } 
        if (Trigger.isDelete ) {
         System.enqueueJob(new SessionMemberNottification(Trigger.old,'Email_Session_Deleted'));
        } 
    }

}