import { LightningElement, api } from 'lwc';
import getSiteKey from '@salesforce/apex/ReCaptchaCtrl.getSiteKey';

export default class NlsqReCaptcha extends LightningElement {
    @api errorMsg;
    @api required;

    connectedCallback() {
        document.addEventListener('grecaptchaVerified', (e) => {
            this.change(e.detail.response);
            this.validate(true);
        });

        document.addEventListener('grecaptchaExpired', () => {
            this.change(null);
        });
    }

    renderedCallback() {
        getSiteKey()
            .then((key) => {
                const reCaptcha = this.template.querySelector('[data-id="reCaptcha"]');

                document.dispatchEvent(
                    new CustomEvent('grecaptchaRender', { detail: { element: reCaptcha, sitekey: key } })
                );
            })
            .catch((error) => console.log(error));
    }

    disconnectedCallback() {
        document.removeEventListener('grecaptchaVerified');
        document.removeEventListener('grecaptchaExpired');
    }

    change(value) {
        this.dispatchEvent(
            new CustomEvent('change', {
                detail: value
            })
        );
    }

    @api
    reset() {
        document.dispatchEvent(new CustomEvent('grecaptchaReset'));
    }

    @api
    validate(isResponse) {
        if (!this.required) return;

        const field = this.template.querySelector(`[data-name="reCaptcha"]`);
        const errorField = this.template.querySelector(`[data-name="reCaptcha-error"]`);

        if (isResponse) {
            field.classList.remove('slds-has-error');
            errorField.classList.add('slds-hide');
        } else {
            field.classList.add('slds-has-error');
            errorField.classList.remove('slds-hide');
        }
    }
}