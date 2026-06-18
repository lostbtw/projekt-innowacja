public with sharing class ShelterFieldProtectionTriggerHandler implements ITriggerHandler {
  public void beforeInsert(List<SObject> newList) {
  }

  public void beforeUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    if (ShelterCountHelper.isCalculating) {
      return;
    }

    Map<Id, Shelter__c> oldShelterMap = (Map<Id, Shelter__c>) oldMap;
    for (Shelter__c s : (List<Shelter__c>) newList) {
      Shelter__c old = oldShelterMap.get(s.Id);
      if (s.Total_Adoptions__c != old.Total_Adoptions__c) {
        s.Total_Adoptions__c.addError(
          'Total Adoptions is calculated automatically and cannot be modified manually.'
        );
      }
      if (
        s.Non_Virtual_Adopted_Animals__c != old.Non_Virtual_Adopted_Animals__c
      ) {
        s.Non_Virtual_Adopted_Animals__c.addError(
          'Non-Virtual Adopted Animals is calculated automatically and cannot be modified manually.'
        );
      }
    }
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