@IsTest
public class DeviceRequestTriggerTest {
    private static final String COMMUITY_USER_EMAIL_1 = 'first.user.email@mail.com';
    private static final String COMMUITY_USER_EMAIL_2 = 'second.user.email@mail.com';
    @TestSetup
    static void makeData() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }
        NLSQTestUtils.DeviceFactory df = new NLSQTestUtils.DeviceFactory();
        NLSQTestUtils.DeviceRequestFactory drf = new NLSQTestUtils.DeviceRequestFactory();

        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        Contact contact = cf.getContact('Test1', COMMUITY_USER_EMAIL_1);
        NLSQTestUtils.insertRecords(new List<Contact>{ contact });

        NLSQTestUtils.CommunityUserFactory uf = new NLSQTestUtils.CommunityUserFactory();
        User testCommunityUser = uf.getUser(contact);
        NLSQTestUtils.insertRecords(new List<User>{ testCommunityUser });
        Product2 device;
        System.runAs(testCommunityUser) {
            device = df.getDevice('Test1');
            NLSQTestUtils.insertRecords(new List<Product2>{ device });
        }

        Contact contact2 = cf.getContact('Test2', COMMUITY_USER_EMAIL_2);
        NLSQTestUtils.insertRecords(new List<Contact>{ contact2 });

        User testCommunityUser2 = uf.getUser(contact2);
        NLSQTestUtils.insertRecords(new List<User>{ testCommunityUser2 });

        System.runAs(testCommunityUser2) {
            Device_Request__c deviceReq = drf.getDeviceRequest(device.Id);
            deviceReq.Stage_modified_date__c = Date.today().addDays(-1);
            deviceReq.Stage__c = Label.lblMakerWanted;
            NLSQTestUtils.insertRecords(new List<Device_Request__c>{ deviceReq });
        }
    }

    @IsTest
    static void testUpdateDeviceRequestStage() {
        User testUser = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_2];
        Device_Request__c deviceReq = [SELECT Id, Stage__c, Stage_modified_date__c FROM Device_Request__c LIMIT 1];
        System.assertEquals(Label.lblMakerWanted, deviceReq.Stage__c, 'The Stage should be equals Maker Wanted');
        System.assertEquals(
            Date.today().addDays(-1),
            deviceReq.Stage_modified_date__c,
            'The Stage modify date should be yesterday'
        );
        Test.startTest();
        System.runAs(testUser) {
            deviceReq.Stage__c = Label.lblShipped;
            update deviceReq;
        }
        Test.stopTest();
        Device_Request__c deviceReqAfterUpdate = [
            SELECT Id, Stage__c, Stage_modified_date__c
            FROM Device_Request__c
            LIMIT 1
        ];
        System.assertEquals(Label.lblShipped, deviceReqAfterUpdate.Stage__c, 'The Stage should be equals Shipped');
        System.assertEquals(
            Date.today(),
            deviceReqAfterUpdate.Stage_modified_date__c,
            'The Stage modify date should be today'
        );
    }

    @IsTest
    static void testUpdateDeviceRequestCountry() {
        User testUser = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_2];
        Device_Request__c deviceReq = [SELECT Id, Country__c, Stage_modified_date__c FROM Device_Request__c LIMIT 1];
        System.assertEquals('Canada', deviceReq.Country__c, 'The Country should be equals Canada');
        System.assertEquals(
            Date.today().addDays(-1),
            deviceReq.Stage_modified_date__c,
            'The Stage modify date should be yesterday'
        );
        Test.startTest();
        System.runAs(testUser) {
            deviceReq.Country__c = 'Italy';
            update deviceReq;
        }
        Test.stopTest();
        Device_Request__c deviceReqAfterUpdate = [
            SELECT Id, Country__c, Stage_modified_date__c
            FROM Device_Request__c
            LIMIT 1
        ];
        System.assertEquals('Italy', deviceReqAfterUpdate.Country__c, 'The Country should be equals Italy');
        System.assertEquals(
            Date.today().addDays(-1),
            deviceReqAfterUpdate.Stage_modified_date__c,
            'The Stage modify date should be yesterday'
        );
    }
}