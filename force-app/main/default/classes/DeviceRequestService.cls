public inherited sharing class DeviceRequestService {
    public static List<RequestWrapper> getUserRequests(Id userId, QueryParameters parameters) {
        List<Device_Request__c> requests = DeviceRequestSelector.getUserRequests(userId, parameters);
        Set<Id> deviceIds = NLSQsObjectManager.mapIdFieldToSobject(requests, 'Device__c').keySet();
        Map<Id, String> deviceIdToImgUrl = ManagedContentService.getDeviceIdToContentKey(deviceIds);

        return createWrappers(requests, deviceIdToImgUrl);
    }

    private static List<RequestWrapper> createWrappers(
        List<Device_Request__c> requests,
        Map<Id, String> deviceIdToImgUrl
    ) {
        List<RequestWrapper> wrappers = new List<RequestWrapper>();

        for (Device_Request__c request : requests) {
            wrappers.add(new RequestWrapper(request, deviceIdToImgUrl.get(request.Device__c)));
        }

        return wrappers;
    }
}