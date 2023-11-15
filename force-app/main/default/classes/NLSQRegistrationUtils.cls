@SuppressWarnings('PMD.ApexCrudViolation')
public without sharing class NLSQRegistrationUtils {
    public static List<BuyerGroup> getDefaultBuyerGroup() {
        return [
            SELECT Id
            FROM BuyerGroup
            WHERE Name = :NLSQConstants.SETTING.Buyer_Group_Name__c
            LIMIT 1
        ];
    }

    public static Profile getCommunityProfile() {
        return [
            SELECT Id
            FROM Profile
            WHERE Name = :NLSQConstants.SETTING.Community_Profile_Name__c
        ];
    }

    public static Organization getOgrDefaults() {
        return [
            SELECT TimeZoneSidKey, DefaultLocaleSidKey, LanguageLocaleKey
            FROM Organization
        ];
    }

    public static List<User> getUserByUsername(String username) {
        return [SELECT Id FROM User WHERE Username = :username AND IsActive = TRUE];
    }

    public static List<PermissionSet> getPermissionSetsByNames(List<String> permissionSetsNames) {
        return [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetsNames];
    }

    public static User getUserAccount(Id userId) {
        User user = [
            SELECT Account.Id, Account.Name
            FROM User
            WHERE Id = :userId AND AccountId != NULL
            LIMIT 1
        ];

        return user;
    }
}