trigger VirtualNonAdoptedCountTrigger on Adoption__c (after insert, after update, after delete, after undelete) {
    VirtualNonAdoptedCountTriggerHandler handler = new VirtualNonAdoptedCountTriggerHandler();
    List<Adoption__c> records = Trigger.isDelete ? Trigger.old : Trigger.new;
    handler.handle(records, Trigger.old, Trigger.isUpdate);
}

