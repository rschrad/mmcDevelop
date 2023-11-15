@isTest(SeeAllData=false)
public class JunkLeadHandlerTest {

    @testSetup static void setup() {
        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i < 5; i++) {
            leads.add(new Lead(
                FirstName = 'Testing', 
                LastName = 'Lead ' + i,
                Email = 'testingneilsquire' + i + '@mailinator.com',
                Company = 'LLC Truckers',
                Phone = '200-000-000' + i, 
                Street = '10' + i + ' King St.',
                City = 'LANWAN',
                State = 'ON', 
                PostalCode = '100001'
            ));
        }
        insert leads;
    }
    
    @isTest static void testMethod1() {
        List<Id> ids = new List<Id>();
        
        for(Lead ld : [SELECT Id FROM Lead]) {
            ids.add(ld.Id);
        }
        
        Test.startTest();
        JunkLeadHandler.deleteJunkLeads(ids);
        Test.stopTest();
        
        // All Leads are deleted
        System.assertEquals(0, [SELECT Count() FROM Lead]);
    }
        
}