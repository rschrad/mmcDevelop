@SuppressWarnings('PMD.ApexCrudViolation, PMD.EmptyStatementBlock')
public inherited sharing class DeviceLikeTriggerHandler implements ITriggerHandler {
    public void beforeInsert(List<SObject> newItems) {
        setUserDeviceUniqValues(newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        setUserDeviceUniqValues(newItems.values());
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        /*not logic on before delete*/
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        calculateLikesCount(newItems.values(), true);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        /*cannot change device and dont need recalculation*/
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        calculateLikesCount(oldItems.values(), false);
    }

    public void afterUndelete(Map<Id, SObject> newItems) {
        calculateLikesCount(newItems.values(), true);
    }

    private static void calculateLikesCount(List<Device_Like__c> likes, Boolean isAdd) {
        Map<Id, List<SObject>> deviceIdToLikes = NLSQsObjectManager.mapIdFieldToListSobject(likes, 'Device__c');

        List<Product2> devices = [
            SELECT Likes_Count__c
            FROM Product2
            WHERE Id IN :deviceIdToLikes.keySet()
        ];

        for (Product2 device : devices) {
            List<Device_Like__c> dLikes = (List<Device_Like__c>) deviceIdToLikes.get(device.Id);
            Integer likesCount = dLikes.size();

            if (device.Likes_Count__c == null) {
                device.Likes_Count__c = 0;
            }

            device.Likes_Count__c = isAdd ? (device.Likes_Count__c + likesCount) : (device.Likes_Count__c - likesCount);
        }

        update devices;
    }

    private static void setUserDeviceUniqValues(List<Device_Like__c> likes) {
        for (Device_Like__c deviceLike : likes) {
            deviceLike.User_Device__c = deviceLike.OwnerId + ':' + deviceLike.Device__c;
        }
    }
}