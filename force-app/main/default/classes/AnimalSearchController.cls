public with sharing class AnimalSearchController {
  @AuraEnabled(cacheable=true)
  public static List<Map<String, String>> getShelterOptions() {
    List<Map<String, String>> options = new List<Map<String, String>>();
    for (Shelter__c s : [SELECT Id, Name FROM Shelter__c ORDER BY Name]) {
      options.add(
        new Map<String, String>{ 'label' => s.Name, 'value' => s.Id }
      );
    }
    return options;
  }

  @AuraEnabled(cacheable=true)
  public static List<Map<String, String>> getBreedOptions() {
    List<Map<String, String>> options = new List<Map<String, String>>();
    for (AggregateResult ar : [
      SELECT Breed__c
      FROM Animal__c
      WHERE Breed__c != NULL
      GROUP BY Breed__c
      ORDER BY Breed__c
    ]) {
      String breed = (String) ar.get('Breed__c');
      options.add(
        new Map<String, String>{ 'label' => breed, 'value' => breed }
      );
    }
    return options;
  }

  @AuraEnabled(cacheable=true)
  public static List<Animal__c> searchAnimals(
    String shelterId,
    String breed,
    Decimal ageFrom,
    Decimal ageTo,
    String gender,
    Integer pageSize,
    Integer pageNumber
  ) {
    Integer offset = (pageNumber - 1) * pageSize;
    String query = 'SELECT Id, Name, Breed__c, Age__c, Weight__c, Sex__c, Photo__c, Shelter__r.Address__City__s, Shelter__r.Address__StateCode__s FROM Animal__c WHERE Status__c = \'Available\' ';

    if (String.isNotBlank(shelterId)) {
      query += 'AND Shelter__c = :shelterId ';
    }
    if (String.isNotBlank(breed)) {
      query += 'AND Breed__c = :breed ';
    }
    if (String.isNotBlank(gender)) {
      query += 'AND Sex__c = :gender ';
    }

    if (ageFrom != null) {
      query += 'AND Age__c >= :ageFrom ';
    }
    if (ageTo != null) {
      query += 'AND Age__c <= :ageTo ';
    }

    query += 'ORDER BY Name ASC LIMIT :pageSize OFFSET :offset';

    return Database.query(query);
  }
}