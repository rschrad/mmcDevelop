public class ReCaptchaCallout extends NLSQCallout {
    private final ReCaptcha_Config__mdt metadata;

    public ReCaptchaCallout(ReCaptcha_Config__mdt metadata) {
        this.metadata = metadata;
    }

    public HttpResponse verify(String uiResponse) {
        HttpRequestBuilder builder = getBuilder();

        builder.setEndpoint(metadata.Url__c);
        builder.setMethod('POST');
        builder.setBody('secret=' + metadata.SecretKey__c + '&response=' + uiResponse);

        HttpRequest request = builder.build();
        return sendRequest(request);
    }
}