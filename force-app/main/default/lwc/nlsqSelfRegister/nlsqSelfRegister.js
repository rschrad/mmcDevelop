import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import labels from './nlsqSelfRegisterLabels.js';
import getPortalRoles from '@salesforce/apex/SelfRegisterCtrl.getPortalRoles';
import registerUser from '@salesforce/apex/SelfRegisterCtrl.registerUser';
import { navigateToWebPage } from 'c/nlsqUtils';
import { validateField, validateRequiredFields } from './nlsqSelfRegisterHelper';

const validRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;

export default class NlsqSelfRegister extends NavigationMixin(LightningElement) {
    @api privacyUrl;
    @api termsUrl;
    @api checkPasswordUrl;
    labels = labels;
    emailErrorMsg = this.labels.completeFieldLabel;
    isLoading = true;

    @track agreementFields = {
        terms: false,
        privacy: false,
        subscription: false
    };
    rolesOptions = [];
    rolesValue = [];
    reCaptchaResponse;
    statesByCountry;
    country;
    state;

    @track currentContact = {
        HasOptedOutOfEmail: true
    };

    @wire(getPortalRoles)
    wiredRoles({ data, error }) {
        if (data) {
            this.rolesOptions = data;
        } else if (error) {
            this.template.querySelector('c-nlsq-toast').showToast({
                type: 'error',
                message: error.body.message
            });
            console.error(error);
        }
    }

    connectedCallback() {
        this.isLoading = false;
    }

    handleSelfRegister() {
        if (!this.reCaptchaResponse) {
            this.template.querySelector('c-nlsq-re-captcha').validate(false);
        }

        const isValid = validateRequiredFields(this);

        if (!isValid || !this.reCaptchaResponse) {
            return;
        }

        this.isLoading = true;
        const currentContact = this.currentContact;

        registerUser({
            currentContact: currentContact,
            captchaResponse: this.reCaptchaResponse
        })
            .then(() => {
                this.isLoading = false;
                navigateToWebPage(this, this.checkPasswordUrl);
            })
            .catch((error) => {
                this.reCaptchaResponse = '';
                this.template.querySelector('c-nlsq-re-captcha').reset();
                this.template.querySelector('c-nlsq-toast').showToast({
                    type: 'error',
                    message: error.body.message
                });
                console.error(error);
                this.isLoading = false;
            });
    }

    setContactField(e) {
        this.emailErrorMsg = this.labels.completeFieldLabel;
        const name = e.target.name;
        const type = e.target.type;
        let data = e.target.value;

        if (Array.isArray(data)) {
            this.rolesValue = data;
            data = data.join(';');
        }

        if (type === 'checkbox') {
            data = !e.target.checked;
        }
        this.currentContact[name] = data;

        validateField(this, name, data);
    }

    setAgreementField(e) {
        const name = e.target.name;
        const data = e.target.checked;
        this.agreementFields[name] = data;

        validateField(this, name, data);
    }

    setStatesByCountry({ detail }) {
        this.statesByCountry = detail;
    }

    setAddressField({ detail: { value, name, code } }) {
        this.currentContact[name] = code;

        if (name === 'MailingCountryCode') {
            this.country = value;
            this.currentContact.MailingStateCode = null;
        } else {
            this.state = value;
        }
    }

    validateEmail(e) {
        this.emailErrorMsg = this.labels.validEmailLabel;
        const data = e.target.value.match(validRegex);
        validateField(this, 'Email', data);
    }

    getReCaptchaResponse(e) {
        this.reCaptchaResponse = e.detail;
    }
}