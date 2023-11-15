@IsTest
public class SelfRegisterCtrlTest {
    @IsTest
    static void registerUserSuccess() {
        User admin = new User(Id = UserInfo.getUserId());
        NLSQTestUtils.ContactFactory contactFactory = new NLSQTestUtils.ContactFactory();

        Contact currentContact = contactFactory.getContact('Test', 'usertest@gmail.com');
        currentContact.Portal_Roles__c = 'Maker';

        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());

        Test.startTest();

        System.runAs(admin) {
            SelfRegisterCtrl.registerUser(currentContact, 'success_response');
        }

        Test.stopTest();

        User u = [
            SELECT
                ContactId,
                AccountId,
                Account.Name,
                FirstName,
                LastName,
                Email,
                Username,
                CountryCode,
                Portal_Roles__c
            FROM User
            WHERE Username = :currentContact.Email
        ];

        String msgPrefix = NLSQTestUtils.RECORD_ASSERTION_MSG_PREFIX;
        System.assertEquals('Contact', u.FirstName, msgPrefix + '(Contact.FirstName)');
        System.assertEquals('Test', u.LastName, msgPrefix + '(Contact.LastName)');
        System.assertEquals('usertest@gmail.com', u.Email, msgPrefix + '(Contact.Email)');
        System.assertEquals('usertest@gmail.com', u.Username, msgPrefix + '(Contact.Email)');
        System.assertEquals('US', u.CountryCode, msgPrefix + '(Contact.CountryCode)');
        System.assertEquals('Maker', u.Portal_Roles__c, msgPrefix + '(Contact.Portal_Roles__c)');
        System.assertNotEquals(null, u.ContactId, 'Contact for this User should be created');
        System.assertNotEquals(null, u.AccountId, 'Account for this User should be created');

        Contact c = [
            SELECT AccountId, Email, Role_Is_Other__c, Role_Is_Chapter_Lead__c, FirstName, LastName
            FROM Contact
            WHERE Id = :u.ContactId
        ];

        System.assertEquals('Contact', c.FirstName, msgPrefix + '(Contact.FirstName)');
        System.assertEquals('Test', c.LastName, msgPrefix + '(Contact.LastName)');
        System.assertEquals('usertest@gmail.com', c.Email, msgPrefix + '(Contact.Email)');
        System.assertNotEquals(null, c.AccountId, 'Account for this Contact should be created');

        BuyerAccount bAccount = [SELECT Name FROM BuyerAccount WHERE BuyerId = :c.AccountId];

        System.assertEquals(u.Account.Name, bAccount.Name, 'BuyerAccount should be same with user Account Name');

        BuyerGroupMember bMember = [SELECT BuyerGroup.Name FROM BuyerGroupMember WHERE BuyerId = :c.AccountId];

        System.assertEquals(
            NLSQConstants.SETTING.Buyer_Group_Name__c,
            bMember.BuyerGroup.Name,
            'Should be bayer group for this member'
        );
    }

    @IsTest
    static void registerUserWithAlreadyCreatedContact() {
        User admin = new User(Id = UserInfo.getUserId());

        String email = 'usertest@gmail.com';
        String contactLastName = 'New Contact';

        NLSQTestUtils.ContactFactory contactFactory = new NLSQTestUtils.ContactFactory();

        Contact c = contactFactory.getContact('Test', email);
        System.runAs(admin) {
            insert c;
        }

        Contact currentContact = contactFactory.getContact(contactLastName, email);
        currentContact.Portal_Roles__c = 'Maker';

        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());

        Test.startTest();
        System.runAs(admin) {
            SelfRegisterCtrl.registerUser(currentContact, 'success_response');
        }

        Test.stopTest();

        Contact updatedContact = [
            SELECT LastName, Portal_Roles__c
            FROM Contact
            WHERE Id = :c.Id
        ];

        System.assertNotEquals(updatedContact.LastName, c.LastName, 'Contacts last names should not be equeal');
        System.assertEquals(
            contactLastName,
            updatedContact.LastName,
            'Contact last name should be: ' + contactLastName
        );
        System.assertNotEquals(null, updatedContact.Portal_Roles__c, 'Portal_Roles__c should not be null');
    }

    @IsTest
    static void registerUserRecaptchaError() {
        NLSQTestUtils.ContactFactory contactFactory = new NLSQTestUtils.ContactFactory();

        Contact currentContact = contactFactory.getContact('Test', 'usertest@gmail.com');
        currentContact.Portal_Roles__c = 'Maker';

        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockError());

        String errorMsg;
        Test.startTest();
        try {
            SelfRegisterCtrl.registerUser(currentContact, 'error_response');
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(ReCaptchaService.ERROR_MSG, errorMsg, 'error message cause captcha bad response');
    }

    @IsTest
    static void registerUserAlreadyExistUser() {
        User admin = new User(Id = UserInfo.getUserId());
        Contact c = new NLSQTestUtils.ContactFactory().getContact('Test', 'usertest@gmail.com');

        System.runAs(admin) {
            insert c;
        }

        User u = new NLSQTestUtils.CommunityUserFactory().getUser(c);
        System.runAs(admin) {
            insert u;
        }

        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());

        String errorMsg;
        Test.startTest();
        try {
            SelfRegisterCtrl.registerUser(c, 'success_response');
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(Label.msgEmailExist, errorMsg, 'error message for exist user');
    }

    @IsTest
    static void registerUserWrongEmail() {
        Contact c = new NLSQTestUtils.ContactFactory().getContact('Test', 'wrong email');
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());

        String errorMsg;
        Test.startTest();
        try {
            SelfRegisterCtrl.registerUser(c, 'success_response');
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(Label.msgValidEmail, errorMsg, 'error message about invalid email');
    }

    @IsTest
    static void getPortalRoles() {
        Test.startTest();
        List<PicklistItem> roles = SelfRegisterCtrl.getPortalRoles();
        Test.stopTest();

        System.assert(!roles.isEmpty(), 'Roles list should not be empty');
    }

    @IsTest
    static void getPortalRolesError() {
        NLSQTestUtils.testError = true;
        String errorMsg;

        Test.startTest();

        try {
            SelfRegisterCtrl.getPortalRoles();
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Attempt to de-reference a null object', errorMsg, 'error message cause data not found');
    }
}