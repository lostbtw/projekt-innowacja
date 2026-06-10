trigger AnimalShelterCountTrigger on Animal__c (after insert, after update, before delete) {
    AnimalShelterCountTriggerHandler handler = new AnimalShelterCountTriggerHandler();
    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.new, Trigger.old);
    } else if (Trigger.isBefore && Trigger.isDelete) {
        handler.beforeDelete(Trigger.old);
    }
}