public with sharing class AdoptionTriggerHandler implements ITriggerHandler {
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
  public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    AdoptionCountService.recalculate((List<Adoption__c>) oldList, null);
  }
  public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
    AdoptionCountService.recalculate((List<Adoption__c>) newList, null);
  }
  public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    AdoptionCountService.recalculate((List<Adoption__c>) newList, null);
  }
  public void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    AdoptionCountService.recalculate(
      (List<Adoption__c>) newList,
      (List<Adoption__c>) oldList
    );
    AdoptionStatusService.handleStatusChange(
      (List<Adoption__c>) newList,
      (List<Adoption__c>) oldList
    );
  }
  public Boolean isDisabled() {
    return false;
  }
}