public inherited sharing class DeviceMediaSelector {
    public static List<ProductMedia> getDeviceMedias(Set<Id> deviceIds) {
        return [
            SELECT ElectronicMediaId, ProductId
            FROM ProductMedia
            WHERE ProductId IN :deviceIds AND ElectronicMediaGroup.Name = 'Product List Image'
            WITH SECURITY_ENFORCED
        ];
    }
}