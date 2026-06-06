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

    @AuraEnabled(cacheable=true)
    public static List<Shelter__c> getSheltersInSameCity(Id shelterId) {
        Shelter__c current = [
            SELECT City__c
            FROM Shelter__c
            WHERE Id = :shelterId
            LIMIT 1
        ];
        System.debug('Step 1 - Found shelter. City value: [' + current.City__c + ']');
        System.debug('Step 1 - City is null: ' + (current.City__c == null));

        if (current.City__c != null) {
            List<Shelter__c> results = [
                SELECT Id, Name, City__c
                FROM Shelter__c
                WHERE City__c = :current.City__c
            ];
            System.debug('Step 2 - Shelters found: ' + results.size());
            for (Shelter__c s : results) {
                System.debug('  -> ' + s.Name + ' | ' + s.City__c);
            }
        } else {
            System.debug('Step 2 - SKIPPED because City is null');
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
