public with sharing class AdoptionStatusChangeTriggerHandler {
  public void afterUpdate(
    List<Adoption__c> newRecords,
    Map<Id, Adoption__c> oldMap
  ) {
    EmailTemplate template = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = 'Adoption_status_change_1780397637232'
      LIMIT 1
    ];

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Adoption__c adoption : newRecords) {
      Adoption__c oldAdoption = oldMap.get(adoption.Id);

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
}