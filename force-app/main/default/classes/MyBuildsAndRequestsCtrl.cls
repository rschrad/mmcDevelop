public with sharing class MyBuildsAndRequestsCtrl {
    @AuraEnabled
    public static List<RequestWrapper> getRequests(Id userId, QueryParameters parameters) {
        try {
            return DeviceRequestService.getUserRequests(userId, parameters);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static Integer getRequestsCount(Id userId) {
        try {
            return DeviceRequestSelector.getUserRequestsCount(userId);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}