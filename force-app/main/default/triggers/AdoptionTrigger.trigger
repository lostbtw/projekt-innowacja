trigger AdoptionTrigger on Adoption__c (after insert, after update, after delete, after undelete) {
    ITriggerHandler adoptionCount = new AdoptionCountTriggerHandler();
    ITriggerHandler virtualCount = new VirtualNonAdoptedCountTriggerHandler();
    ITriggerHandler statusChange = new AdoptionStatusChangeTriggerHandler();

    if (Trigger.isAfter && Trigger.isInsert) {
        if (!adoptionCount.isDisabled()) adoptionCount.afterInsert(Trigger.new, Trigger.newMap);
        if (!virtualCount.isDisabled()) virtualCount.afterInsert(Trigger.new, Trigger.newMap);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        if (!adoptionCount.isDisabled()) adoptionCount.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        if (!virtualCount.isDisabled()) virtualCount.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        if (!statusChange.isDisabled()) statusChange.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        if (!adoptionCount.isDisabled()) adoptionCount.afterDelete(Trigger.old, Trigger.oldMap);
        if (!virtualCount.isDisabled()) virtualCount.afterDelete(Trigger.old, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isUndelete) {
        if (!adoptionCount.isDisabled()) adoptionCount.afterUndelete(Trigger.new, Trigger.newMap);
        if (!virtualCount.isDisabled()) virtualCount.afterUndelete(Trigger.new, Trigger.newMap);
    }
}
