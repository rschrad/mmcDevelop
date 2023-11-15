public inherited sharing class DeviceUtils {
    public static Id getDefaultDevicesCategoryId() {
        return [
            SELECT Id
            FROM ProductCategory
            WHERE Name = :NLSQConstants.SETTING.Category_Name__c
            WITH SECURITY_ENFORCED
            LIMIT 1
        ]
        .Id;
    }

    public static Id getCommerceEntitlementPolicyId() {
        return [SELECT Id FROM CommerceEntitlementPolicy WHERE Name = :NLSQConstants.SETTING.Policy_Name__c LIMIT 1].Id;
    }

    public static Id getUserLike(Id recordId) {
        List<Device_Like__c> likes = [
            SELECT Id
            FROM Device_Like__c
            WHERE Device__c = :recordId AND OwnerId = :UserInfo.getUserId()
            WITH SECURITY_ENFORCED
        ];
        return likes.size() > 0 ? likes.get(0).Id : null;
    }

    public static Id getDeviceRequestRecordType() {
        return Schema.SObjectType.Device_Request__c.getRecordTypeInfosByDeveloperName()
            .get(NLSQConstants.SETTING?.Device_Request_RecordType_Name__c)
            ?.getRecordTypeId();
    }
}