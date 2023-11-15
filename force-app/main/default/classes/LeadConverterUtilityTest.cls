@isTest(SeeAllData=true)
public class LeadConverterUtilityTest {
    
    @isTest static void testMethod1() {
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
        
        List<Account> accounts = new List<Account>();
        for(Integer i=0; i < 3; i++) {
            accounts.add(new Account(
                Name = 'WWC Truckers ' + i
            ));
        }
        insert accounts;
        
        List<Account> accountList = [SELECT Id FROM Account WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 5];
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i < 3; i++) {
            contacts.add(new Contact(
                FirstName = 'Testing', 
                LastName = 'Con ' + i, 
                Title = 'Testing Dev', 
                Email = 'testingneilsquire' + i + '@mailinator.com',
                Phone = '200-000-000' + i,
                AccountId = accountList[i].Id
            ));
        }
        insert contacts; 
        
        List<Id> leadIds = new List<Id>();
        
        for(Lead ld : [SELECT Id, Status FROM Lead WHERE CreatedDate = TODAY AND IsConverted = false ORDER BY CreatedDate DESC LIMIT 5]) {
            leadIds.add(ld.Id);
        }
        
        Test.startTest();
        LeadConverterUtility.convertLeads(leadIds);
        LeadConverterBatch obj = new LeadConverterBatch('SELECT Id, Status FROM Lead WHERE CreatedDate = TODAY AND IsConverted = false ORDER BY CreatedDate DESC LIMIT 5');
        Database.executeBatch(obj);
        Test.stopTest();
    }
    
    
}