@IsTest
public class ContactUsCtrlTest {
    private static final String COMMUITY_USER_EMAIL_1 = 'first.user.email@mail.com';
    private static final String COMMUITY_USER_EMAIL_2 = 'second.user.email@mail.com';
    private static final String COMMUITY_USER_EMAIL_3 = 'third.user.email@mail.com';

    @TestSetup
    static void setup() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }

        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        Contact makerContact = cf.getContact('Maker', COMMUITY_USER_EMAIL_1);
        Contact requestorContact = cf.getContact('Req', COMMUITY_USER_EMAIL_2);
        Contact otherContact = cf.getContact('Other', COMMUITY_USER_EMAIL_3);
        NLSQTestUtils.insertRecords(new List<Contact>{ makerContact, requestorContact, otherContact });

        NLSQTestUtils.CommunityUserFactory uf = new NLSQTestUtils.CommunityUserFactory();
        User makerUser = uf.getUser(makerContact);
        User requestorUser = uf.getUser(requestorContact);
        User otherUser = uf.getUser(otherContact);
        NLSQTestUtils.insertRecords(new List<User>{ makerUser, requestorUser, otherUser });
    }

    @IsTest
    static void sendMessageUnderSysAdmin() {
        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(0, cases.size(), 'No one message was sent.');
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(3, contacts.size(), 'Only three contacts were created in the setup.');
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());
        Test.startTest();
        ContactRequestWrapper contactRequest = new ContactRequestWrapper();
        contactRequest.cs.Subject = 'Test Subject';
        contactRequest.cs.Description = 'Test Message';
        contactRequest.cs.Origin = 'Web';
        contactRequest.cs.Status = 'New';
        ContactUsCtrl.sendMessage(contactRequest, 'success_response', false);
        Test.stopTest();
        List<Contact> contactsAfterSentMessage = [SELECT Id FROM Contact];
        System.assertEquals(3, contactsAfterSentMessage.size(), 'Only three contacts must exist');
        List<Case> casesAfterSentMessage = [SELECT Id, Origin, Status, ContactId, Subject, Description FROM Case];
        System.assertEquals(1, casesAfterSentMessage.size(), 'Only one message was sent.');
        System.assertEquals('Web', casesAfterSentMessage.get(0).Origin, 'The Origin for new case must be Web.');
        System.assertEquals('New', casesAfterSentMessage.get(0).Status, 'The Status for new case must be New.');
        System.assertEquals(
            null,
            casesAfterSentMessage.get(0).ContactId,
            'The ContactId for new case must be null for Internal User.'
        );
        System.assertEquals(
            'Test Subject',
            casesAfterSentMessage.get(0).Subject,
            'The Subject for the new case was defined as Test Subject.'
        );
        System.assertEquals(
            'Test Message',
            casesAfterSentMessage.get(0).Description,
            'The Description for the new case was defined as Test Message.'
        );
    }

    @IsTest
    static void sendMessageRecaptchaError() {
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockError());
        String errorMsg;
        Test.startTest();
        try {
            ContactUsCtrl.sendMessage(new ContactRequestWrapper(), 'error_response', false);
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(ReCaptchaService.ERROR_MSG, errorMsg, 'error message cause captcha bad response');
    }

    @IsTest
    static void sendMessageUnderCommunityUser() {
        User us = [
            SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email
            FROM User
            WHERE Email = :COMMUITY_USER_EMAIL_3
        ];
        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(0, cases.size(), 'No one message was sent.');
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(3, contacts.size(), 'Only three contacts were created in the setup.');
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());
        Test.startTest();
        System.runAs(us) {
            ContactRequestWrapper contactRequest = new ContactRequestWrapper();
            contactRequest.cont.FirstName = us.Contact.FirstName;
            contactRequest.cont.LastName = us.Contact.LastName;
            contactRequest.cont.Email = us.Contact.Email;
            contactRequest.cs.Subject = 'Test Subject';
            contactRequest.cs.ContactId = us.ContactId;
            contactRequest.cs.Description = 'Test Message';
            contactRequest.cs.Origin = 'Web';
            contactRequest.cs.Status = 'New';
            ContactUsCtrl.sendMessage(contactRequest, 'success_response', false);
        }
        Test.stopTest();
        List<Contact> contactsAfterSentMessage = [SELECT Id FROM Contact];
        System.assertEquals(3, contactsAfterSentMessage.size(), 'Only three contacts must exist');
        Contact currentContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :us.ContactId];
        System.assertEquals(
            us.Contact.FirstName,
            currentContact.FirstName,
            'The First Name for current contact should not be updated.'
        );
        System.assertEquals(
            us.Contact.LastName,
            currentContact.LastName,
            'The Last Name for current contact should not be updated.'
        );
        System.assertEquals(
            us.Contact.Email,
            currentContact.Email,
            'The Email for current contact should not be updated.'
        );

        List<Case> casesAfterSentMessage = [SELECT Id, Origin, Status, ContactId, Subject, Description FROM Case];
        System.assertEquals(1, casesAfterSentMessage.size(), 'Only one message was sent.');
        System.assertEquals('Web', casesAfterSentMessage.get(0).Origin, 'The Origin for new case must be Web.');
        System.assertEquals('New', casesAfterSentMessage.get(0).Status, 'The Status for new case must be New.');
        System.assertEquals(
            us.ContactId,
            casesAfterSentMessage.get(0).ContactId,
            'The ContactId for the new case must be equal current contact'
        );
        System.assertEquals(
            'Test Subject',
            casesAfterSentMessage.get(0).Subject,
            'The Subject for the new case was defined as Test Subject.'
        );
        System.assertEquals(
            'Test Message',
            casesAfterSentMessage.get(0).Description,
            'The Description for the new case was defined as Test Message.'
        );
    }

    @IsTest
    static void sendMessageUnderNewGuestUser() {
        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(0, cases.size(), 'No one message was sent.');
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(3, contacts.size(), 'Only three contacts were created in the setup.');
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());
        Test.startTest();
        ContactRequestWrapper contactRequest = new ContactRequestWrapper();
        contactRequest.cont.FirstName = 'Guest';
        contactRequest.cont.LastName = 'User';
        contactRequest.cont.Email = 'guestuser@gmail.com';
        contactRequest.cs.Subject = 'Test Subject';
        contactRequest.cs.Description = 'Test Message';
        contactRequest.cs.Origin = 'Web';
        contactRequest.cs.Status = 'New';
        ContactUsCtrl.sendMessage(contactRequest, 'success_response', true);
        Test.stopTest();
        List<Contact> contactsAfterSentMessage = [SELECT Id FROM Contact];
        System.assertEquals(4, contactsAfterSentMessage.size(), 'Fourth contact must be created for guest user.');
        Contact currentContact = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
            WHERE Email = 'guestuser@gmail.com'
        ];
        System.assertEquals('Guest', currentContact.FirstName, 'The First Name for current contact must be Guest.');
        System.assertEquals('User', currentContact.LastName, 'The Last Name for current contact must be User.');

        List<Case> casesAfterSentMessage = [SELECT Id, Origin, Status, ContactId, Subject, Description FROM Case];
        System.assertEquals(1, casesAfterSentMessage.size(), 'Only one message was sent.');
        System.assertEquals('Web', casesAfterSentMessage.get(0).Origin, 'The Origin for new case must be Web.');
        System.assertEquals('New', casesAfterSentMessage.get(0).Status, 'The Status for new case must be New.');
        System.assertEquals(
            currentContact.Id,
            casesAfterSentMessage.get(0).ContactId,
            'The ContactId for the new case must be equal current contact'
        );
        System.assertEquals(
            'Test Subject',
            casesAfterSentMessage.get(0).Subject,
            'The Subject for the new case was defined as Test Subject.'
        );
        System.assertEquals(
            'Test Message',
            casesAfterSentMessage.get(0).Description,
            'The Description for the new case was defined as Test Message.'
        );
    }

    @IsTest
    static void sendMessageUnderExistedGuestUser() {
        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(0, cases.size(), 'No one message was sent.');
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(3, contacts.size(), 'Only three contacts were created in the setup.');
        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        Contact guestUser = cf.getContact('User', 'guestuser@gmail.com');
        NLSQTestUtils.insertRecords(new List<Contact>{ guestUser });
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());
        Test.startTest();
        ContactRequestWrapper contactRequest = new ContactRequestWrapper();
        contactRequest.cont.FirstName = 'Pablo';
        contactRequest.cont.LastName = 'Picasso';
        contactRequest.cont.Email = guestUser.Email;
        contactRequest.cs.Subject = 'Test Subject';
        contactRequest.cs.Description = 'Test Message';
        contactRequest.cs.Origin = 'Web';
        contactRequest.cs.Status = 'New';
        ContactUsCtrl.sendMessage(contactRequest, 'success_response', true);
        Test.stopTest();
        List<Contact> contactsAfterSentMessage = [SELECT Id FROM Contact];
        System.assertEquals(4, contactsAfterSentMessage.size(), 'Fourth contact must be created for guest user.');
        Contact currentContact = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
            WHERE Email = 'guestuser@gmail.com'
        ];
        System.assertEquals(
            'Pablo',
            currentContact.FirstName,
            'The First Name for current contact must be updated to Pablo.'
        );
        System.assertEquals(
            'Picasso',
            currentContact.LastName,
            'The Last Name for current contact must be updated to Picasso.'
        );

        List<Case> casesAfterSentMessage = [SELECT Id, Origin, Status, ContactId, Subject, Description FROM Case];
        System.assertEquals(1, casesAfterSentMessage.size(), 'Only one message was sent.');
        System.assertEquals('Web', casesAfterSentMessage.get(0).Origin, 'The Origin for new case must be Web.');
        System.assertEquals('New', casesAfterSentMessage.get(0).Status, 'The Status for new case must be New.');
        System.assertEquals(
            currentContact.Id,
            casesAfterSentMessage.get(0).ContactId,
            'The ContactId for the new case must be equal current contact'
        );
        System.assertEquals(
            'Test Subject',
            casesAfterSentMessage.get(0).Subject,
            'The Subject for the new case was defined as Test Subject.'
        );
        System.assertEquals(
            'Test Message',
            casesAfterSentMessage.get(0).Description,
            'The Description for the new case was defined as Test Message.'
        );
    }

    @IsTest
    static void sendMessageWithEmptyEmail() {
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());
        String errorMsg;
        Test.startTest();
        try {
            ContactUsCtrl.sendMessage(new ContactRequestWrapper(), 'success_response', true);
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Property email can not be null.', errorMsg, 'error message cause empty email value');
    }
}