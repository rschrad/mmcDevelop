@IsTest
public class MyDevicesCtrlTest {
    private static final String COMMUITY_USER_EMAIL_1 = 'first.user.email@mail.com';
    private static final String COMMUITY_USER_EMAIL_2 = 'second.user.email@mail.com';
    @TestSetup
    static void makeData() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }
        NLSQTestUtils.DeviceFactory df = new NLSQTestUtils.DeviceFactory();

        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        Contact contact = cf.getContact('Test1', COMMUITY_USER_EMAIL_1);
        NLSQTestUtils.insertRecords(new List<Contact>{ contact });

        NLSQTestUtils.CommunityUserFactory uf = new NLSQTestUtils.CommunityUserFactory();
        User testCommunityUser = uf.getUser(contact);
        NLSQTestUtils.insertRecords(new List<User>{ testCommunityUser });

        System.runAs(testCommunityUser) {
            Product2 device = df.getDevice('Test1');
            NLSQTestUtils.insertRecords(new List<Product2>{ device });
        }

        Contact contact2 = cf.getContact('Test2', COMMUITY_USER_EMAIL_2);
        NLSQTestUtils.insertRecords(new List<Contact>{ contact2 });

        User testCommunityUser2 = uf.getUser(contact2);
        NLSQTestUtils.insertRecords(new List<User>{ testCommunityUser2 });

        System.runAs(testCommunityUser2) {
            Product2 device = df.getDevice('Test2');
            NLSQTestUtils.insertRecords(new List<Product2>{ device });
        }
    }
    @IsTest
    static void testAllExistingDevices() {
        Test.startTest();
        List<Product2> devices = [SELECT Id FROM Product2];
        Test.stopTest();
        System.assertEquals(2, devices.size(), 'The number of devices must equal 2');
    }

    @IsTest
    static void testGetDevicesCount() {
        User testUser = [SELECT Id FROM USER WHERE EMAIL = :COMMUITY_USER_EMAIL_1];
        Integer devicesCount;
        Test.startTest();
        System.runAs(testUser) {
            devicesCount = MyDevicesCtrl.getDevicesCount(testUser.Id);
        }
        Test.stopTest();
        System.assertEquals(1, devicesCount, 'The number of devices must equal 1');
    }

    @IsTest
    static void testGetDevicesCountError() {
        User testUser = [SELECT Id FROM USER WHERE EMAIL = :COMMUITY_USER_EMAIL_1];
        String errorMsg;
        Test.startTest();
        System.runAs(testUser) {
            try {
                MyDevicesCtrl.getDevicesCount(null);
            } catch (Exception ex) {
                errorMsg = ex.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals('Property userId can not be null.', errorMsg, 'exception with invalid ID should be thrown');
    }

    @IsTest
    static void testGetDevices() {
        User testUser = [SELECT Id FROM USER WHERE EMAIL = :COMMUITY_USER_EMAIL_1];
        List<DeviceWrapper> devices;
        Test.startTest();
        System.runAs(testUser) {
            devices = MyDevicesCtrl.getDevices(testUser.Id, new QueryParameters(5, 0, null));
        }
        Test.stopTest();
        System.assertEquals(1, devices.size(), 'Returned list should have 1 record.');
        System.assertEquals(
            '/s/sfsites/c/img/b2b/default-product-image.svg',
            devices.get(0).imageUrl,
            'The wrong image link'
        );
    }

    @IsTest
    static void testGetDevicesError() {
        User testUser = [SELECT Id FROM USER WHERE EMAIL = :COMMUITY_USER_EMAIL_1];
        String errorMsg;
        Test.startTest();
        System.runAs(testUser) {
            try {
                MyDevicesCtrl.getDevices(null, new QueryParameters());
            } catch (Exception ex) {
                errorMsg = ex.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals('Property userId can not be null.', errorMsg, 'exception with invalid ID should be thrown');
    }
}