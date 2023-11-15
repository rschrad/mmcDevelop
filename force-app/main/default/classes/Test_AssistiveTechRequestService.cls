@isTest(SeeAllData=false)
public class Test_AssistiveTechRequestService {
    
    @testSetup static void setUpTestData() {
        
        Contact cont = new Contact();
        cont.FirstName = 'Testing';
        cont.LastName = 'Contact';
        cont.Email = 'testing_contact@fic.com';
        insert cont;
        
        Assistive_Technology_Project__c ATProject = new Assistive_Technology_Project__c();
        ATProject.Build_hrs__c = 10;
        ATProject.Date_Complete__c = System.today() + 5;
        ATProject.MMC_ID__c = '999B';
        ATProject.Name = 'Test AT Project';
        insert ATProject;
        
        Assistive_Technology_RequestDelivery__c ATRD = new Assistive_Technology_RequestDelivery__c();
        ATRD.Request_Date__c = Date.valueOf(String.valueOf('2021-10-01T00:00:00Z'));
        ATRD.Name = 'Testing Project';
        ATRD.MMC_Portal_Entry_ID__c = '999B';
        ATRD.Stage__c = 'Building Device';
        ATRD.Technology_User__c = cont.Id;
        ATRD.Assistive_Technology_Project__c = ATProject.Id;
        insert ATRD;
    }
    
    static testMethod void testPositiveCreateRequest() {
        // Initiate Request Variables
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/AssistiveTechnologyRequestDelivery/';
        req.httpMethod = 'POST';
        req.addParameter('opt', 'Create');
        req.requestBody = Blob.valueOf('{ "Email": "tesitngwoprojectfic@mailinator.com", "MailingStreetAddress": "500 Marshville Road", "MailingCity": "MILLS GATE", "MailingState": "NY", "MailingCountry": "USA", "MMC_Portal_Entry_ID": "999C", "Full_Name": "ATRD Test 07", "Stage": "Building Device", "Request_Date" : "2021-10-01T00:00:00Z", "Project_Name" : "" }');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AssistiveTechRequestService.AssistiveTechRequestResponse ATRResp = AssistiveTechRequestService.handleUpsertRequest();
        Test.stopTest(); 
        
        System.assertEquals(true, ATRResp.success);
    }
    
    static testMethod void testNegativeCreateRequest() {
        // Initiate Request Variables
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/AssistiveTechnologyRequestDelivery/';
        req.httpMethod = 'POST';
        req.addParameter('opt', 'Create');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AssistiveTechRequestService.AssistiveTechRequestResponse ATRResp = AssistiveTechRequestService.handleUpsertRequest();
        Test.stopTest(); 
        
        System.assertEquals(false, ATRResp.success);
    }
    
    static testMethod void testPositiveUpdateRequest() {
        // Initiate Request Variables
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/AssistiveTechnologyRequestDelivery/';
        req.httpMethod = 'POST';
        req.addParameter('opt', 'Update');
        req.requestBody = Blob.valueOf('{ "MMC_Portal_Entry_ID": "999B", "Stage": "Scrapped" }');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AssistiveTechRequestService.AssistiveTechRequestResponse ATRResp = AssistiveTechRequestService.handleUpsertRequest();
        Test.stopTest(); 
        
        System.assertEquals(true, ATRResp.success);
    }
    
    static testMethod void testNegativeUpdateRequest() {
        // Initiate Request Variables
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/AssistiveTechnologyRequestDelivery/';
        req.httpMethod = 'POST';
        req.addParameter('opt', 'Update');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AssistiveTechRequestService.AssistiveTechRequestResponse ATRResp = AssistiveTechRequestService.handleUpsertRequest();
        Test.stopTest(); 
        
        System.assertEquals(false, ATRResp.success);
    }
    
}