trigger VirtualNonAdoptedCountTrigger on Adoption__c (after insert, after update, after delete, after undelete) {
    Set<Id> animalIds = new Set<Id>();

    List<Adoption__c> records = Trigger.isDelete ? Trigger.old : Trigger.new;
    for (Adoption__c adoption : records) {
        if (adoption.Animal__c != null) animalIds.add(adoption.Animal__c);
    }
    if (Trigger.isUpdate) {
        for (Adoption__c adoption : Trigger.old) {
            if (adoption.Animal__c != null) animalIds.add(adoption.Animal__c);
        }
    }

    if (animalIds.isEmpty()) return;

    Set<Id> shelterIds = new Set<Id>();
    for (Animal__c animal : [SELECT Id, Shelter__c FROM Animal__c WHERE Id IN :animalIds AND Shelter__c != null]) {
        shelterIds.add(animal.Shelter__c);
    }

    ShelterCountHelper.recalculate(shelterIds, new Set<Id>());
}
