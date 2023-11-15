import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { showToast, handleError } from 'c/nlsqUtils';
import labels from './nlsqContactUsFormLabels';
import sendMessage from '@salesforce/apex/ContactUsCtrl.sendMessage';
import Id from '@salesforce/user/Id';
import uiFields from './nlsqUserFieldsApiNames';
import isGuestUser from '@salesforce/user/isGuest';

export default class NlsqContactUsForm extends LightningElement {
    @track contact = { FirstName: '', LastName: '', Email: '' };
    @track message = { Origin: 'Web', Status: 'New', ContactId: '', Subject: '', Description: '' };
    reCaptchaResponse;
    userId = Id;
    userFieldsData;
    hideFormFooter = false;
    isLoading = false;
    labels = labels;

    @wire(getRecord, { recordId: '$userId', fields: uiFields })
    userDetails({ error, data }) {
        if (data) {
            this.userFieldsData = data.fields;
            this.prepopulateUserFields();
        } else if (error) {
            handleError(this, error);
        }
    }

    prepopulateUserFields() {
        const fiedsValues = this.userFieldsData.ContactId.value
            ? this.userFieldsData.Contact.value.fields
            : this.userFieldsData;
        this.contact.FirstName = fiedsValues.FirstName.value;
        this.contact.LastName = fiedsValues.LastName.value;
        this.contact.Email = fiedsValues.Email.value;
        this.message.ContactId = this.userFieldsData.ContactId.value;
        this.disablePrepopulatedFields();
    }

    disablePrepopulatedFields() {
        this.template.querySelectorAll('.validate').forEach((item) => {
            if (this.contact[item.name]) {
                item.disabled = true;
            }
        });
    }

    handleReCaptcha(event) {
        this.reCaptchaResponse = event.detail;
    }

    setRequestField(event) {
        const obj = event.currentTarget.dataset.obj;
        const name = event.target.name;
        const value = event.detail.value;
        if (obj === 'Contact') {
            this.contact[name] = value;
        } else {
            this.message[name] = value;
        }
    }

    async sendMessage() {
        if (!this.reCaptchaResponse) {
            this.template.querySelector('c-nlsq-re-captcha').validate(false);
        }

        const isValid = this.validateRequiredFields();

        if (!isValid || !this.reCaptchaResponse) {
            return;
        }

        try {
            this.isLoading = true;
            const request = { cont: this.contact, cs: this.message };
            await sendMessage({
                contactRequest: request,
                uiResponse: this.reCaptchaResponse,
                isGuest: isGuestUser
            });
            this.postSendMessageActions();
        } catch (error) {
            this.reCaptchaResponse = '';
            this.template.querySelector('c-nlsq-re-captcha').reset();
            handleError(this, error);
        } finally {
            this.isLoading = false;
        }
    }

    validateRequiredFields() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');

        inputFields.forEach((inputField) => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        return isValid;
    }

    postSendMessageActions() {
        showToast(this, 'Success', this.labels.msgSuccessSendMessageCU, 'success', 'pester');
        this.disableAllInputs();
        this.hideFormFooter = true;
    }

    disableAllInputs() {
        this.template.querySelectorAll('.validate').forEach((item) => {
            item.disabled = true;
        });
    }
}