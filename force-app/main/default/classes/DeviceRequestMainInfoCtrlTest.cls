@IsTest
private class DeviceRequestMainInfoCtrlTest {
    @TestSetup
    static void setup() {
        NLSQTestUtils.DeviceFactory deviceFactory = new NLSQTestUtils.DeviceFactory();

        Product2 device = deviceFactory.getDevice('device');

        NLSQTestUtils.insertRecords(new List<Product2>{ device });
    }

    @IsTest
    static void getContentKey() {
        Product2 device = [SELECT Id FROM Product2 WHERE Name = 'device'];

        Test.startTest();
        Map<Id, String> deviceIdToContent = DeviceRequestMainInfoCtrl.getContentKey(device.Id);
        Test.stopTest();

        System.assertNotEquals(null, deviceIdToContent.get(device.Id), 'Map should be contains decive Id as a key');
        System.assertEquals(
            NLSQConstants.DEFAULT_DEVICE_IMG_URL,
            deviceIdToContent.get(device.Id),
            'Url for img should be: ' + NLSQConstants.DEFAULT_DEVICE_IMG_URL
        );
    }

    @IsTest
    static void getContentKeyError() {
        String errorMsg;

        Test.startTest();
        try {
            DeviceRequestMainInfoCtrl.getContentKey(null);
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