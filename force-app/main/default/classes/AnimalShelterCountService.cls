public with sharing class AnimalShelterCountService {
  public static void recalculateOnInsert(List<Animal__c> newList) {
    ShelterCountHelper.recalculate(collectShelterIds(newList), new Set<Id>());
  }

  public static void recalculateOnUpdate(
    List<Animal__c> newList,
    List<Animal__c> oldList
  ) {
    Set<Id> shelterIds = collectShelterIds(newList);
    shelterIds.addAll(collectShelterIds(oldList));
    ShelterCountHelper.recalculate(shelterIds, new Set<Id>());
  }

  public static void recalculateOnDelete(List<Animal__c> oldList) {
    Set<Id> shelterIds = new Set<Id>();
    Set<Id> excludeAnimalIds = new Set<Id>();
    for (Animal__c animal : oldList) {
      if (animal.Shelter__c != null) {
        shelterIds.add(animal.Shelter__c);
        excludeAnimalIds.add(animal.Id);
      }
    }
    ShelterCountHelper.recalculate(shelterIds, excludeAnimalIds);
  }

  private static Set<Id> collectShelterIds(List<Animal__c> records) {
    Set<Id> ids = new Set<Id>();
    for (Animal__c animal : records) {
      if (animal.Shelter__c != null)
        ids.add(animal.Shelter__c);
    }
    return ids;
  }
}