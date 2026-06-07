public with sharing class AnimalShelterCountTriggerHandler {
  public void afterInsert(List<Animal__c> newRecords) {
    ShelterCountHelper.recalculate(
      collectShelterIds(newRecords),
      new Set<Id>()
    );
  }

  public void afterUpdate(
    List<Animal__c> newRecords,
    List<Animal__c> oldRecords
  ) {
    Set<Id> shelterIds = collectShelterIds(newRecords);
    shelterIds.addAll(collectShelterIds(oldRecords));
    ShelterCountHelper.recalculate(shelterIds, new Set<Id>());
  }

  public void beforeDelete(List<Animal__c> oldRecords) {
    Set<Id> shelterIds = new Set<Id>();
    Set<Id> excludeAnimalIds = new Set<Id>();
    for (Animal__c animal : oldRecords) {
      if (animal.Shelter__c != null) {
        shelterIds.add(animal.Shelter__c);
        excludeAnimalIds.add(animal.Id);
      }
    }
    ShelterCountHelper.recalculate(shelterIds, excludeAnimalIds);
  }

  private Set<Id> collectShelterIds(List<Animal__c> records) {
    Set<Id> ids = new Set<Id>();
    for (Animal__c animal : records) {
      if (animal.Shelter__c != null)
        ids.add(animal.Shelter__c);
    }
    return ids;
  }
}
