public class DeviceWrapper {
    @AuraEnabled
    public Product2 device;
    @AuraEnabled
    public String imageUrl;

    public DeviceWrapper(Product2 device, String imageUrl) {
        this.device = device;
        this.imageUrl = imageUrl;
    }
}