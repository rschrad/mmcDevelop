public class DeviceService {
    public static void updateCount(Id recordId, String field) {
        if (!NLSQConstants.PRODUCT_UPDATE_COUNT_FIELDS.contains(field)) {
            throw new DmlException('Invalid field for count update: ' + field);
        }

        Product2 product = DeviceSelector.getDeviceField(recordId, field);
        Decimal value = (Decimal) product.get(field);
        value = value == null ? 1 : value + 1;
        product.put(field, value);
        NLSQDMLServiceWS.updateRecord(product);
    }

    public static List<PicklistItem> getDevicesPicklist() {
        List<Product2> devices = DeviceSelector.getActiveDevicesByDefaultCategory();

        List<PicklistItem> devicePicklist = new List<PicklistItem>();
        for (Product2 device : devices) {
            devicePicklist.add(new PicklistItem(device.Name, device.Id));
        }

        return devicePicklist;
    }

    public static Id submitDevice(Product2 product, List<ContentVersion> contentVersions) {
        NLSQDMLServiceWS.insertRecord(product);

        ProductCategoryProduct pcp = new ProductCategoryProduct();
        pcp.ProductId = product.Id;
        pcp.ProductCategoryId = DeviceUtils.getDefaultDevicesCategoryId();
        NLSQDMLServiceWS.insertRecord(pcp);

        CommerceEntitlementProduct cep = new CommerceEntitlementProduct();
        cep.ProductId = product.Id;
        cep.PolicyId = DeviceUtils.getCommerceEntitlementPolicyId();
        NLSQDMLServiceWS.insertRecord(cep);

        FileService.processDeviceFiles(product.Id, contentVersions);
        return product.Id;
    }

    public static List<DeviceWrapper> getAllDevices(Id userId, String filterField, QueryParameters queryParams) {
        Map<Id, Product2> devices = DeviceSelector.getDevicesAsMap(userId, filterField, queryParams);
        Map<Id, String> devicesContentKeys = ManagedContentService.getDeviceIdToContentKey(devices.keySet());
        List<DeviceWrapper> allDevices = getWrappedDevices(devices, devicesContentKeys);
        return allDevices;
    }

    private static List<DeviceWrapper> getWrappedDevices(
        Map<Id, Product2> devices,
        Map<Id, String> devicesContentKeys
    ) {
        List<DeviceWrapper> wrappedDevices = new List<DeviceWrapper>();

        for (Product2 item : devices.values()) {
            if (devicesContentKeys.containsKey(item.Id)) {
                wrappedDevices.add(new DeviceWrapper(item, devicesContentKeys.get(item.Id)));
            }
        }
        return wrappedDevices;
    }
}