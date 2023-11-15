@IsTest
public class MyReviewsCtrlTest {
    private static final String COMMUITY_USER_EMAIL_1 = 'first.user.email@mail.com';
    private static final String COMMUITY_USER_EMAIL_2 = 'second.user.email@mail.com';
    @TestSetup
    static void makeData() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }
        NLSQTestUtils.DeviceFactory df = new NLSQTestUtils.DeviceFactory();
        Product2 device = df.getDevice('Test1');
        device.IsActive = true;
        NLSQTestUtils.insertRecords(new List<Product2>{ device });

        NLSQTestUtils.ContactFactory cf = new NLSQTestUtils.ContactFactory();
        Contact contact = cf.getContact('Test1', COMMUITY_USER_EMAIL_1);
        NLSQTestUtils.insertRecords(new List<Contact>{ contact });

        NLSQTestUtils.CommunityUserFactory uf = new NLSQTestUtils.CommunityUserFactory();
        User testCommunityUser = uf.getUser(contact);
        NLSQTestUtils.insertRecords(new List<User>{ testCommunityUser });
        NLSQTestUtils.ReviewFactory rf = new NLSQTestUtils.ReviewFactory(device);

        System.runAs(testCommunityUser) {
            Device_Review__c review = rf.getReview(testCommunityUser.Id, 5);
            review.Review_Body__c = 'review body';
            insert review;
        }

        Contact contact2 = cf.getContact('Test2', COMMUITY_USER_EMAIL_2);
        NLSQTestUtils.insertRecords(new List<Contact>{ contact2 });

        User testCommunityUser2 = uf.getUser(contact2);
        NLSQTestUtils.insertRecords(new List<User>{ testCommunityUser2 });

        System.runAs(testCommunityUser2) {
            Device_Review__c review = rf.getReview(testCommunityUser2.Id, 5);
            review.Review_Body__c = 'review body';
            insert review;
        }
    }

    @IsTest
    static void testGetReviewsCount() {
        User testUser = [SELECT Id FROM USER WHERE EMAIL = :COMMUITY_USER_EMAIL_1];
        Integer reviewsCount;
        Test.startTest();
        System.runAs(testUser) {
            reviewsCount = MyReviewsCtrl.getReviewsCount(testUser.Id);
        }
        Test.stopTest();
        System.assertEquals(1, reviewsCount, 'The number of reviews must equal 1');
    }

    @IsTest
    static void testGetReviewsCountError() {
        User testUser = [SELECT Id FROM USER WHERE EMAIL = :COMMUITY_USER_EMAIL_1];
        String errorMsg;
        Test.startTest();
        System.runAs(testUser) {
            try {
                MyReviewsCtrl.getReviewsCount(null);
            } catch (Exception ex) {
                errorMsg = ex.getMessage();
            }
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
        User testUser = [SELECT Id FROM USER WHERE EMAIL = :COMMUITY_USER_EMAIL_1];
        List<Device_Review__c> reviews;
        Test.startTest();
        System.runAs(testUser) {
            reviews = MyReviewsCtrl.getReviews(testUser.Id, new QueryParameters(5, 0, null));
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
        User testUser = [SELECT Id FROM USER WHERE EMAIL = :COMMUITY_USER_EMAIL_1];
        String errorMsg;
        Test.startTest();
        System.runAs(testUser) {
            try {
                MyReviewsCtrl.getReviews(null, new QueryParameters());
            } catch (Exception ex) {
                errorMsg = ex.getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(
            'Property recordId can not be null.',
            errorMsg,
            'exception with invalid ID should be thrown'
        );
    }
}