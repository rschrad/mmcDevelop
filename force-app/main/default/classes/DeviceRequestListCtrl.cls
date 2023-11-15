public with sharing class DeviceRequestListCtrl {
    @AuraEnabled
    public static List<SortingFieldWrapper> getDeviceRequestFilterFields() {
        List<SortingFieldWrapper> listFields = new List<SortingFieldWrapper>();
        for (String key : NLSQConstants.DEVICE_REQUEST_LIST_SORTING_FIELDS.keySet()) {
            listFields.add(new SortingFieldWrapper(key, NLSQConstants.DEVICE_REQUEST_LIST_SORTING_FIELDS.get(key)));
        }
        return listFields;
    }

    @AuraEnabled
    public static Integer getDeviceRequestsCount(Map<String, String> filteringFieldToValue) {
        try {
            return DeviceRequestSelector.getDisplayedDeviceRequestsCount(filteringFieldToValue);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

    @AuraEnabled
    public static List<Device_Request__c> getDeviceRequests(
        QueryParameters queryParams,
        Map<String, String> filteringFieldToValue
    ) {
        try {
            return DeviceRequestSelector.getDisplayedDeviceRequests(queryParams, filteringFieldToValue);
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }
}