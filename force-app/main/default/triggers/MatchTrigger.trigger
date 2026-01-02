trigger MatchTrigger on Match__c (before insert, after insert, after update, after delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            MatchTriggerHandler.handleAfterInsertUpdate(Trigger.new, Trigger.oldMap);
        }
        else if(Trigger.isDelete){
            MatchTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}