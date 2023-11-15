public with sharing class DeviceReviewsCtrl {
    @AuraEnabled
    public static Integer getReviewsCount(Id recordId) {
        try {
            return DeviceReviewSelector.getReviewsCount(recordId, 'Device__c');
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static List<Device_Review__c> getReviews(Id recordId, QueryParameters queryParams) {
        try {
            return DeviceReviewSelector.getReviews(recordId, 'Device__c', queryParams);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}