@IsTest
public class SubmitDeviceCtrlTest {

    @TestSetup
    static void makeData() {
        User u = new User(Id = UserInfo.getUserId());
        System.runAs(u) {
            NLSQTestUtils.assignAdminPermissionSet();
        }
        List<ContentVersion> cvList = new List<ContentVersion>();
        NLSQTestUtils.ContentVersionFactory cvFactory = new NLSQTestUtils.ContentVersionFactory();
        Contact c = new NLSQTestUtils.ContactFactory().getContact('Test', 'usertest@gmail.com');
        insert c;
        User commU = new NLSQTestUtils.CommunityUserFactory().getUser(c);
        insert commU;
        for (Integer i = 0; i < 9; i++) {
            ContentVersion cv = cvFactory.getCV('TestDocument' + i);
            cvList.add(cv);
        }
        System.runAs(u) {
            insert cvList;
        }
    }

    @IsTest
    static void testSubmit() {
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());
        ProductCatalog catalog = new NLSQTestUtils.DeviceCatalogFactory().getDeviceCatalog('Catalog');
        insert catalog;
        String categoryName = NLSQConstants.SETTING.Category_Name__c;
        ProductCategory category = new NLSQTestUtils.DeviceCategoryFactory()
            .getDeviceCategory(categoryName, catalog.Id);
        insert category;
        String policyName = NLSQConstants.SETTING.Policy_Name__c;
        CommerceEntitlementPolicy policy = new NLSQTestUtils.CommerceEntitlementPolicyFactory().getRecord(policyName);
        insert policy;

        User commU = [SELECT Id FROM User WHERE Email = 'usertest@gmail.com'];

        List<ContentVersion> files = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Title LIKE 'TestDocument%'
        ];

        System.assertEquals(9, files.size(), 'Should have 9 ContentVersion records as initial data.');
        Integer i = 0;
        for (ContentVersion file : files) {
            file.Title = System.Label.hProductDetailImage + i;
            i += 1;
        }
        files[0].Title = System.Label.hProductListImage;

        Id recordId;
        Test.startTest();
        System.runAs(commU) {
            recordId = SubmitDeviceCtrl.submit(new Product2(Name = 'Test1'), files, null);
        }
        Test.stopTest();

        Product2 actual = [SELECT Name FROM Product2 WHERE Id = :recordId];
        System.assertNotEquals(null, actual, 'Should create product');
        System.assertEquals('Test1', actual.Name, 'Created product name should be \'Test1\'.');

        List<ContentVersion> actualFiles = [
            SELECT Id
            FROM ContentVersion
            WHERE Title LIKE :System.Label.hProductDetailImage + '%' OR Title = :System.Label.hProductListImage
        ];
        System.assertEquals(9, actualFiles.size(), 'Should update 9 files titles.');

        List<Id> cdIds = new List<Id>();
        for (ContentVersion cv : files) {
            cdIds.add(cv.ContentDocumentId);
        }
        List<ContentDocumentLink> cdLinks = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :cdIds AND LinkedEntityId = :recordId
        ];
        System.assertEquals(9, cdLinks.size(), 'Should create 9 ContentDocumentLink records for Product Id.');

        List<ProductCategoryProduct> pcp = [
            SELECT Id
            FROM ProductCategoryProduct
            WHERE ProductId = :recordId AND ProductCategoryId = :category.Id
        ];
        String msg = 'Should create 1 ProductCategoryProduct record for Product with specified ProductCategoryId.';
        System.assertEquals(1, pcp.size(), msg);

        List<CommerceEntitlementProduct> cep = [
            SELECT Id
            FROM CommerceEntitlementProduct
            WHERE ProductId = :recordId AND PolicyId = :policy.Id
        ];
        msg = 'Should create 1 CommerceEntitlementProduct record for Product with specified PolicyId.';
        System.assertEquals(1, cep.size(), msg);
    }

    @IsTest
    static void testSubmitCaptchaError() {
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockError());
        String errorMsg;

        Test.startTest();
        try {
            SubmitDeviceCtrl.submit(null, null, null);
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Failed to validate ReCaptcha.', errorMsg, 'Should throw recaptcha error');
    }

    @IsTest
    static void testSubmitError() {
        Test.setMock(HttpCalloutMock.class, new ReCaptchaMockSuccess());
        String errorMsg;

        Test.startTest();
        try {
            SubmitDeviceCtrl.submit(null, null, null);
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(
            'Attempt to de-reference a null object',
            errorMsg,
            'null object exception should be thrown'
        );
    }

    @IsTest
    static void testGetFormFields() {
        User commU = [SELECT Id FROM User WHERE Email = 'usertest@gmail.com'];

        Map<String, List<PicklistItem>> fields;
        Test.startTest();
        System.runAs(commU) {
            fields = SubmitDeviceCtrl.getFormFields();
        }
        Test.stopTest();

        String msgPrefix = NLSQTestUtils.RECORD_ASSERTION_MSG_PREFIX;
        System.assertEquals(4, fields.size(), 'Should return 3 Form Fields entries.');
        System.assert(fields.containsKey('Device_Category__c'), msgPrefix + '(Device_Category__c)');
        System.assert(fields.containsKey('Disability_Type__c'), msgPrefix + '(Disability_Type__c)');

        List<PicklistItem> capabilities = fields.get('Projects_Skills__c');
        System.assertEquals(9, capabilities.size(), 'Should have 9 options for Projects_Skills__c field.');

        List<PicklistItem> projectsNeeds = fields.get('Disability_Type__c');
        System.assertEquals(9, projectsNeeds.size(), 'Should have 9 options for Disability_Type__c field.');

        List<PicklistItem> licenses = fields.get('License__c');
        System.assertEquals(8, licenses.size(), 'Should have 8 options for License__c field.');

    }
}