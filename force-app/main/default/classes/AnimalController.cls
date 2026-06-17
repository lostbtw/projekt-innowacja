public with sharing class AnimalController {

    private static final String NAMED_CREDENTIAL = 'callout:MissingAnimals';
    private static final String API_PATH = '/services/apexrest/MissingAnimals';
    public class AnimalResponseWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String missingDate;
        @AuraEnabled public String imageUrl;
    }

    public class MissingAnimalRequest {
        @AuraEnabled public MissingAnimalWrapper missingAnimalWrapper;
    }

    public class MissingAnimalWrapper {
        @AuraEnabled public ReportWrapper report;
        @AuraEnabled public AnimalDataWrapper animal;
    }

    public class ReportWrapper {
        @AuraEnabled public String address;
        @AuraEnabled public Decimal disappearancePlaceLongitude;
        @AuraEnabled public Decimal disappearancePlaceLatitude;
        @AuraEnabled public String disappearanceDate;
        @AuraEnabled public String description;
    }

    public class AnimalDataWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String breed;
        @AuraEnabled public Integer age;
        @AuraEnabled public String uniqueFeatures;
        @AuraEnabled public String size;
    }

    public class UpdateStatusRequest {
        @AuraEnabled public String animalId;
        @AuraEnabled public Boolean found;
    }

    @AuraEnabled
    public static List<AnimalResponseWrapper> getAnimalsWithImages(Integer dayDelta) {
        List<AnimalResponseWrapper> animals = new List<AnimalResponseWrapper>();
        
        String endpoint = NAMED_CREDENTIAL + API_PATH;
        if (dayDelta != null) {
            endpoint += '?dayDelta=' + dayDelta;
        }

        HttpRequest listReq = new HttpRequest();
        listReq.setEndpoint(endpoint);
        listReq.setMethod('GET');
        listReq.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse listRes = http.send(listReq);

        if (listRes.getStatusCode() != 200) {
            throw new AuraHandledException('Error fetching animals: ' + listRes.getStatusCode() + ' ' + listRes.getBody());
        }

        List<Object> animalList = (List<Object>) JSON.deserializeUntyped(listRes.getBody());

        for (Object obj : animalList) {
            Map<String, Object> animalMap = (Map<String, Object>) obj;

            AnimalResponseWrapper wrapper = new AnimalResponseWrapper();
            wrapper.id = (String) animalMap.get('id');
            wrapper.name = (String) animalMap.get('name');
            wrapper.missingDate = (String) animalMap.get('missingDate');
            
            try {
                String detailEndpoint = NAMED_CREDENTIAL + API_PATH + '/' + wrapper.id;
                HttpRequest detailReq = new HttpRequest();
                detailReq.setEndpoint(detailEndpoint);
                detailReq.setMethod('GET');
                detailReq.setHeader('Content-Type', 'application/json');

                HttpResponse detailRes = http.send(detailReq);

                if (detailRes.getStatusCode() == 200) {
                    Map<String, Object> detailMap = (Map<String, Object>) JSON.deserializeUntyped(detailRes.getBody());
                    wrapper.imageUrl = (String) detailMap.get('imageUrl');
                } else {
                    wrapper.imageUrl = null;
                }
            } catch (Exception e) {
                System.debug('Error fetching details for ' + wrapper.id + ': ' + e.getMessage());
            }
            animals.add(wrapper);
        }
        return animals;
    }

    @AuraEnabled
    public static String postMissingAnimal(MissingAnimalRequest requestBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + API_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        String jsonBody = JSON.serialize(requestBody);
        req.setBody(jsonBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
            throw new AuraHandledException('Error posting missing animal: ' + res.getStatusCode() + ' ' + res.getBody());
        }
        
        return res.getBody();
    }
    
    @AuraEnabled
    public static String updateFoundStatus(String animalId, Boolean found) {
        UpdateStatusRequest updateReq = new UpdateStatusRequest();
        updateReq.animalId = animalId;
        updateReq.found = found;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + API_PATH);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(updateReq));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200 && res.getStatusCode() != 204) {
            throw new AuraHandledException('Error updating status: ' + res.getStatusCode() + ' ' + res.getBody());
        }

        return res.getBody();
    }
}