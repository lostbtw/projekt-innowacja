public with sharing class ShelterController {
    @AuraEnabled(cacheable=true)
    public static List<Shelter__c> getShelters() {
        return [
            SELECT Id, Name,
                Monday_Open__c, Monday_Close__c,
                Tuesday_Open__c, Tuesday_Close__c,
                Wednesday_Open__c, Wednesday_Close__c,
                Thursday_Open__c, Thursday_Close__c,
                Friday_Open__c, Friday_Close__c,
                Saturday_Open__c, Saturday_Close__c,
                Sunday_Open__c, Sunday_Close__c,
                Closed_From__c, Closed_To__c
            FROM Shelter__c
            ORDER BY Name ASC
        ];
    }
}