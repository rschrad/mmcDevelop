public with sharing class MyReviewsCtrl {
    @AuraEnabled
    public static Integer getReviewsCount(Id userId) {
        try {
            return DeviceReviewSelector.getReviewsCount(userId, 'OwnerId');
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static List<Device_Review__c> getReviews(Id userId, QueryParameters queryParams) {
        try {
            return DeviceReviewSelector.getReviews(userId, 'OwnerId', queryParams);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}