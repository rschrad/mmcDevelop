public with sharing class MainDeviceInfoCtrl {
    @AuraEnabled
    public static Product2 getDeviceInfo(Id recordId) {
        try {
            return DeviceSelector.getDeviceInfo(recordId);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static String getUserLike(Id recordId) {
        try {
            return DeviceUtils.getUserLike(recordId);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static void updateCount(Id recordId, String field) {
        try {
            DeviceService.updateCount(recordId, field);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}