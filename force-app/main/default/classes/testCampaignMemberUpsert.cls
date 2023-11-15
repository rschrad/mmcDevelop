@isTest
private class testCampaignMemberUpsert {
 
 static testMethod void testInsert() {
 
    Contact maker1 = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast',Email = 'xyzmail@mail.com');
    insert maker1;
    
    Campaign campaign1 = new Campaign(Name='test');
    insert campaign1;
    
    Assistive_Technology_Project__c project1 = new Assistive_Technology_Project__c(Name='project1');
    insert project1;
    
    Assistive_Technology_Project__c project2 = new Assistive_Technology_Project__c(Name='project2');
    insert project2;
    
    
    Assistive_Technology_RequestDelivery__c build1 = new Assistive_Technology_RequestDelivery__c  (Name='build1', Primary_Maker_Contact__c =maker1.id, Assistive_Technology_Project__c = project1.id, Created_At_Campaign__c = campaign1.id);
    insert build1;

    Assistive_Technology_RequestDelivery__c build2 = new Assistive_Technology_RequestDelivery__c  (Name='build2', Primary_Maker_Contact__c =maker1.id, Assistive_Technology_Project__c = project2.id, Created_At_Campaign__c = campaign1.id);
    insert build2;    
    
    Test.startTest();
    CampaignMember cm1 = [SELECT Id FROM CampaignMember WHERE ContactId =:maker1.id AND CampaignID = :campaign1.Id];
    Test.stopTest();
    
    system.assert(cm1.id != null,'didnt insert campaign member!');
  }  
    
}