@IsTest
public class UserTriggerTest {
    private static final String COMMUITY_USER_EMAIL_1 = 'first.user.email@mail.com';
    @TestSetup
    static void makeData() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }

        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        Contact contact = cf.getContact('Test1', COMMUITY_USER_EMAIL_1);
        contact.Email = COMMUITY_USER_EMAIL_1;
        contact.MailingCountry = 'Canada';
        contact.MailingStreet = '1820 East Pender Street';
        contact.MailingCity = 'Vancouver';
        contact.MailingState = 'British Columbia';
        contact.MailingPostalCode = 'V5L 1W7';
        contact.MailingCountryCode = 'CA';
        contact.MailingStateCode = 'BC';
        contact.Portal_Roles__c = 'Maker';
        NLSQTestUtils.insertRecords(new List<Contact>{ contact });

        NLSQTestUtils.CommunityUserFactory uf = new NLSQTestUtils.CommunityUserFactory();
        User testCommunityUser = uf.getUser(contact);
        testCommunityUser.Country = contact.MailingCountry;
        testCommunityUser.Street = contact.MailingStreet;
        testCommunityUser.City = contact.MailingCity;
        testCommunityUser.State = contact.MailingState;
        testCommunityUser.PostalCode = contact.MailingPostalCode;
        testCommunityUser.StateCode = contact.MailingStateCode;
        testCommunityUser.CountryCode = contact.MailingCountryCode;
        testCommunityUser.Portal_Roles__c = contact.Portal_Roles__c;
        NLSQTestUtils.insertRecords(new List<User>{ testCommunityUser });
    }

    @IsTest
    static void testValidateExistUserAndContact() {
        Test.startTest();
        User testUser = [
            SELECT
                Id,
                FirstName,
                LastName,
                Email,
                Country,
                Street,
                City,
                State,
                PostalCode,
                ContactId,
                StateCode,
                CountryCode,
                Portal_Roles__c
            FROM USER
            WHERE EMAIL = :COMMUITY_USER_EMAIL_1
        ];
        Contact con = [
            SELECT
                Id,
                FirstName,
                LastName,
                Email,
                MailingCountry,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountryCode,
                MailingStateCode,
                Portal_Roles__c
            FROM Contact
            WHERE Id = :testUser.ContactId
        ];
        Test.stopTest();
        System.assertEquals('Contact', testUser.FirstName, 'The FirstName is wrong');
        System.assertEquals('Test1', testUser.LastName, 'The LastName is wrong');
        System.assertEquals('first.user.email@mail.com', testUser.Email, 'The Email is wrong');
        System.assertEquals('Canada', testUser.Country, 'The Country is wrong');
        System.assertEquals('1820 East Pender Street', testUser.Street, 'The Street is wrong');
        System.assertEquals('Vancouver', testUser.City, 'The City is wrong');
        System.assertEquals('British Columbia', testUser.State, 'The State is wrong');
        System.assertEquals('V5L 1W7', testUser.PostalCode, 'The PostalCode is wrong');
        System.assertEquals('BC', testUser.StateCode, 'The StateCode is wrong');
        System.assertEquals('CA', testUser.CountryCode, 'The CountryCode is wrong');
        System.assertEquals('Maker', testUser.Portal_Roles__c, 'The Portal_Roles__c is wrong');

        System.assertEquals('Contact', con.FirstName, 'The FirstName is wrong');
        System.assertEquals('Test1', con.LastName, 'The LastName is wrong');
        System.assertEquals('first.user.email@mail.com', con.Email, 'The Email is wrong');
        System.assertEquals('Canada', con.MailingCountry, 'The MailingCountry is wrong');
        System.assertEquals('1820 East Pender Street', con.MailingStreet, 'The MailingStreet is wrong');
        System.assertEquals('Vancouver', con.MailingCity, 'The MailingCity is wrong');
        System.assertEquals('British Columbia', con.MailingState, 'The MailingState is wrong');
        System.assertEquals('V5L 1W7', con.MailingPostalCode, 'The MailingPostalCode is wrong');
        System.assertEquals('BC', con.MailingStateCode, 'The MailingStateCode is wrong');
        System.assertEquals('CA', con.MailingCountryCode, 'The MailingCountryCode is wrong');
        System.assertEquals('Maker', con.Portal_Roles__c, 'The Portal_Roles__c is wrong');
    }

    @IsTest
    static void testUpdateUserAndContactRecord() {
        User testUser = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_1];
        Test.startTest();
        System.runAs(testUser) {
            testUser.FirstName = 'Gen';
            testUser.LastName = 'Tester';
            testUser.Email = 'gen.tester.email@mail.com';
            testUser.Country = 'Italy';
            testUser.Street = '1821 Pender Street';
            testUser.City = 'Florence';
            testUser.State = '';
            testUser.PostalCode = '50100';
            testUser.StateCode = '';
            testUser.CountryCode = 'IT';
            testUser.Portal_Roles__c = 'Teacher';
            update testUser;
        }
        Test.stopTest();
        User userAfterUpdate = [
            SELECT
                Id,
                FirstName,
                LastName,
                Email,
                Country,
                Street,
                City,
                State,
                PostalCode,
                ContactId,
                StateCode,
                CountryCode,
                Portal_Roles__c
            FROM USER
            WHERE EMAIL = 'gen.tester.email@mail.com'
        ];
        Contact conAfterUpdate = [
            SELECT
                Id,
                FirstName,
                LastName,
                Email,
                MailingCountry,
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountryCode,
                MailingStateCode,
                Portal_Roles__c
            FROM Contact
            WHERE Id = :userAfterUpdate.ContactId
        ];
        System.assertEquals('Gen', userAfterUpdate.FirstName, 'The FirstName is wrong');
        System.assertEquals('Tester', userAfterUpdate.LastName, 'The LastName is wrong');
        System.assertEquals('gen.tester.email@mail.com', userAfterUpdate.Email, 'The Email is wrong');
        System.assertEquals('Italy', userAfterUpdate.Country, 'The Country is wrong');
        System.assertEquals('1821 Pender Street', userAfterUpdate.Street, 'The Street is wrong');
        System.assertEquals('Florence', userAfterUpdate.City, 'The City is wrong');
        System.assertEquals(null, userAfterUpdate.State, 'The State is wrong');
        System.assertEquals('50100', userAfterUpdate.PostalCode, 'The PostalCode is wrong');
        System.assertEquals(null, userAfterUpdate.StateCode, 'The StateCode is wrong');
        System.assertEquals('IT', userAfterUpdate.CountryCode, 'The CountryCode is wrong');
        System.assertEquals('Teacher', userAfterUpdate.Portal_Roles__c, 'The Portal_Roles__c is wrong');

        System.assertEquals('Gen', conAfterUpdate.FirstName, 'The FirstName is wrong');
        System.assertEquals('Tester', conAfterUpdate.LastName, 'The LastName is wrong');
        System.assertEquals('gen.tester.email@mail.com', conAfterUpdate.Email, 'The Email is wrong');
        System.assertEquals('Italy', conAfterUpdate.MailingCountry, 'The MailingCountry is wrong');
        System.assertEquals('1821 Pender Street', conAfterUpdate.MailingStreet, 'The MailingStreet is wrong');
        System.assertEquals('Florence', conAfterUpdate.MailingCity, 'The MailingCity is wrong');
        System.assertEquals(null, conAfterUpdate.MailingState, 'The MailingState is wrong');
        System.assertEquals('50100', conAfterUpdate.MailingPostalCode, 'The MailingPostalCode is wrong');
        System.assertEquals(null, conAfterUpdate.MailingStateCode, 'The MailingStateCode is wrong');
        System.assertEquals('IT', conAfterUpdate.MailingCountryCode, 'The MailingCountryCode is wrong');
        System.assertEquals('Teacher', conAfterUpdate.Portal_Roles__c, 'The Portal_Roles__c is wrong');
    }
}