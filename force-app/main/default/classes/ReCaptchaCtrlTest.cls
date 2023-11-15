@IsTest
public class ReCaptchaCtrlTest {
    @IsTest
    static void getSiteKey() {
        Test.startTest();
        String key = ReCaptchaCtrl.getSiteKey();
        Test.stopTest();

        System.assertEquals(null, key, 'empty key on deployment');
    }

    @IsTest
    static void getSiteKeyError() {
        NLSQTestUtils.testError = true;
        String errorMsg;

        Test.startTest();

        try {
            ReCaptchaCtrl.getSiteKey();
        } catch (Exception ex) {
            errorMsg = ex.getMessage();
        }

        Test.stopTest();

        System.assertEquals('Attempt to de-reference a null object', errorMsg, 'error message cause data not found');
    }
}