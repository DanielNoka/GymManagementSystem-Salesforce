public with sharing class SessionTriggerHelper {
    
     public static void setTrainerAutomatically(List<Session__c> newSessions){
       
        for(Session__c session : newSessions){
            if(session.Trainer__c == null){//the trainer field is not in page layout for trainers so its null
               session.Trainer__c = UserInfo.getUserId();
            }else{
               session.OwnerId = session.Trainer__c; // in this case Trainer is set by admin so we need to set the owner to that trainer
            }
        }
    }

    public static void setEndTimeAutomatically(List<Session__c> newSessions){
        for(Session__c session : newSessions){
             Integer duration = Integer.valueOf(session.Duration_min__c);//convert picklist to int
             session.End_Time__c = session.Start_Time__c.addMinutes(duration);
        }
    }

    public static void preventOverlappingSessions(List<Session__c> newSessions){
        Set<Id> trainerIds = new Set<Id>();
        for(Session__c session : newSessions){
            trainerIds.add(session.Trainer__c);
        }
        //get all sessions per trainer
        Map<Id, List<Session__c>> trainerSessions = new Map<Id, List<Session__c>>();

        List<Session__c> oldSessions = [SELECT Id, Trainer__c, Start_Time__c, End_Time__c, Duration_min__c FROM Session__c WHERE Trainer__c IN :trainerIds
                                        AND Id NOT IN :newSessions];//to prevent self overlap because on update we need to exclude the current session

        for(Session__c s : oldSessions){
            if(!trainerSessions.containsKey(s.Trainer__c)){
                trainerSessions.put(s.Trainer__c, new List<Session__c>());
            }
             trainerSessions.get(s.Trainer__c).add(s);
        }

        for(Session__c newSession : newSessions){
            List<Session__c> trainerOldSessions = trainerSessions.get(newSession.Trainer__c);
            if (trainerOldSessions == null) continue; // prevent null pointer exception
            for(Session__c oldSession : trainerOldSessions){
                if(newSession.Start_Time__c < oldSession.End_Time__c && newSession.End_Time__c > oldSession.Start_Time__c){
                    newSession.addError('This session time is already booked');
                }


        }

    }
}

}