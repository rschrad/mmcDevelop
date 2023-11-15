public inherited sharing class ManagedContentService {
    public static Map<Id, String> getDeviceIdToContentKey(Set<Id> deviceIds) {
        Map<Id, String> idToKey = new Map<Id, String>();
        List<Id> contentIds = new List<Id>();
        String defaultKey = NLSQConstants.DEFAULT_DEVICE_IMG_URL;
        List<ProductMedia> productMedias = DeviceMediaSelector.getDeviceMedias(deviceIds);
        Map<Id, SObject> deviceIdToMedia = NLSQsObjectManager.mapIdFieldToSobject(productMedias, 'ProductId');
        Map<Id, SObject> contentIdToProductMedia = NLSQsObjectManager.mapIdFieldToSobject(
            productMedias,
            'ElectronicMediaId'
        );

        for (Id deviceId : deviceIds) {
            if (deviceIdToMedia.containsKey(deviceId)) {
                ProductMedia pMedia = (ProductMedia) deviceIdToMedia.get(deviceId);
                contentIds.add(pMedia.ElectronicMediaId);
            } else {
                idToKey.put(deviceId, defaultKey);
            }
        }

        if (!contentIds.isEmpty()) {
            ConnectApi.ManagedContentVersionCollection versionCollection = getVersionCollection(contentIds);
            idToKey.putAll(getDevisesUrls(versionCollection, contentIdToProductMedia));
        }

        return idToKey;
    }

    @TestVisible
    private static ConnectApi.ManagedContentVersionCollection getVersionCollection(List<Id> contentIds) {
        return ConnectApi.ManagedContent.getManagedContentByIds(
            Network.getNetworkId(),
            contentIds,
            null,
            null,
            UserInfo.getLanguage(),
            null,
            null
        );
    }

    @TestVisible
    private static Map<Id, String> getDevisesUrls(
        ConnectApi.ManagedContentVersionCollection versionCollection,
        Map<Id, SObject> contentIdToProductMedia
    ) {
        Map<Id, String> idToKey = new Map<Id, String>();

        ProductMedia pMedia;
        List<ConnectApi.ManagedContentMediaSourceNodeValue> mediaSourceNodes = new List<ConnectApi.ManagedContentMediaSourceNodeValue>();
        for (ConnectApi.ManagedContentVersion versionItems : versionCollection.items) {
            pMedia = (ProductMedia) contentIdToProductMedia.get(versionItems.managedContentId);
            mediaSourceNodes.add(
                (ConnectApi.ManagedContentMediaSourceNodeValue) versionItems.contentNodes.get('source')
            );

            for (ConnectApi.ManagedContentMediaSourceNodeValue nodeValue : mediaSourceNodes) {
                idToKey.put(pMedia.ProductId, nodeValue.url);
            }
        }

        return idToKey;
    }
}