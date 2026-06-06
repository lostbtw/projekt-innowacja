trigger AnimalShelterCountTrigger on Animal__c (after insert, after update, before delete) {
    Set<Id> shelterIds = new Set<Id>();
    Set<Id> excludeAnimalIds = new Set<Id>();

    if (Trigger.isDelete) {
        for (Animal__c animal : Trigger.old) {
            if (animal.Shelter__c != null) {
                shelterIds.add(animal.Shelter__c);
                excludeAnimalIds.add(animal.Id);
            }
        }
    } else {
        for (Animal__c animal : Trigger.new) {
            if (animal.Shelter__c != null) shelterIds.add(animal.Shelter__c);
        }
        if (Trigger.isUpdate) {
            for (Animal__c animal : Trigger.old) {
                if (animal.Shelter__c != null) shelterIds.add(animal.Shelter__c);
            }
        }
    }

    ShelterCountHelper.recalculate(shelterIds, excludeAnimalIds);
}

