trigger ShelterFieldProtectionTrigger on Shelter__c(before update) {
    if (ShelterCountHelper.isCalculating) {
        return;
    }
    for (Shelter__c s : Trigger.new) {
        Shelter__c old = Trigger.oldMap.get(s.Id);
        if (s.Total_Adoptions__c != old.Total_Adoptions__c) {
            s.Total_Adoptions__c.addError('Total Adoptions is calculated automatically and cannot be modified manually.');
        }
        if (s.Non_Virtual_Adopted_Animals__c != old.Non_Virtual_Adopted_Animals__c) {
            s.Non_Virtual_Adopted_Animals__c.addError('Non-Virtual Adopted Animals is calculated automatically and cannot be modified manually.');
        }
    }
}