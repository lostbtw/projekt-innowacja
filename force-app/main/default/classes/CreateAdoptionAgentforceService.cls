public with sharing class CreateAdoptionAgentforceService {
    
    public class CreateAdoptionRequest {
        @InvocableVariable(required=true description='Name of the animal to adopt') 
        public String animalName;
    
        @InvocableVariable(required=true description='Full name of the contact')
        public String contactName;
    }

    public class AdoptionResponse {
        @InvocableVariable(description='True if action was successful')
        public Boolean isSuccess;

        @InvocableVariable(description='Message to display to the user')
        public String message;
    }

    @InvocableMethod(label='Create New Adoption' description='Creates a new Adoption record. Do NOT use if animal is already in progress.')
    public static List<AdoptionResponse> createAdoption(List<CreateAdoptionRequest> requests) {
        List<AdoptionResponse> responses = new List<AdoptionResponse>();
        
        for (CreateAdoptionRequest req : requests) {
            AdoptionResponse res = new AdoptionResponse();
            try {
                Animal__c animal = [SELECT Id, Name FROM Animal__c WHERE Name = :req.animalName LIMIT 1];
                
                List<Adoption__c> existingAdoptions = [
                    SELECT Id FROM Adoption__c 
                    WHERE Animal__c = :animal.Id 
                    AND Status__c IN ('In Progress', 'Approved')
                ];
                
                if (!existingAdoptions.isEmpty()) {
                    res.isSuccess = false;
                    res.message = 'The selected animal is already in another adoption process.';
                } else {
                    Contact con = [SELECT Id FROM Contact WHERE Name = :req.contactName LIMIT 1];
                    
                    Integer adoptionCount = [SELECT COUNT() FROM Adoption__c] + 1;
                    
                    Adoption__c newAdoption = new Adoption__c(
                        Name = 'Adopcja ' + adoptionCount,
                        Animal__c = animal.Id,
                        Contact__c = con.Id,
                        Status__c = 'In Progress'
                    );
                    insert newAdoption;
                    
                    res.isSuccess = true;
                    res.message = 'Adoption successfully created for ' + animal.Name;
                }
            } catch (Exception e) {
                res.isSuccess = false;
                res.message = 'Error: ' + e.getMessage();
            }
            responses.add(res);
        }
        return responses;
    }
}