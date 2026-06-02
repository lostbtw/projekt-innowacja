public with sharing class ShelterController {
    @AuraEnabled(cacheable=true)
    public static List<Shelter__c> getShelters() {
        return [
            SELECT Id, Name
            FROM Shelter__c
        ];
    }
}