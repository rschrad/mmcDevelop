@IsTest
private class MyBuildsAndRequestsCtrlTest {
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

        NLSQTestUtils.DeviceFactory df = new NLSQTestUtils.DeviceFactory();
        Product2 device;
        System.runAs(makerUser) {
            device = df.getDevice('Device');
            NLSQTestUtils.insertRecords(new List<Product2>{ device });
        }

        NLSQTestUtils.DeviceRequestFactory drf = new NLSQTestUtils.DeviceRequestFactory();

        System.runAs(requestorUser) {
            Device_Request__c request = drf.getDeviceRequest(device.Id);
            request.Maker__c = makerUser.Id;
            NLSQTestUtils.insertRecords(new List<Device_Request__c>{ request });
        }
    }

    @IsTest
    static void getRequestsByMaker() {
        User u = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_1];
        List<RequestWrapper> wrappers;
        QueryParameters parameters = new QueryParameters();
        parameters.lim = 4;
        parameters.offset = 0;

        Test.startTest();
        System.runAs(u) {
            wrappers = MyBuildsAndRequestsCtrl.getRequests(u.Id, parameters);
        }
        Test.stopTest();

        System.assertNotEquals(null, wrappers, 'List of wrappers should not be null');
        System.assert(!wrappers.isEmpty(), 'List of wrappers should not be empty');

        for (RequestWrapper wrapper : wrappers) {
            System.assertNotEquals(null, wrapper.request, 'Request should not be null');
            System.assertNotEquals(null, wrapper.mediaUrl, 'Media Url should not be null');
        }
    }

    @IsTest
    static void getRequestsByRequestor() {
        User u = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_2];
        List<RequestWrapper> wrappers;
        QueryParameters parameters = new QueryParameters();
        parameters.lim = 4;
        parameters.offset = 0;

        Test.startTest();
        System.runAs(u) {
            wrappers = MyBuildsAndRequestsCtrl.getRequests(u.Id, parameters);
        }
        Test.stopTest();

        System.assertNotEquals(null, wrappers, 'List of wrappers should not be null');
        System.assert(!wrappers.isEmpty(), 'List of wrappers should not be empty');

        for (RequestWrapper wrapper : wrappers) {
            System.assertNotEquals(null, wrapper.request, 'Request should not be null');
            System.assertNotEquals(null, wrapper.mediaUrl, 'Media Url should not be null');
        }
    }

    @IsTest
    static void getRequestsByUserWithoutRequests() {
        User u = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_3];
        List<RequestWrapper> wrappers;
        QueryParameters parameters = new QueryParameters();
        parameters.lim = 4;
        parameters.offset = 0;

        Test.startTest();
        System.runAs(u) {
            wrappers = MyBuildsAndRequestsCtrl.getRequests(u.Id, parameters);
        }
        Test.stopTest();

        System.assertNotEquals(null, wrappers, 'List of wrappers should not be null');
        System.assert(wrappers.isEmpty(), 'List of wrappers should be empty');
    }

    @IsTest
    static void getRequestsCount() {
        User u = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_1];
        Integer count;

        Test.startTest();
        System.runAs(u) {
            count = MyBuildsAndRequestsCtrl.getRequestsCount(u.Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, count, 'Records count should not be null');
        System.assertEquals(1, count, 'Record count should be 1');
    }

    @IsTest
    static void getRequestsCountError() {
        String errorMsg;

        Test.startTest();
        try {
            MyBuildsAndRequestsCtrl.getRequestsCount(null);
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(
            'Property recordId can not be null.',
            errorMsg,
            'exception with invalid ID should be thrown'
        );
    }

    @IsTest
    static void getRequestsError() {
        String errorMsg;

        Test.startTest();
        try {
            MyBuildsAndRequestsCtrl.getRequests(null, null);
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(
            'Property recordId can not be null.',
            errorMsg,
            'exception with invalid ID should be thrown'
        );
    }
}