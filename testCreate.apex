CreateAdoptionAgentforceService.CreateAdoptionRequest req = new CreateAdoptionAgentforceService.CreateAdoptionRequest();

req.animalName = '132'; 

req.contactName = 'Test Testovich'; 

List<CreateAdoptionAgentforceService.CreateAdoptionRequest> reqList = new List<CreateAdoptionAgentforceService.CreateAdoptionRequest>{req};

List<CreateAdoptionAgentforceService.AdoptionResponse> results = CreateAdoptionAgentforceService.createAdoption(reqList);

System.debug('Result: ' + results[0].isSuccess);
System.debug('Message: ' + results[0].message);
