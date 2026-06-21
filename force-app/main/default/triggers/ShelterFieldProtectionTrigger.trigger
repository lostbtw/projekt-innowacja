trigger ShelterFieldProtectionTrigger on Shelter__c (before update) {
    ITriggerHandler handler = new ShelterTriggerHandler();
    if (Trigger.isBefore && Trigger.isUpdate){
        handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}