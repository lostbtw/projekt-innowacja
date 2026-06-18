public with sharing class AnimalShelterCountTriggerHandler implements ITriggerHandler {
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
    List<Animal__c> oldAnimals = (List<Animal__c>) oldList;
    Set<Id> shelterIds = new Set<Id>();
    Set<Id> excludeAnimalIds = new Set<Id>();
    for (Animal__c animal : oldAnimals) {
      if (animal.Shelter__c != null) {
        shelterIds.add(animal.Shelter__c);
        excludeAnimalIds.add(animal.Id);
      }
    }
    ShelterCountHelper.recalculate(shelterIds, excludeAnimalIds);
  }

  public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    ShelterCountHelper.recalculate(
      collectShelterIds((List<Animal__c>) newList),
      new Set<Id>()
    );
  }

  public void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    Set<Id> shelterIds = collectShelterIds((List<Animal__c>) newList);
    shelterIds.addAll(collectShelterIds((List<Animal__c>) oldList));
    ShelterCountHelper.recalculate(shelterIds, new Set<Id>());
  }

  public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
  }
  public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
  }

  public Boolean isDisabled() {
    return false;
  }

  private Set<Id> collectShelterIds(List<Animal__c> records) {
    Set<Id> ids = new Set<Id>();
    for (Animal__c animal : records) {
      if (animal.Shelter__c != null)
        ids.add(animal.Shelter__c);
    }
    return ids;
  }
}