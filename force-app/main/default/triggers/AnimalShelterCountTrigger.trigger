trigger AnimalShelterCountTrigger on Animal__c (after insert, after update, before delete) {
    ITriggerHandler handler = new AnimalShelterCountTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert)  handler.afterInsert(Trigger.new, Trigger.newMap);
    if (Trigger.isAfter && Trigger.isUpdate)  handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    if (Trigger.isBefore && Trigger.isDelete) handler.beforeDelete(Trigger.old, Trigger.oldMap);
}