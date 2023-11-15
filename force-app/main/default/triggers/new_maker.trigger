trigger new_maker on Maker__c (after insert) {

    List<CampaignMember> members = new List<CampaignMember>();
    List<Maker__c> these_makers = [SELECT Id, Assistive_Technology_Request_Delivery__r.Created_At_Campaign__c, Contact__c FROM Maker__c WHERE ID IN : trigger.new];

    for (Maker__c this_maker : these_makers){
         if (this_Maker.Assistive_Technology_Request_Delivery__r.Created_At_Campaign__c != null){
        
            CampaignMember thisMember = new CampaignMember(CampaignId = this_Maker.Assistive_Technology_Request_Delivery__r.Created_At_Campaign__c
                                                            , ContactId= this_Maker.Contact__c);
            members.add(thisMember);   
         }
    }
    
    try {

    Database.insert(members);
         } catch (Exception ex) {
            System.Debug('Insert failed ' + ex);
         }
          


}