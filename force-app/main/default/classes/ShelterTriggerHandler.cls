public with sharing class ShelterTriggerHandler implements ITriggerHandler {
  public void beforeInsert(List<SObject> newList) {
  }
  public void beforeUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    ShelterFieldProtectionService.validate(
      (List<Shelter__c>) newList,
      (Map<Id, Shelter__c>) oldMap
    );
  }
  public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
  }
  public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
  }
  public void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
  }
  public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
  }
  public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
  }
  public Boolean isDisabled() {
    return false;
  }
}