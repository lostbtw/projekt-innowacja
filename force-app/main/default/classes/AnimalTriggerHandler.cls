public with sharing class AnimalTriggerHandler implements ITriggerHandler {
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
    AnimalShelterCountService.recalculateOnDelete((List<Animal__c>) oldList);
  }
  public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    AnimalShelterCountService.recalculateOnInsert((List<Animal__c>) newList);
  }
  public void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    AnimalShelterCountService.recalculateOnUpdate(
      (List<Animal__c>) newList,
      (List<Animal__c>) oldList
    );
  }
  public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
  }
  public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
  }
  public Boolean isDisabled() {
    return false;
  }
}
