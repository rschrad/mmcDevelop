@isTest(SeeAllData=false)
public class Test_AssistiveTechRequestController {

    @testSetup static void setUpTestData() {
        Contact cont = new Contact();
        cont.FirstName = 'Testing';
        cont.LastName = 'Contact';
        cont.Email = 'testing_contact@fic.com';
        insert cont;
        
        Assistive_Technology_Project__c ATProject = new Assistive_Technology_Project__c();
        ATProject.Build_hrs__c = 10;
        ATProject.Date_Complete__c = System.today() + 5;
        ATProject.MMC_ID__c = '9981';
        ATProject.Name = 'Test AT Project';
        insert ATProject;
        
        List<Assistive_Technology_RequestDelivery__c> ATRDeliveries = new List<Assistive_Technology_RequestDelivery__c>();
        
        for(Integer i = 0; i < 10; i++) {
            Assistive_Technology_RequestDelivery__c ATRD = new Assistive_Technology_RequestDelivery__c();
            ATRD.Request_Date__c = Date.valueOf(String.valueOf('2021-10-01T00:00:00Z'));
            ATRD.Name = 'Testing Project ' + i;
            ATRD.MMC_Portal_Entry_ID__c = '999' + i;
            ATRD.Stage__c = 'Maker Wanted';
            ATRD.Technology_User__c = cont.Id;
            ATRD.Assistive_Technology_Project__c = ATProject.Id;
            ATRDeliveries.add(ATRD);
        }
        
        insert ATRDeliveries;
    }
    
    static testMethod void testWPCalloutRequest() {
        
        String endpoint = 'https://makersmakingchange2-nexcess.developmentwebsite.ca';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(endpoint + '/wp-json/AssistiveTechnologyRequest/v2', 
                                                                          'POST', 
                                                                          '{ "token": "eyJ0eXAiOiJKV1QiLCJ", "user_email": "testingcall@speaking.ca", "user_nicename": "Tester", "user_display_name": "Test User" }', 
                                                                          'application/json', 200));
        
        Wordpress_Config__mdt WPConfig = Wordpress_Config__mdt.getInstance('WP_Config');
        
        Test.startTest();
        ATRD_WPCallout WPCallout = new ATRD_WPCallout(null);
        String accessToken = WPCallout.WP_AuthenticationRequest();
        Test.stopTest();
        
        System.assertEquals('eyJ0eXAiOiJKV1QiLCJ', accessToken);
    }
    
    static testMethod void testStageUpdateRequest() {
        
        List<AssistiveTechRequestController.WP_Request> requests = new List<AssistiveTechRequestController.WP_Request>();
        
        for(Assistive_Technology_RequestDelivery__c ATRD : [SELECT Id, Name, User_Email__c, MMC_Portal_Entry_ID__c, Stage__c 
                                                            FROM Assistive_Technology_RequestDelivery__c])
        {
            AssistiveTechRequestController.WP_Request request = new AssistiveTechRequestController.WP_Request();
            request.email = ATRD.User_Email__c;
            request.recordId = ATRD.Id;
            request.stage = ATRD.Stage__c;
            request.id = ATRD.MMC_Portal_Entry_ID__c;
            requests.add(request);
        }
        
        String endpoint = 'https://makersmakingchange2-nexcess.developmentwebsite.ca';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(endpoint + '/wp-json/AssistiveTechnologyRequest/v2', 
                                                                          'POST', 
                                                                          '{ "code": "jwt_auth_invalid_token", "message": "Expired token", "data": { "status": 403 } }', 
                                                                          'application/json', 200));
        
        Test.startTest();
        AssistiveTechRequestController.handleRecordChange(requests);
        Test.stopTest();
        
        List<Assistive_Technology_RequestDelivery__c> ATRDs = [SELECT Id, WP_Request_Logs__c 
                                                               FROM Assistive_Technology_RequestDelivery__c];
        
        for(Assistive_Technology_RequestDelivery__c ATRD : ATRDs) {
            System.assertEquals('{ "code": "jwt_auth_invalid_token", "message": "Expired token", "data": { "status": 403 } }', 
                                ATRD.WP_Request_Logs__c);
        }
        
    }
    
}