@IsTest
private class DeviceReviewTriggerTest {
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

        Product2 firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            0,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 0, cause review records does not exist in system'
        );
        System.assertEquals(
            0,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 0, cause review records does not exist in system'
        );

        NLSQTestUtils.ReviewFactory firstDeviceReview = new NLSQTestUtils.ReviewFactory(firstDevice);

        Device_Review__c deviceReview = firstDeviceReview.getReview(communityUser.Id, 5);

        Test.startTest();

        System.runAs(communityUser) {
            insert deviceReview;
        }

        Test.stopTest();

        firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            1,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 1, cause one review record exists in system'
        );
        System.assertEquals(
            5,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 5 for existing rating records'
        );
    }

    @IsTest
    static void testOneUserListInsert() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];

        Product2 firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];
        Product2 secondDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'Second device'];

        System.assertEquals(
            0,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 0, cause review records does not exist in system'
        );
        System.assertEquals(
            0,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 0 for existing rating records'
        );
        System.assertEquals(
            0,
            secondDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 0, cause review records does not exist in system'
        );
        System.assertEquals(
            0,
            secondDevice.Rating_Average__c,
            'Rating_Average__c field must be 0 for existing rating records'
        );

        NLSQTestUtils.ReviewFactory firstDeviceReview = new NLSQTestUtils.ReviewFactory(firstDevice);
        NLSQTestUtils.ReviewFactory secondDeviceReview = new NLSQTestUtils.ReviewFactory(secondDevice);

        List<Device_Review__c> deviceReviews = new List<Device_Review__c>{
            firstDeviceReview.getReview(firstUser.Id, 5),
            secondDeviceReview.getReview(firstUser.Id, 2)
        };

        Test.startTest();

        System.runAs(firstUser) {
            insert deviceReviews;
        }

        Test.stopTest();

        firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];
        secondDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'Second device'];

        System.assertEquals(
            1,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 1, cause one review record exists in system'
        );
        System.assertEquals(
            5,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 5 for existing rating records'
        );
        System.assertEquals(
            1,
            secondDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 1, cause one review record exists in system'
        );
        System.assertEquals(
            2,
            secondDevice.Rating_Average__c,
            'Rating_Average__c field must be 2 for existing rating records'
        );
    }

    @IsTest
    static void testOneProductListInsert() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];
        User secondUser = [SELECT Id FROM User WHERE Email = 'second.user.email@mail.com'];

        Product2 firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            0,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 0, cause review records does not exist in system'
        );
        System.assertEquals(
            0,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 0, cause review records does not exist in system'
        );

        NLSQTestUtils.ReviewFactory firstDeviceReviews = new NLSQTestUtils.ReviewFactory(firstDevice);

        List<Device_Review__c> deviceReviews = new List<Device_Review__c>{
            firstDeviceReviews.getReview(firstUser.Id, 5),
            firstDeviceReviews.getReview(secondUser.Id, 2)
        };

        Test.startTest();

        insert deviceReviews;

        Test.stopTest();

        firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            2,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 2, cause two review record exists in system'
        );
        System.assertEquals(
            3.5,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 3.5 for existing rating records'
        );
    }

    @IsTest
    static void testSingleUpdate() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];
        Product2 firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];

        NLSQTestUtils.ReviewFactory firstDeviceReviews = new NLSQTestUtils.ReviewFactory(firstDevice);

        Device_Review__c deviceReview = firstDeviceReviews.getReview(firstUser.Id, 5);
        insert deviceReview;

        Test.startTest();
        deviceReview.Rating__c = 4;
        update deviceReview;

        Test.stopTest();

        firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            1,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 1, cause one review record exists in system'
        );
        System.assertEquals(
            4,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 4 for existing rating records'
        );
    }

    @IsTest
    static void testSingleDelete() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];
        User secondUser = [SELECT Id FROM User WHERE Email = 'second.user.email@mail.com'];

        Product2 firstDevice = [SELECT Id FROM Product2 WHERE Name = 'First device'];

        NLSQTestUtils.ReviewFactory firstDeviceReview = new NLSQTestUtils.ReviewFactory(firstDevice);

        List<Device_Review__c> deviceReviews = new List<Device_Review__c>{
            firstDeviceReview.getReview(firstUser.Id, 5),
            firstDeviceReview.getReview(secondUser.Id, 2)
        };
        insert deviceReviews;

        firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];
        System.assertEquals(
            2,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 2, cause two review records exists in system'
        );
        System.assertEquals(
            3.5,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 3.5 for existing rating records'
        );

        Test.startTest();

        delete deviceReviews.get(0);

        Test.stopTest();

        firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            1,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 1, cause one review record exists in system'
        );
        System.assertEquals(
            2.0,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 2.0 for existing rating records'
        );
    }

    @IsTest
    static void testSingleUnDelete() {
        User firstUser = [SELECT Id FROM User WHERE Email = 'first.user.email@mail.com'];
        User secondUser = [SELECT Id FROM User WHERE Email = 'second.user.email@mail.com'];

        Product2 firstDevice = [SELECT Id FROM Product2 WHERE Name = 'First device'];

        NLSQTestUtils.ReviewFactory firstDeviceReviews = new NLSQTestUtils.ReviewFactory(firstDevice);

        List<Device_Review__c> deviceReviews = new List<Device_Review__c>{
            firstDeviceReviews.getReview(firstUser.Id, 5),
            firstDeviceReviews.getReview(secondUser.Id, 2)
        };
        insert deviceReviews;

        firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];
        System.assertEquals(
            2,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 2, cause two review records exists in system'
        );
        System.assertEquals(
            3.5,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 3.5 for existing rating records'
        );

        delete deviceReviews.get(0);

        Test.startTest();

        undelete deviceReviews.get(0);

        Test.stopTest();

        firstDevice = [SELECT Reviews_Count__c, Rating_Average__c FROM Product2 WHERE Name = 'First device'];

        System.assertEquals(
            2,
            firstDevice.Reviews_Count__c,
            'Reviews_Count__c field must be 2, cause two review records exists in system'
        );
        System.assertEquals(
            3.5,
            firstDevice.Rating_Average__c,
            'Rating_Average__c field must be 3.5 for existing rating records'
        );
    }
}