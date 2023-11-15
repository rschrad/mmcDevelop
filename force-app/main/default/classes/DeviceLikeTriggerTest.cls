@IsTest
private class DeviceLikeTriggerTest {
    @TestSetup
    static void setup() {
        User admin = new User(Id = UserInfo.getUserId());
        NLSQTestUtils.assignAdminPermissionSet();

        NLSQTestUtils.DeviceFactory deviceFactory = new NLSQTestUtils.DeviceFactory();

        Product2 firstDevice = deviceFactory.getDevice('First device');
        Product2 secondDevice = deviceFactory.getDevice('Second device');

        System.runAs(admin) {
            NLSQTestUtils.insertRecords(new List<Product2>{ firstDevice, secondDevice });
        }

        NLSQTestUtils.ContactFactory contactFactory = new NLSQTestUtils.ContactFactory();
        Contact firstContact = contactFactory.getContact('First', 'first.user.email@mail.com');
        Contact secondContact = contactFactory.getContact('Second', 'second.user.email@mail.com');

        System.runAs(admin) {
            NLSQTestUtils.insertRecords(new List<Contact>{ firstContact, secondContact });
        }

        NLSQTestUtils.CommunityUserFactory communityUserFactory = new NLSQTestUtils.CommunityUserFactory();
        User firstUser = communityUserFactory.getUser(firstContact);
        User secondUser = communityUserFactory.getUser(secondContact);

        System.runAs(admin) {
            NLSQTestUtils.insertRecords(new List<User>{ firstUser, secondUser });
        }
    }

    @IsTest
    static void testSingleInsert() {
        User communityUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];

        Product2 firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            0,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 0, cause likes records do not exist in system'
        );

        NLSQTestUtils.LikeFactory firstDeviceLikes = new NLSQTestUtils.LikeFactory(firstDevice);

        Device_Like__c deviceLike = firstDeviceLikes.getLike(communityUser.Id);

        Test.startTest();

        System.runAs(communityUser) {
            insert deviceLike;
        }

        Test.stopTest();

        firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            1,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 1, cause one like record exists in system'
        );
    }

    @IsTest
    static void testOneUserListInsert() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];

        Product2 firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];
        Product2 secondDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'Second device'];

        System.assertEquals(
            0,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 0, cause likes records do not exist in system'
        );
        System.assertEquals(
            0,
            secondDevice.Likes_Count__c,
            'Likes_Count__c field must be 0, cause likes records do not exist in system'
        );

        NLSQTestUtils.LikeFactory firstDeviceLikes = new NLSQTestUtils.LikeFactory(firstDevice);
        NLSQTestUtils.LikeFactory secondDeviceLikes = new NLSQTestUtils.LikeFactory(secondDevice);

        List<Device_Like__c> deviceLikes = new List<Device_Like__c>{
            firstDeviceLikes.getLike(firstUser.Id),
            secondDeviceLikes.getLike(firstUser.Id)
        };

        Test.startTest();

        System.runAs(firstUser) {
            insert deviceLikes;
        }

        Test.stopTest();

        firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];
        secondDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'Second device'];

        System.assertEquals(
            1,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 1, cause one like record exists in system'
        );
        System.assertEquals(
            1,
            secondDevice.Likes_Count__c,
            'Likes_Count__c field must be 1, cause one like record exists in system'
        );
    }

    @IsTest
    static void testOneProductListInsert() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];
        User secondUser = [SELECT Id FROM User WHERE Email = 'second.user.email@mail.com'];

        Product2 firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            0,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 0, cause likes records do not exist in system'
        );

        NLSQTestUtils.LikeFactory firstDeviceLikes = new NLSQTestUtils.LikeFactory(firstDevice);

        List<Device_Like__c> deviceLikes = new List<Device_Like__c>{
            firstDeviceLikes.getLike(firstUser.Id),
            firstDeviceLikes.getLike(secondUser.Id)
        };

        Test.startTest();

        insert deviceLikes;

        Test.stopTest();

        firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            2,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 2, cause two like records exists in system'
        );
    }

    @IsTest
    static void testSingleUpdate() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];
        User secondUser = [SELECT Id FROM User WHERE Email = 'second.user.email@mail.com'];

        Product2 firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        NLSQTestUtils.LikeFactory firstDeviceLikes = new NLSQTestUtils.LikeFactory(firstDevice);

        Device_Like__c deviceLike = firstDeviceLikes.getLike(firstUser.Id);
        insert deviceLike;

        Test.startTest();

        deviceLike.OwnerId = secondUser.Id;
        update deviceLike;

        Test.stopTest();

        firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            1,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 1, cause one like record exists in system'
        );
    }

    @IsTest
    static void testSingleDelete() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];
        User secondUser = [SELECT Id FROM User WHERE Email = 'second.user.email@mail.com'];

        Product2 firstDevice = [SELECT Id FROM Product2 WHERE Name = 'First device'];

        NLSQTestUtils.LikeFactory firstDeviceLikes = new NLSQTestUtils.LikeFactory(firstDevice);

        List<Device_Like__c> deviceLikes = new List<Device_Like__c>{
            firstDeviceLikes.getLike(firstUser.Id),
            firstDeviceLikes.getLike(secondUser.Id)
        };
        insert deviceLikes;
        firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];
        System.assertEquals(
            2,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 2, cause two like records exists in system'
        );

        Test.startTest();

        delete deviceLikes.get(0);

        Test.stopTest();

        firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            1,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 1, cause one like record exists in system'
        );
    }

    @IsTest
    static void testSingleUnDelete() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];
        User secondUser = [SELECT Id FROM User WHERE Email = 'second.user.email@mail.com'];

        Product2 firstDevice = [SELECT Id FROM Product2 WHERE Name = 'First device'];

        NLSQTestUtils.LikeFactory firstDeviceLikes = new NLSQTestUtils.LikeFactory(firstDevice);

        List<Device_Like__c> deviceLikes = new List<Device_Like__c>{
            firstDeviceLikes.getLike(firstUser.Id),
            firstDeviceLikes.getLike(secondUser.Id)
        };
        insert deviceLikes;
        firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];
        System.assertEquals(
            2,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 2, cause two like records exists in system'
        );
        delete deviceLikes.get(0);

        Test.startTest();

        undelete deviceLikes.get(0);

        Test.stopTest();

        firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            2,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 2, cause one like record exists in system'
        );
    }

    @IsTest
    static void testUniqLike() {
        User communityUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];

        Product2 firstDevice = [SELECT Likes_Count__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            0,
            firstDevice.Likes_Count__c,
            'Likes_Count__c field must be 0, cause likes records do not exist in system'
        );

        NLSQTestUtils.LikeFactory firstDeviceLikes = new NLSQTestUtils.LikeFactory(firstDevice);

        List<Device_Like__c> deviceLikes = new List<Device_Like__c>{
            firstDeviceLikes.getLike(communityUser.Id),
            firstDeviceLikes.getLike(communityUser.Id)
        };

        Boolean exceptionThrown = false;

        Test.startTest();

        try {
            insert deviceLikes;
        } catch (Exception ex) {
            exceptionThrown = true;
        }

        Test.stopTest();

        System.assert(exceptionThrown, 'exception must bu thrown on not-uniq likes');
    }
}