public with sharing class AdoptionStatusChangeTriggerHandler implements ITriggerHandler {
  public void beforeInsert(List<SObject> newList) {
  }

  public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
  }

  public void beforeUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
  }

  public void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    List<Adoption__c> newRecords = (List<Adoption__c>) newList;
    Map<Id, Adoption__c> oldMap2 = (Map<Id, Adoption__c>) oldMap;

    EmailTemplate template = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = 'Adoption_status_change_1780397637232'
      LIMIT 1
    ];

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Adoption__c adoption : newRecords) {
      Adoption__c oldAdoption = oldMap2.get(adoption.Id);

      if (
        adoption.Status__c != oldAdoption.Status__c &&
        adoption.Contact__c != null
      ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(template.Id);
        mail.setTargetObjectId(adoption.Contact__c);
        mail.setWhatId(adoption.Id);
        mail.setSaveAsActivity(false);
        mail.setTreatTargetObjectAsRecipient(true);

        emails.add(mail);
      }
    }

    if (!emails.isEmpty()) {
      Messaging.sendEmail(emails);
    }
  }

  public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
  }

  public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
  }

  public void afterUndelete(List<SObject> newList, Map<Id, SObject> newMap) {
  }

  public Boolean isDisabled() {
    return false;
  }
}
