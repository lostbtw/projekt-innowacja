public with sharing class AnimalController {
    @AuraEnabled(cacheable=true)
    public static List<Animal__c> getLostAnimalsByDate(Date admissionDate) {
        List<Animal__c> animals = [
            select Id, Name, Status__c, Date_of_Admission__c
            from Animal__c
            Where Status__c = 'Lost' and Date_of_Admission__c = :admissionDate
        ];
        return animals;
    }

    @AuraEnabled(cacheable=true)
    public static List<Animal__c> getAnimalWithPhotos() {
        List<Animal__c> animals = [
            select Id, Name, Photo__c, Photo_Preview__c
            from Animal__c
            where Photo__c != null
        ];
        return animals;
    }
}
