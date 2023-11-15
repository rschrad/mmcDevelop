import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { handleError, navigateToRecordPage } from 'c/nlsqUtils';
import userId from '@salesforce/user/Id';
import getFormFields from '@salesforce/apex/SubmitDeviceCtrl.getFormFields';
import submit from '@salesforce/apex/SubmitDeviceCtrl.submit';
import labels from './nlsqSubmitDeviceLabels';

export default class NlsqDeviceSubmit extends NavigationMixin(LightningElement) {
    formFields;
    product = { sobjectType: 'Product2', Designer__c: userId };
    listImage = [];
    detailImages = [];
    labels = labels;
    imgformats = ['.jpg', '.jpeg', '.jfif', '.png', '.gif', '.bmp'];
    captchaResponse;

    connectedCallback() {
        getFormFields()
            .then((res) => (this.formFields = res))
            .catch((error) => handleError(this, error));
    }

    renderedCallback() {
        this.template.querySelectorAll('.validate').forEach((fld) => {
            if (fld.required) {
                fld.messageWhenValueMissing = this.labels.msgMandatoryField.replace('{fieldLabel}', fld.label);
            }
        });
    }

    onFieldChange({ target, detail }) {
        let { name: field, value } = target;
        if (value !== undefined) {
            this.product[field] = value;
        } else {
            value = [...detail];
            this.product[field] = value.length > 0 ? value.join(';') : null;
        }
    }

    setFiles(event) {
        this[event.target.name] = [...event.detail];
    }

    handleReCaptcha(e) {
        this.captchaResponse = e.detail;
    }

    submit() {
        try {
            this.validate();
            const contentVersions = [...this.listImage, ...this.detailImages];
            submit({ product: this.product, contentVersions, captchaResponse: this.captchaResponse })
                .then((recordId) => navigateToRecordPage(this, 'Product2', recordId))
                .catch((error) => {
                    this.captchaResponse = null;
                    this.template.querySelector('c-nlsq-re-captcha').reset();
                    handleError(this, error);
                });
        } catch (error) {
            handleError(this, error);
        }
    }

    validate() {
        if (!this.captchaResponse) {
            this.template.querySelector('c-nlsq-re-captcha').validate(false);
        }
        this.validateFields();
        if (this.detailImages.length > 8) {
            throw new Error(`Can't upload more than 8 files for ${this.labels.fieldDownloadables} field.`);
        }
    }

    validateFields() {
        const emptyFields = [];
        this.template.querySelectorAll('.validate').forEach((fld) => {
            if (typeof fld.checkValidity === 'function') {
                if (!fld.checkValidity()) {
                    fld.reportValidity();
                    emptyFields.push(fld.label);
                }
            } else {
                if (fld.required && !this.product[fld.name]?.length) {
                    emptyFields.push(fld.label);
                }
            }
            if (fld.dataset?.max && this.product[fld.name]?.length >= +fld.dataset.max) {
                this.throwMaxLengthErr(fld.label, fld.dataset.max);
            }
        });
        if (emptyFields.length) {
            this.throwReqFieldsErr(emptyFields);
        }
    }

    throwMaxLengthErr(label, length) {
        throw new Error(`Too long value for ${label} field. (max: ${length})`);
    }

    throwReqFieldsErr(fields) {
        throw new Error(`Required fields are not filled: ${fields.join(', ')}`);
    }
}