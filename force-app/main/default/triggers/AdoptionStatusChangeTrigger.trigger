trigger AdoptionStatusChangeTrigger on Adoption__c (after update) {
    AdoptionStatusChangeTriggerHandler handler = new AdoptionStatusChangeTriggerHandler();
    List<Adoption__c> newRecords = Trigger.isDelete ? Trigger.old : Trigger.new;
    if (Trigger.isAfter && Trigger.isUpdate){
        handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}