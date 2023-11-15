@IsTest
public class DeviceRequestListCtrlTest {
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
        Id recTypeId = getDeviceRequestRecordType();
        Device_Request__c request1 = drf.getDeviceRequest(device.Id);
        request1.Country__c = 'UA';
        request1.RecordTypeId = recTypeId;
        Device_Request__c request2 = drf.getDeviceRequest(device.Id);
        request2.Maker__c = makerUser.Id;
        request2.RecordTypeId = recTypeId;
        request2.Stage__c = Label.lblBuildingDevice;
        Device_Request__c request3 = drf.getDeviceRequest(device.Id);

        System.runAs(requestorUser) {
            NLSQTestUtils.insertRecords(new List<Device_Request__c>{ request1, request2, request3 });
        }
    }

    @IsTest
    static void getAllRequestsCount() {
        Map<String, String> filteringFieldsToValue = new Map<String, String>{
            'Country__c' => null,
            'State__c' => null
        };

        Test.startTest();

        Integer count = DeviceRequestListCtrl.getDeviceRequestsCount(filteringFieldsToValue);

        Test.stopTest();

        System.assertEquals(2, count, 'Record count should be 2');
    }

    @IsTest
    static void getRequestsCountFiltered() {
        Map<String, String> filteringFieldsToValue = new Map<String, String>{
            'Country__c' => 'UA',
            'State__c' => null,
            'Device__c' => 'Dev'
        };
        Integer count;

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            count = DeviceRequestListCtrl.getDeviceRequestsCount(filteringFieldsToValue);
        }
        Test.stopTest();

        System.assertEquals(1, count, 'Record count should be 1');
    }

    @IsTest
    static void getDeviceRequests() {
        Map<String, String> filteringFieldsToValue = new Map<String, String>{
            'Country__c' => null,
            'State__c' => null
        };

        List<Device_Request__c> deviceRequests;

        QueryParameters parameters = new QueryParameters();
        parameters.lim = 1;
        parameters.offset = 0;
        parameters.orderBy = 'Request_Date__c ASC';

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            deviceRequests = DeviceRequestListCtrl.getDeviceRequests(parameters, filteringFieldsToValue);
        }

        Test.stopTest();

        System.assertEquals(1, deviceRequests.size(), 'List Record count should be 1');
    }

    @IsTest
    static void getDeviceRequestFilterFields() {
        User u = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_3];
        List<SortingFieldWrapper> fields;
        Test.startTest();
        System.runAs(u) {
            fields = DeviceRequestListCtrl.getDeviceRequestFilterFields();
        }
        Test.stopTest();

        System.assertEquals(5, fields.size(), 'List count should be 5');
        System.assertEquals('Request_Date__c', fields.get(0).fieldApiName, 'Wrong Field Api Name');
        System.assertEquals('Device__r.Name', fields.get(1).fieldApiName, 'Wrong Field Api Name');
        System.assertEquals('City__c', fields.get(2).fieldApiName, 'Wrong Field Api Name');
        System.assertEquals('State__c', fields.get(3).fieldApiName, 'Wrong Field Api Name');
        System.assertEquals('Country__c', fields.get(4).fieldApiName, 'Wrong Field Api Name');
    }

    @IsTest
    static void getDeviceRequestsError() {
        User testUser = [SELECT Id FROM User WHERE Email = :COMMUITY_USER_EMAIL_3];
        String errorMsg;

        Test.startTest();
        System.runAs(testUser) {
            try {
                DeviceRequestListCtrl.getDeviceRequests(null, null);
            } catch (Exception ex) {
                errorMsg = ex.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals('Attempt to de-reference a null object', errorMsg, 'List of records must be empty');
    }

    static Id getDeviceRequestRecordType() {
        return Schema.SObjectType.Device_Request__c.getRecordTypeInfosByDeveloperName()
            .get(NLSQConstants.SETTING.Device_Request_RecordType_Name__c)
            .getRecordTypeId();
    }
}