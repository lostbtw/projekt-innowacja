public with sharing class ShelterMapController {

    @AuraEnabled(cacheable=true)
    public static List<Shelter__c> ShelterMapController(Id shelterId) {
        Shelter__c current = [
            SELECT City__c
            FROM Shelter__c
            WHERE Id = :shelterId
            LIMIT 1
        ];

        if (current.City__c != null) {
            return new List<Shelter__c>();
        }

        return [
            SELECT Id, Name, Street__c, City__c, State__c,
                   PostalCode__c, Country__c
            FROM Shelter__c
            WHERE City__c = :current.City__c
            ORDER BY Name
        ];
    }
    
}
