public class ShelterCountHelper {
    public static Boolean isCalculating = false;

    public static void recalculate(Set<Id> shelterIds, Set<Id> excludeAnimalIds) {
        if (shelterIds.isEmpty()) return;

        Map<Id, Integer> totalAnimals = new Map<Id, Integer>();
        Map<Id, Integer> virtualAdoptedPerShelter = new Map<Id, Integer>();
        Map<Id, Integer> totalAdoptionsPerShelter = new Map<Id, Integer>();

        for (Id shelterId : shelterIds) {
            totalAnimals.put(shelterId, 0);
            virtualAdoptedPerShelter.put(shelterId, 0);
            totalAdoptionsPerShelter.put(shelterId, 0);
        }

        if (excludeAnimalIds.isEmpty()) {
            for (AggregateResult ar : [
                SELECT Shelter__c shelterId, COUNT(Id) cnt
                FROM Animal__c
                WHERE Shelter__c IN :shelterIds
                GROUP BY Shelter__c
            ]) {
                totalAnimals.put((Id) ar.get('shelterId'), (Integer) ar.get('cnt'));
            }

            for (AggregateResult ar : [
                SELECT Animal__r.Shelter__c shelterId, COUNT_DISTINCT(Animal__c) cnt
                FROM Adoption__c
                WHERE Animal__r.Shelter__c IN :shelterIds
                AND RecordType.DeveloperName = 'Virtual'
                GROUP BY Animal__r.Shelter__c
            ]) {
                virtualAdoptedPerShelter.put((Id) ar.get('shelterId'), (Integer) ar.get('cnt'));
            }

            for (AggregateResult ar : [
                SELECT Animal__r.Shelter__c shelterId, COUNT(Id) cnt
                FROM Adoption__c
                WHERE Animal__r.Shelter__c IN :shelterIds
                GROUP BY Animal__r.Shelter__c
            ]) {
                totalAdoptionsPerShelter.put((Id) ar.get('shelterId'), (Integer) ar.get('cnt'));
            }
        } else {
            for (AggregateResult ar : [
                SELECT Shelter__c shelterId, COUNT(Id) cnt
                FROM Animal__c
                WHERE Shelter__c IN :shelterIds AND Id NOT IN :excludeAnimalIds
                GROUP BY Shelter__c
            ]) {
                totalAnimals.put((Id) ar.get('shelterId'), (Integer) ar.get('cnt'));
            }

            for (AggregateResult ar : [
                SELECT Animal__r.Shelter__c shelterId, COUNT_DISTINCT(Animal__c) cnt
                FROM Adoption__c
                WHERE Animal__r.Shelter__c IN :shelterIds
                AND Animal__c NOT IN :excludeAnimalIds
                AND RecordType.DeveloperName = 'Virtual'
                GROUP BY Animal__r.Shelter__c
            ]) {
                virtualAdoptedPerShelter.put((Id) ar.get('shelterId'), (Integer) ar.get('cnt'));
            }

            for (AggregateResult ar : [
                SELECT Animal__r.Shelter__c shelterId, COUNT(Id) cnt
                FROM Adoption__c
                WHERE Animal__r.Shelter__c IN :shelterIds AND Animal__c NOT IN :excludeAnimalIds
                GROUP BY Animal__r.Shelter__c
            ]) {
                totalAdoptionsPerShelter.put((Id) ar.get('shelterId'), (Integer) ar.get('cnt'));
            }
        }

        List<Shelter__c> toUpdate = new List<Shelter__c>();
        for (Id shelterId : shelterIds) {
            toUpdate.add(new Shelter__c(
                Id = shelterId,
                Non_Virtual_Adopted_Animals__c = totalAnimals.get(shelterId) - virtualAdoptedPerShelter.get(shelterId),
                Total_Adoptions__c = totalAdoptionsPerShelter.get(shelterId)
            ));
        }
        isCalculating = true;
        try {
            update toUpdate;
        } finally {
            isCalculating = false;
        }
    }
}