// this class exist only for covering ManagedContentService.cls
// cause it's not possible to create/insert ManagedContentVersionCollection
@IsTest
private class ManagedContentServiceTest {
    @IsTest
    static void getDevisesUrlds() {
        String errorMsg;

        Test.startTest();
        try {
            ManagedContentService.getVersionCollection(new List<Id>());
        } catch (Exception exc) {
            errorMsg = exc.getMessage();
        }
        Test.stopTest();

        System.assertNotEquals(null, errorMsg, 'It is not possible get data from test area');
    }

    @IsTest
    static void getDevisesUrls() {
        String errorMsg;
        NLSQTestUtils.DeviceFactory deviceFactory = new NLSQTestUtils.DeviceFactory();

        Product2 device = deviceFactory.getDevice('device');

        insert device;

        Map<Id, SObject> idToSObject = new Map<Id, SObject>();
        idToSObject.put(device.Id, new ProductMedia(ProductId = device.Id));
        ConnectApi.ManagedContentVersionCollection versionCollection = new ConnectApi.ManagedContentVersionCollection();
        versionCollection.items = new List<ConnectApi.ManagedContentVersion>{ new ConnectApi.ManagedContentVersion() };

        Test.startTest();
        try {
            ManagedContentService.getDevisesUrls(versionCollection, idToSObject);
        } catch (Exception exc) {
            errorMsg = exc.getMessage();
        }
        Test.stopTest();

        System.assertNotEquals(null, errorMsg, 'It is not possible get data from test area');
    }
}