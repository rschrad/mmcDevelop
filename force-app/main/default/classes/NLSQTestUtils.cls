@IsTest
public without sharing class NLSQTestUtils {
    private static final Profile COMMUNITY_PROFILE = NLSQRegistrationUtils.getCommunityProfile();
    private static final PermissionSet ADMIN_PERMISSION_SET = [
        SELECT Id
        FROM PermissionSet
        WHERE Name = 'Neil_Squire_Internal_Admin'
    ];
    public static Boolean testError = false;
    public static final String RECORD_ASSERTION_MSG_PREFIX = 'Value should match with original value: ';

    public class ContactFactory {
        private final Contact defaultContact = new Contact(FirstName = 'Contact', MailingCountryCode = 'US');

        public Contact getContact(String lastName, String contactEmail) {
            Contact currentContact = defaultContact.clone();
            currentContact.LastName = lastName;
            currentContact.Email = contactEmail;

            return currentContact;
        }
    }

    public class ContentVersionFactory {
        public ContentVersion getCV(String name) {
            return new ContentVersion(
                Title = name,
                PathOnClient = name,
                VersionData = Blob.valueOf(name),
                IsMajorVersion = true
            );
        }
    }

    public class CommerceEntitlementPolicyFactory {
        public CommerceEntitlementPolicy getRecord(String name) {
            return new CommerceEntitlementPolicy(Name = name);
        }
    }

    public class GuestUserFactory {
        Profile guestProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'MMC Web Profile'
            LIMIT 1
        ];

        public User getGuestUser() {
            return new User(
                Email = 'guest.uset@test.com',
                Username = 'guest.uset@test.com',
                FirstName = 'Guest',
                LastName = 'User',
                Alias = 'User',
                ProfileId = this.guestProfile.Id,
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'GMT',
                EmailEncodingKey = 'UTF-8'
            );
        }
    }

    public class CommunityUserFactory {
        private final User defaultUser = new User(
            ProfileId = COMMUNITY_PROFILE.Id,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            EmailEncodingKey = 'UTF-8'
        );

        public User getUser(Contact c) {
            User currentUser = defaultUser.clone();
            currentUser.ContactId = c.Id;
            currentUser.Email = c.Email;
            currentUser.Username = c.Email;
            currentUser.FirstName = c.FirstName;
            currentUser.LastName = c.LastName;
            currentUser.Alias = c.LastName;

            return currentUser;
        }
    }

    public class DeviceFactory {
        private final Product2 defaultDevice = new Product2(
            User_Value_Statement__c = 'User Value',
            Downloads_Count__c = 10,
            Shares_Count__c = 15,
            Views_Count__c = 150
        );

        public Product2 getDevice(String deviceName) {
            Product2 newDevice = defaultDevice.clone();
            newDevice.Designer__c = UserInfo.getUserId();
            newDevice.Name = deviceName;

            return newDevice;
        }
    }

    public class DeviceRequestFactory {
        private final Device_Request__c defaultDeviceRequest = new Device_Request__c(
            Country__c = 'Canada',
            City__c = 'Ottawa',
            Request_Notes__c = 'Message'
        );

        public Device_Request__c getDeviceRequest(Id deviceId) {
            Device_Request__c newDeviceRequest = defaultDeviceRequest.clone();
            newDeviceRequest.Device__c = deviceId;
            return newDeviceRequest;
        }
    }

    public class DeviceCatalogFactory {
        private final ProductCatalog defaultCatalog = new ProductCatalog();

        public ProductCatalog getDeviceCatalog(String deviceCatalogName) {
            ProductCatalog newCatalog = defaultCatalog.clone();
            newCatalog.Name = deviceCatalogName;

            return newCatalog;
        }
    }

    public class DeviceCategoryFactory {
        private final ProductCategory defaultCategory = new ProductCategory();

        public ProductCategory getDeviceCategory(String deviceCategoryName, String deviceCatalogId) {
            ProductCategory newCategory = defaultCategory.clone();
            newCategory.Name = deviceCategoryName;
            newCategory.CatalogId = deviceCatalogId;
            return newCategory;
        }
    }

    public class DeviceCategoryDeviceFactory {
        private final ProductCategoryProduct defaultDeviceCategoryDevice = new ProductCategoryProduct();

        public ProductCategoryProduct getDeviceCategoryDevice(String categoryId, String productId) {
            ProductCategoryProduct newDeviceCategoryDevice = defaultDeviceCategoryDevice.clone();
            newDeviceCategoryDevice.ProductCategoryId = categoryId;
            newDeviceCategoryDevice.ProductId = productId;

            return newDeviceCategoryDevice;
        }
    }

    public class LikeFactory {
        private final Product2 device;

        public LikeFactory(Product2 device) {
            this.device = device;
        }

        public Device_Like__c getLike(Id ownerId) {
            return new Device_Like__c(Device__c = device.Id, OwnerId = ownerId);
        }
    }

    public class ReviewFactory {
        private final Product2 device;

        public ReviewFactory(Product2 device) {
            this.device = device;
        }

        public Device_Review__c getReview(Id ownerId, Integer rating) {
            return new Device_Review__c(Device__c = device.Id, OwnerId = ownerId, Rating__c = rating);
        }
    }

    public class AuthUserDataFactory {
        private final Map<String, String> attributes = new Map<String, String>();

        private final Auth.UserData defaultUserData = new Auth.UserData(
            '222',
            'User',
            'Test',
            'User Test',
            'usertest@gmail.com',
            'https://',
            'usertest@gmail.com',
            'UK',
            'provider',
            'https://login',
            attributes
        );

        public Auth.UserData getAuthUserData() {
            return defaultUserData;
        }
    }

    public static List<SObject> insertRecords(List<SObject> records) {
        insert records;
        return records;
    }

    public static List<SObject> updateRecords(List<SObject> records) {
        update records;
        return records;
    }

    public static void assignAdminPermissionSet() {
        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId = :ADMIN_PERMISSION_SET.Id
        ];

        if (permissionSetAssignments.isEmpty()) {
            insert new PermissionSetAssignment(
                AssigneeId = UserInfo.getUserId(),
                PermissionSetId = ADMIN_PERMISSION_SET.Id
            );
        }
    }
}