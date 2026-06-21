public with sharing class AdoptionStatusService {
  public static void handleStatusChange(
    List<Adoption__c> newList,
    List<Adoption__c> oldList
  ) {
    Map<Id, Adoption__c> oldMap = new Map<Id, Adoption__c>(oldList);

    EmailTemplate template = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = 'Adoption_status_change_1780397637232'
      LIMIT 1
    ];

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (Adoption__c adoption : newList) {
      Adoption__c old = oldMap.get(adoption.Id);
      if (adoption.Status__c != old.Status__c && adoption.Contact__c != null) {
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