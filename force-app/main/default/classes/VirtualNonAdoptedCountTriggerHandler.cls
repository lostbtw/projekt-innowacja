public with sharing class VirtualNonAdoptedCountTriggerHandler implements ITriggerHandler {
  public void beforeInsert(List<SObject> newList) {
  }

  public void beforeUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
  }

  public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
  }

  public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    recalculateFromAdoptions((List<Adoption__c>) newList, null);
  }

  public void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    recalculateFromAdoptions(
      (List<Adoption__c>) newList,
      (List<Adoption__c>) oldList
    );
  }

  public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    recalculateFromAdoptions((List<Adoption__c>) oldList, null);
  }

  public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    recalculateFromAdoptions((List<Adoption__c>) newList, null);
  }

  public Boolean isDisabled() {
    return false;
  }

  private void recalculateFromAdoptions(
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
