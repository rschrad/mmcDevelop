public with sharing class MyDevicesCtrl {
    @AuraEnabled
    public static Integer getDevicesCount(Id userId) {
        try {
            return DeviceSelector.getDevicesCount(userId, 'Designer__c');
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static List<DeviceWrapper> getDevices(Id userId, QueryParameters queryParams) {
        try {
            return DeviceService.getAllDevices(userId, 'Designer__c', queryParams);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}