@IsTest
public class DeviceReviewsCtrlTest {
    @TestSetup
    static void makeData() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }
        NLSQTestUtils.DeviceFactory df = new NLSQTestUtils.DeviceFactory();
        Product2 device = df.getDevice('Test1');
        NLSQTestUtils.insertRecords(new List<Product2>{ device });

        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        Contact contact = cf.getContact('Test1', 'first.user.email@mail.com');
        NLSQTestUtils.insertRecords(new List<Contact>{ contact });

        NLSQTestUtils.CommunityUserFactory uf = new NLSQTestUtils.CommunityUserFactory();
        User testUser = uf.getUser(contact);
        NLSQTestUtils.insertRecords(new List<User>{ testUser });

        NLSQTestUtils.ReviewFactory rf = new NLSQTestUtils.ReviewFactory(device);
        Device_Review__c review = rf.getReview(testUser.Id, 5);
        review.Review_Body__c = 'review body';
        insert review;
    }

    @IsTest
    static void testGetReviewsCount() {
        Id recordId = [SELECT Id FROM Product2 WHERE Name = 'Test1' LIMIT 1].Id;
        Integer reviewsCount;
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            reviewsCount = DeviceReviewsCtrl.getReviewsCount(recordId);
        }
        Test.stopTest();

        System.assertEquals(1, reviewsCount, 'Should return 1, because 1 review record was created for device.');
    }

    @IsTest
    static void testGetReviewsCountError() {
        String errorMsg;

        Test.startTest();
        try {
            DeviceReviewsCtrl.getReviewsCount(null);
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

    @IsTest
    static void testGetReviews() {
        Id recordId = [SELECT Id FROM Product2 WHERE Name = 'Test1' LIMIT 1].Id;
        List<Device_Review__c> reviews;
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            reviews = DeviceReviewsCtrl.getReviews(recordId, new QueryParameters(5, 0, null));
        }
        Test.stopTest();

        System.assertEquals(1, reviews.size(), 'Returned list should have 1 record.');
        Device_Review__c review = reviews[0];
        String msgPrefix = NLSQTestUtils.RECORD_ASSERTION_MSG_PREFIX;

        System.assertNotEquals(null, review, 'Record should be returned.');
        System.assertEquals(Date.today(), review.CreatedDate.date(), msgPrefix + '(Device_Review__c.CreatedDate)');
        System.assertEquals('Contact Test1', review.Owner.Name, msgPrefix + '(Device_Review__c.Owner.Name)');
        System.assertEquals('review body', review.Review_Body__c, msgPrefix + '(Device_Review__c.Review_Body__c)');
    }

    @IsTest
    static void testGetReviewsError() {
        String errorMsg;

        Test.startTest();
        try {
            DeviceReviewsCtrl.getReviews(null, new QueryParameters());
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