public with sharing class AdoptionCountService {
  public static void recalculate(
    List<Adoption__c> records,
    List<Adoption__c> oldRecords
  ) {
    Set<Id> animalIds = collectAnimalIds(records, oldRecords);
    if (animalIds.isEmpty())
      return;

    recalculateTotalAdoptions(animalIds);
    recalculateNonAdoptedCount(animalIds);
  }

  private static void recalculateTotalAdoptions(Set<Id> animalIds) {
    Map<Id, Id> animalToShelter = new Map<Id, Id>();
    for (Animal__c animal : [
      SELECT Id, Shelter__c
      FROM Animal__c
      WHERE Id IN :animalIds AND Shelter__c != NULL
    ]) {
      animalToShelter.put(animal.Id, animal.Shelter__c);
    }

    Set<Id> shelterIds = new Set<Id>(animalToShelter.values());
    if (shelterIds.isEmpty())
      return;

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
      shelterAdoptionCount.put(
        (Id) ar.get('shelterId'),
        (Integer) ar.get('cnt')
      );
    }

    List<Shelter__c> sheltersToUpdate = new List<Shelter__c>();
    for (Id shelterId : shelterIds) {
      sheltersToUpdate.add(
        new Shelter__c(
          Id = shelterId,
          Total_Adoptions__c = shelterAdoptionCount.get(shelterId)
        )
      );
    }

    ShelterCountHelper.isCalculating = true;
    try {
      update sheltersToUpdate;
    } finally {
      ShelterCountHelper.isCalculating = false;
    }
  }

  private static void recalculateNonAdoptedCount(Set<Id> animalIds) {
    Set<Id> shelterIds = new Set<Id>();
    for (Animal__c animal : [
      SELECT Id, Shelter__c
      FROM Animal__c
      WHERE Id IN :animalIds AND Shelter__c != NULL
    ]) {
      shelterIds.add(animal.Shelter__c);
    }
    ShelterCountHelper.recalculate(shelterIds, new Set<Id>());
  }

  private static Set<Id> collectAnimalIds(
    List<Adoption__c> records,
    List<Adoption__c> oldRecords
  ) {
    Set<Id> animalIds = new Set<Id>();
    for (Adoption__c adoption : records) {
      if (adoption.Animal__c != null)
        animalIds.add(adoption.Animal__c);
    }
    if (oldRecords != null) {
      for (Adoption__c adoption : oldRecords) {
        if (adoption.Animal__c != null)
          animalIds.add(adoption.Animal__c);
      }
    }
    return animalIds;
  }
}
