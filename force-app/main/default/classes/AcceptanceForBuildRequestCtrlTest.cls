@IsTest
private class AcceptanceForBuildRequestCtrlTest {
    @TestSetup
    static void setup() {
        NLSQTestUtils.DeviceFactory deviceFactory = new NLSQTestUtils.DeviceFactory();
        Product2 device = deviceFactory.getDevice('device');
        NLSQTestUtils.insertRecords(new List<Product2>{ device });

        NLSQTestUtils.DeviceRequestFactory drf = new NLSQTestUtils.DeviceRequestFactory();
        Device_Request__c request = drf.getDeviceRequest(device.Id);
        NLSQTestUtils.insertRecords(new List<Device_Request__c>{ request });
    }

    @IsTest
    static void acceptRequest() {
        Device_Request__c request = [SELECT Maker__c, Stage__c FROM Device_Request__c WHERE Device__r.Name = 'device'];

        System.assertEquals(null, request.Maker__c, 'Maker should be empty before test');
        System.assertEquals('Maker Wanted', request.Stage__c, 'Stage__c field should be Maker Wanted by default');

        Test.startTest();
        AcceptanceForBuildRequestCtrl.acceptRequest(request.Id);
        Test.stopTest();

        request = [SELECT Maker__c, Stage__c FROM Device_Request__c WHERE Device__r.Name = 'device'];

        System.assertEquals(UserInfo.getUserId(), request.Maker__c, 'current user should be maker after test');
        System.assertEquals(
            'Building Device',
            request.Stage__c,
            'Stage__c field should be Building Device after accept'
        );
    }

    @IsTest
    static void acceptRequestError() {
        String errorMsg;

        Test.startTest();
        try {
            AcceptanceForBuildRequestCtrl.acceptRequest(null);
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