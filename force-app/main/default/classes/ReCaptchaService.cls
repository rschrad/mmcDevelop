public inherited sharing class ReCaptchaService {
    @TestVisible
    private static final String ERROR_MSG = Label.RecaptchaError;
    private static final String METADATA_INSTANCE_NAME = Test.isRunningTest() && NLSQTestUtils.testError
        ? 'Tests'
        : 'Config';

    private static final ReCaptcha_Config__mdt RE_CAPTCHA_CONFIG = ReCaptcha_Config__mdt.getInstance(
        METADATA_INSTANCE_NAME
    );

    public static String getSiteKey() {
        return RE_CAPTCHA_CONFIG.SiteKey__c;
    }

    public static void verifyResponse(String uiResponse) {
        ReCaptchaCallout callout = new ReCaptchaCallout(RE_CAPTCHA_CONFIG);

        HttpResponse response = callout.verify(uiResponse);

        ReCaptchaResponse captchaResponse = (ReCaptchaResponse) JSON.deserialize(
            response.getBody(),
            ReCaptchaResponse.class
        );

        if (!captchaResponse.success) {
            throw new ReCaptchaException(ERROR_MSG);
        }
    }

    class ReCaptchaException extends Exception {
    }
}