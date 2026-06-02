trigger AdoptionCountTrigger on Adoption__c (after insert, after update, after delete, after undelete) {
    
    Set<Id> animalIds = new Set<Id>();

    List<Adoption__c> records = (Trigger.isDelete) ? Trigger.old : Trigger.new;

    for (Adoption__c animalId : records) {
        if (animalId.Animal__c != null) {
            animalIds.add(animalId.Animal__c);
        }
    }

    if (Trigger.isUpdate) {
        for (Adoption__c animalId : Trigger.old) {
            if (animalId.Animal__c != null) {
                animalIds.add(animalId.Animal__c);
            }
        }
    }

    if (animalIds.isEmpty()) return;

    Map<Id, Id> animalToShelter = new Map<Id, Id>();
    
    for (Animal__c animal : [SELECT Id, Shelter__c FROM Animal__c WHERE Id IN :animalIds AND Shelter__c != null]) {
        animalToShelter.put(animal.Id, animal.Shelter__c);
    }

    Set<Id> shelterIds = new Set<Id>(animalToShelter.values());
    
    if (shelterIds.isEmpty()) return;


    Map<Id, Integer> shelterAdoptionCount = new Map<Id, Integer>();
    
    for (Id shelterId : shelterIds) {
        shelterAdoptionCount.put(shelterId, 0);
    }

    for (AggregateResult ar : [
        SELECT Animal__r.Shelter__c shelterId, COUNT(Id) cnt
        FROM Adoption__c
        WHERE Animal__r.Shelter__c IN :shelterIds
        GROUP BY Animal__r.Shelter__c
    ]) {
        shelterAdoptionCount.put((Id) ar.get('shelterId'), (Integer) ar.get('cnt'));
    }


    List<Shelter__c> sheltersToUpdate = new List<Shelter__c>();
    
    for (Id shelterId : shelterIds) {
        sheltersToUpdate.add(new Shelter__c(
            Id = shelterId,
            Total_Adoptions__c = shelterAdoptionCount.get(shelterId)
        ));
    }

    update sheltersToUpdate;
}