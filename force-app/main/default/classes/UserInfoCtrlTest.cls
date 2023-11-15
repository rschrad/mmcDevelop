@IsTest
private class UserInfoCtrlTest {
    private static final String COMMUITY_USER_EMAIL_1 = 'first.user.email@mail.com';
    private static final String COMMUITY_USER_EMAIL_2 = 'second.user.email@mail.com';

    @TestSetup
    static void setup() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }

        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        Contact makerContact = cf.getContact('Maker', COMMUITY_USER_EMAIL_1);
        Contact reqContact = cf.getContact('Req', COMMUITY_USER_EMAIL_2);
        NLSQTestUtils.insertRecords(new List<Contact>{ makerContact, reqContact });

        NLSQTestUtils.CommunityUserFactory uf = new NLSQTestUtils.CommunityUserFactory();
        User makerUser = uf.getUser(makerContact);
        User reqUser = uf.getUser(reqContact);
        NLSQTestUtils.insertRecords(new List<User>{ makerUser, reqUser });
    }

    @IsTest
    static void getUser() {
        List<String> emails = new List<String>{ COMMUITY_USER_EMAIL_1, COMMUITY_USER_EMAIL_2 };
        List<User> users = [
            SELECT Id
            FROM User
            WHERE Email IN :emails
        ];
        User reqUser;

        Test.startTest();
        System.runAs(users.get(0)) {
            reqUser = UserInfoCtrl.getUser(users.get(1).Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, reqUser, 'User should not be null');
        System.assertNotEquals(null, reqUser.Id, 'User Id should not be null');
        System.assertNotEquals(null, reqUser.Name, 'User Name should not be null');
    }

    @IsTest
    static void getUserError() {
        String errorMsg;
        User user = [
            SELECT Id
            FROM User
            WHERE Email = :COMMUITY_USER_EMAIL_1
        ];

        Test.startTest();
        System.runAs(user) {
            try {
                UserInfoCtrl.getUser(null);
            } catch (Exception ex) {
                errorMsg = ex.getMessage();
            }
        }
        Test.stopTest();

        System.assertEquals(
            'Property recordId can not be null.',
            errorMsg,
            'exception with invalid ID should be thrown'
        );
    }
}