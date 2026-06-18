trigger VirtualNonAdoptedCountTrigger on Adoption__c (after insert, after update, after delete, after undelete) {
    VirtualNonAdoptedCountTriggerHandler handler = new VirtualNonAdoptedCountTriggerHandler();
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) handler.afterInsert(Trigger.new, Trigger.newMap);
        else if (Trigger.isUpdate) handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        else if (Trigger.isDelete) handler.afterDelete(Trigger.old, Trigger.oldMap);
        else if (Trigger.isUndelete) handler.afterUndelete(Trigger.new, Trigger.newMap);
    }
}