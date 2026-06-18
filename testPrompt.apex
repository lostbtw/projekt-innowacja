RejectAdoptionAgentforceService.RejectAdoptionRequest req = new RejectAdoptionAgentforceService.RejectAdoptionRequest();
req.animalName = 'sxf'; 

List<RejectAdoptionAgentforceService.RejectAdoptionRequest> reqList = new List<RejectAdoptionAgentforceService.RejectAdoptionRequest>{req};

List<RejectAdoptionAgentforceService.AdoptionResponse> results = RejectAdoptionAgentforceService.rejectAdoption(reqList);

System.debug('Result: ' + results[0].isSuccess);
System.debug('Message: ' + results[0].message);
