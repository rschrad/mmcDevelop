@IsTest
public class RequestDeviceCtrlTest {
    private static final String COMMUITY_USER_EMAIL_1 = 'first.user.email@mail.com';

    @TestSetup
    static void setup() {
        NLSQTestUtils.DeviceFactory deviceFactory = new NLSQTestUtils.DeviceFactory();
        NLSQTestUtils.DeviceCategoryFactory categoryFactory = new NLSQTestUtils.DeviceCategoryFactory();
        NLSQTestUtils.DeviceCategoryDeviceFactory deviceCategoryDeviceFactory = new NLSQTestUtils.DeviceCategoryDeviceFactory();
        NLSQTestUtils.DeviceCatalogFactory deviceCatalogFactory = new NLSQTestUtils.DeviceCatalogFactory();
        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        NLSQTestUtils.CommunityUserFactory uf = new NLSQTestUtils.CommunityUserFactory();

        Contact requestorContact = cf.getContact('Req', COMMUITY_USER_EMAIL_1);
        NLSQTestUtils.insertRecords(new List<Contact>{ requestorContact });
        User requestorUser = uf.getUser(requestorContact);
        NLSQTestUtils.insertRecords(new List<User>{ requestorUser });

        Product2 firstDevice = deviceFactory.getDevice('First device');
        Product2 secondDevice = deviceFactory.getDevice('Second device');
        Product2 thirdDevice = deviceFactory.getDevice('Third device');
        Product2 fourthDevice = deviceFactory.getDevice('Fourth device');
        firstDevice.IsActive = true;
        secondDevice.IsActive = true;
        fourthDevice.IsActive = true;

        NLSQTestUtils.insertRecords(new List<Product2>{ firstDevice, secondDevice, thirdDevice, fourthDevice });
        ProductCatalog deviceCatalog = deviceCatalogFactory.getDeviceCatalog(NLSQConstants.SETTING.Catalog_Name__c);
        NLSQTestUtils.insertRecords(new List<ProductCatalog>{ deviceCatalog });
        ProductCategory newCategory = categoryFactory.getDeviceCategory('TestCategory', deviceCatalog.Id);
        NLSQTestUtils.insertRecords(new List<ProductCategory>{ newCategory });
        ProductCategory defaultCategory = categoryFactory.getDeviceCategory(
            NLSQConstants.SETTING.Category_Name__c,
            deviceCatalog.Id
        );
        NLSQTestUtils.insertRecords(new List<ProductCategory>{ defaultCategory });

        ProductCategoryProduct productCategoryProduct1 = deviceCategoryDeviceFactory.getDeviceCategoryDevice(
            defaultCategory.Id,
            firstDevice.Id
        );
        ProductCategoryProduct productCategoryProduct2 = deviceCategoryDeviceFactory.getDeviceCategoryDevice(
            defaultCategory.Id,
            secondDevice.Id
        );
        ProductCategoryProduct productCategoryProduct3 = deviceCategoryDeviceFactory.getDeviceCategoryDevice(
            defaultCategory.Id,
            thirdDevice.Id
        );
        ProductCategoryProduct productCategoryProduct4 = deviceCategoryDeviceFactory.getDeviceCategoryDevice(
            newCategory.Id,
            fourthDevice.Id
        );
        NLSQTestUtils.insertRecords(
            new List<ProductCategoryProduct>{
                productCategoryProduct1,
                productCategoryProduct2,
                productCategoryProduct3,
                productCategoryProduct4
            }
        );
    }

    @IsTest
    static void getDevicePicklist() {
        Test.startTest();
        List<PicklistItem> devices = RequestDeviceCtrl.getDevicesPicklist();
        Test.stopTest();

        System.assert(!devices.isEmpty(), 'Device list should not be empty');
        System.assertEquals(2, devices.size(), 'Device should contains 2 items');
    }

    @IsTest
    static void createRecord() {
        Product2 device = [SELECT Id FROM Product2 WHERE Name = 'First device'];

        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());

        NLSQTestUtils.DeviceRequestFactory drf = new NLSQTestUtils.DeviceRequestFactory();

        Device_Request__c deviceRequest = drf.getDeviceRequest(device.Id);

        Test.startTest();
        Id recordId = RequestDeviceCtrl.createRecord(deviceRequest, 'success_response');
        Test.stopTest();

        System.assertNotEquals(null, recordId, 'Record should be created');
    }

    @IsTest
    static void createRecordCommUser() {
        Product2 device = [SELECT Id FROM Product2 WHERE Name = 'First device'];

        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());

        NLSQTestUtils.DeviceRequestFactory drf = new NLSQTestUtils.DeviceRequestFactory();

        Device_Request__c deviceRequest = drf.getDeviceRequest(device.Id);

        User commUser = [SELECT ContactId FROM User WHERE LastName = 'Req' LIMIT 1];
        Id recordId;
        System.runAs(commUser) {
            Test.startTest();
            recordId = RequestDeviceCtrl.createRecord(deviceRequest, 'success_response');
            Test.stopTest();
        }

        System.assertNotEquals(null, recordId, 'Record should be created');

        Device_Request__c request = [
            SELECT Device_Requestor__c, RecordTypeId
            FROM Device_Request__c
            WHERE Id = :recordId
        ];
        Id recTypeId = getDeviceRequestRecordType();
        String msg = 'Device_Requestor__c should be assigned';
        System.assertEquals(commUser.ContactId, request.Device_Requestor__c, msg);
        msg = 'Web_Request record type should be assigned';
        System.assertEquals(recTypeId, request.RecordTypeId, msg);
    }

    @IsTest
    static void createRecordError() {
        Product2 device = [SELECT Id FROM Product2 WHERE Name = 'First device'];

        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());

        NLSQTestUtils.DeviceRequestFactory drf = new NLSQTestUtils.DeviceRequestFactory();
        NLSQTestUtils.GuestUserFactory guf = new NLSQTestUtils.GuestUserFactory();
        User guestUser = guf.getGuestUser();

        insert guestUser;

        Device_Request__c deviceRequest = drf.getDeviceRequest(device.Id);
        String errorMsg;

        Test.startTest();
        System.runAs(guestUser) {
            try {
                RequestDeviceCtrl.createRecord(deviceRequest, 'success_response');
            } catch (Exception exc) {
                errorMsg = exc.getMessage();
            }
        }
        Test.stopTest();

        System.assertEquals(
            'Insufficient permissions: secure query included inaccessible field',
            errorMsg,
            'exception with no create access should be thrown'
        );
    }

    @IsTest
    static void createRecordRecaptchaError() {
        Product2 device = [SELECT Id FROM Product2 WHERE Name = 'First device'];

        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockError());

        Device_Request__c deviceRequest = new Device_Request__c(
            Device__c = device.Id,
            Country__c = 'Country',
            City__c = 'City',
            Request_Notes__c = 'Message'
        );

        String errorMsg;
        Test.startTest();
        try {
            RequestDeviceCtrl.createRecord(deviceRequest, 'error_response');
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(ReCaptchaService.ERROR_MSG, errorMsg, 'error message cause captcha bad response');
    }

    static Id getDeviceRequestRecordType() {
        return Schema.SObjectType.Device_Request__c.getRecordTypeInfosByDeveloperName()
            .get(NLSQConstants.SETTING.Device_Request_RecordType_Name__c)
            .getRecordTypeId();
    }
}