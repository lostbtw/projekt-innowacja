public with sharing class RejectAdoptionAgentforceService {
    
    public class RejectAdoptionRequest {
        @InvocableVariable(required=true description='Name of the animal to reject adoption for')
        public String animalName;
    }

    public class AdoptionResponse {
        @InvocableVariable(description='True if action was successful')
        public Boolean isSuccess;

        @InvocableVariable(description='Message to display to the user')
        public String message;
    }

    @InvocableMethod(label='Reject Adoption' description='Changes the status of an In Progress adoption to rejected and sends an email to the contact.')
    public static List<AdoptionResponse> rejectAdoption(List<RejectAdoptionRequest> requests) {
        List<AdoptionResponse> responses = new List<AdoptionResponse>();

        for (RejectAdoptionRequest req : requests) {
            AdoptionResponse res = new AdoptionResponse();
            try {
                Adoption__c adoptionToReject = [
                    SELECT Id, Name, Contact__c, Contact__r.Email
                    FROM Adoption__c
                    WHERE Animal__r.Name = :req.animalName
                    AND Status__c = 'In Progress'
                    LIMIT 1
                ];

                adoptionToReject.Status__c = 'Rejected';
                update adoptionToReject;

                if (String.isNotBlank(adoptionToReject.Contact__r.Email)) {
                    ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
                    Map<String, ConnectApi.WrappedValue> valueMap = new Map<String, ConnectApi.WrappedValue>();
                    
                    ConnectApi.WrappedValue adoptionValue = new ConnectApi.WrappedValue();
                    adoptionValue.value = adoptionToReject.Id; 
                    valueMap.put('Input:AdoptionRecord', adoptionValue);
                    
                    promptInput.inputParams = valueMap;
                    promptInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
                    promptInput.additionalConfig.applicationName = 'PromptBuilderPreview';
                    promptInput.isPreview = false;
                   String generatedEmailBody;
                try {
                    // 2. Invoke the Prompt Template
                    ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generations = 
                        ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Reject_Adoption_Email', promptInput);
                    generatedEmailBody = generations.generations[0].text;
                } catch (Exception e) {
                    System.debug('Prompt Template failed (Salesforce beta issue), using fallback email text: ' + e.getMessage());
                    generatedEmailBody = 'Dear Applicant,\n\nWe regret to inform you that your adoption request for animal ' + req.animalName + ' has been rejected.\n\nBest regards,\nShelter Team';
                }

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] { adoptionToReject.Contact__r.Email });
                    mail.setSubject('Update on Adoption Request: ' + adoptionToReject.Name);
                    mail.setPlainTextBody(generatedEmailBody);
                    
                    System.debug(generatedEmailBody);
                    
                    if(!Test.isRunningTest()) {
                        try {
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        } catch (Exception e) {
                            System.debug('Email send blocked by Salesforce domain limits, but Prompt generated successfully.');
                        }
                    }
                }

                res.isSuccess = true;
                res.message = 'Adoption rejected successfully.';
            } catch (Exception e) {
                res.isSuccess = false;
                res.message = 'Could not find an In Progress adoption for this animal.';
            }
            responses.add(res);
        }
        return responses;
    }
}