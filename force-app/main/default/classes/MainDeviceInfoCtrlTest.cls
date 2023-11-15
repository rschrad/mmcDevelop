@IsTest
public class MainDeviceInfoCtrlTest {
    @TestSetup
    static void makeData() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }
        NLSQTestUtils.DeviceFactory df = new NLSQTestUtils.DeviceFactory();
        Product2 product = df.getDevice('Test1');
        NLSQTestUtils.insertRecords(new List<Product2>{ product });
        insert new Device_Like__c(Device__c = product.Id);
    }

    @IsTest
    static void testGetDeviceInfo() {
        Id recordId = [SELECT Id FROM Product2 WHERE Name = 'Test1' LIMIT 1].Id;

        Product2 product;
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            product = MainDeviceInfoCtrl.getDeviceInfo(recordId);
        }
        Test.stopTest();

        String msgPrefix = NLSQTestUtils.RECORD_ASSERTION_MSG_PREFIX;
        System.assertNotEquals(null, product, 'Record should be returned.');
        System.assertEquals(recordId, product.Id, msgPrefix + '(Product2.Id)');
        System.assertEquals('Test1', product.Name, msgPrefix + '(Product2.Name)');
        System.assertEquals(1, product.Likes_Count__c, msgPrefix + '(Product2.Likes_Count__c)');
        System.assertEquals(10, product.Downloads_Count__c, msgPrefix + '(Product2.Downloads_Count__c)');
        System.assertEquals(15, product.Shares_Count__c, msgPrefix + '(Product2.Shares_Count__c)');
        System.assertEquals(150, product.Views_Count__c, msgPrefix + '(Product2.Views_Count__c)');
        System.assertEquals(
            'User Value',
            product.User_Value_Statement__c,
            msgPrefix + '(Product2.User_Value_Statement__c)'
        );

        User u = [SELECT Name, FullPhotoUrl FROM User WHERE Id = :UserInfo.getUserId()];
        System.assertEquals(u.Name, product.Designer__r.Name, msgPrefix + '(Product2.Designer__r.Name)');
        System.assertEquals(
            u.FullPhotoUrl,
            product.Designer__r.FullPhotoUrl,
            msgPrefix + '(Product2.Designer__r.FullPhotoUrl)'
        );
    }

    @IsTest
    static void testGetDeviceInfoError() {
        String errorMsg;

        Test.startTest();
        try {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                MainDeviceInfoCtrl.getDeviceInfo(null);
            }
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(
            'List has no rows for assignment to SObject',
            errorMsg,
            'exception with no assignment records should be thrown'
        );
    }

    @IsTest
    static void testUpdateCount() {
        Product2 expected = [SELECT Downloads_Count__c FROM Product2 WHERE Name = 'Test1' LIMIT 1];

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            MainDeviceInfoCtrl.updateCount(expected.Id, 'Downloads_Count__c');
        }
        Test.stopTest();

        Product2 actual = [SELECT Downloads_Count__c FROM Product2 WHERE Id = :expected.Id];
        System.assertEquals(
            expected.Downloads_Count__c + 1,
            actual.Downloads_Count__c,
            'Downloads Count should be incremented by 1.'
        );
    }

    @IsTest
    static void testUpdateCountError() {
        String errorMsg;

        Test.startTest();
        try {
            MainDeviceInfoCtrl.updateCount(null, 'Invalid_Field');
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(
            'Invalid field for count update: Invalid_Field',
            errorMsg,
            'exception with message about wrong field should be thrown'
        );
    }

    @IsTest
    static void testGetUserLike() {
        Id recordId = [SELECT Id FROM Product2 WHERE Name = 'Test1' LIMIT 1].Id;

        Test.startTest();
        Id likeId = MainDeviceInfoCtrl.getUserLike(recordId);
        Test.stopTest();

        Device_Like__c expected = [
            SELECT Id
            FROM Device_Like__c
            WHERE Device__c = :recordId AND OwnerId = :UserInfo.getUserId()
        ];
        System.assertEquals(expected.Id, likeId, 'Should return Device_Like__c Id.');
    }

    @IsTest
    static void testGetUserLikeNull() {
        Id recordId = [SELECT Id FROM Product2 WHERE Name = 'Test1' LIMIT 1].Id;
        delete [SELECT Id FROM Device_Like__c WHERE Device__c = :recordId AND OwnerId = :UserInfo.getUserId()];

        Test.startTest();
        Id likeId = MainDeviceInfoCtrl.getUserLike(recordId);
        Test.stopTest();

        System.assertEquals(null, likeId, 'Should return null instead for empty results.');
    }
}