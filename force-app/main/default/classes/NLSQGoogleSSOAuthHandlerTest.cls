@IsTest
private class NLSQGoogleSSOAuthHandlerTest {
    @TestSetup
    static void setupData() {
        Contact c = new NLSQTestUtils.ContactFactory().getContact('Test', 'usertest@gmail.com');
        insert c;
        User u = new NLSQTestUtils.CommunityUserFactory().getUser(c);
        insert u;
        Test.setCreatedDate(u.Id, System.now().addDays(-1));
    }

    @IsTest
    static void testCreateUserNew() {
        NLSQTestUtils.AuthUserDataFactory dataFactory = new NLSQTestUtils.AuthUserDataFactory();
        Auth.UserData userData = dataFactory.getAuthUserData();
        userData.email = 'another.email@test.com';

        Test.startTest();
        User testUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testUser = new NLSQGoogleSSOAuthHandler().createUser(null, userData);
        }

        Test.stopTest();

        testUser = [SELECT CreatedDate FROM User WHERE Id = :testUser.Id];

        System.assertEquals(System.now().date(), testUser.CreatedDate.date(), 'user should be created now');
    }

    @IsTest
    static void testCreateUserExist() {
        NLSQTestUtils.AuthUserDataFactory dataFactory = new NLSQTestUtils.AuthUserDataFactory();
        Auth.UserData userData = dataFactory.getAuthUserData();

        Test.startTest();

        User testUser = new NLSQGoogleSSOAuthHandler().createUser(null, userData);

        Test.stopTest();

        testUser = [SELECT CreatedDate FROM User WHERE Id = :testUser.Id];
        System.assertNotEquals(System.now().date(), testUser.CreatedDate.date(), 'user should be created not now');
    }

    @IsTest
    static void testUpdateUser() {
        User u = [SELECT Id FROM User WHERE Username = 'usertest@gmail.com'];
        NLSQTestUtils.AuthUserDataFactory dataFactory = new NLSQTestUtils.AuthUserDataFactory();
        Auth.UserData userData = dataFactory.getAuthUserData();
        userData.lastName = 'Updated';

        Test.startTest();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            new NLSQGoogleSSOAuthHandler().updateUser(u.Id, null, userData);
        }

        Test.stopTest();

        User assertUser = [SELECT FirstName, LastName FROM User WHERE Id = :u.Id];

        System.assertEquals('Updated', assertUser.LastName, 'User fields should be updated');
    }
}