public with sharing class VirtualNonAdoptedCountTriggerHandler {
  public void handle(
    List<Adoption__c> records,
    List<Adoption__c> old_records,
    Boolean isUpdate
  ) {
    Set<Id> animalIds = new Set<Id>();

    for (Adoption__c adoption : records) {
      if (adoption.Animal__c != null)
        animalIds.add(adoption.Animal__c);
    }
    if (Trigger.isUpdate) {
      for (Adoption__c adoption : old_records) {
        if (adoption.Animal__c != null)
          animalIds.add(adoption.Animal__c);
      }
    }

    if (animalIds.isEmpty())
      return;

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
}
