public with sharing class ShelterFieldProtectionService {
  public static void validate(
    List<Shelter__c> newList,
    Map<Id, Shelter__c> oldMap
  ) {
    if (ShelterCountHelper.isCalculating)
      return;

    for (Shelter__c s : newList) {
      Shelter__c old = oldMap.get(s.Id);
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
}
