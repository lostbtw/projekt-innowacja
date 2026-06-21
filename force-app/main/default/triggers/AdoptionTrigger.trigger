trigger AdoptionTrigger on Adoption__c (after insert, after update, after delete, after undelete) {
    ITriggerHandler handler = new AdoptionTriggerHandler();
    if (Trigger.isAfter && Trigger.isInsert){
        handler.afterInsert(Trigger.new, Trigger.newMap);
    }
    if (Trigger.isAfter && Trigger.isUpdate){
        handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isDelete){
        handler.afterDelete(Trigger.old, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isUndelete){
        handler.afterUndelete(Trigger.new, Trigger.newMap);
    }
}