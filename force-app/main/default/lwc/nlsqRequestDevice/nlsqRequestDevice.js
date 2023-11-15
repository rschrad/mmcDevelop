import { LightningElement, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { showToast, navigateToRecordPage, handleError } from 'c/nlsqUtils';
import { NavigationMixin } from 'lightning/navigation';

import getDevices from '@salesforce/apex/RequestDeviceCtrl.getDevicesPicklist';
import createRecord from '@salesforce/apex/RequestDeviceCtrl.createRecord';
import userId from '@salesforce/user/Id';
import uiFields from './uiFieldsApiNames';
import nlsqRequestDeviceLabels from './nlsqRequestDeviceLabels';

import COUNTRY_CODE from '@salesforce/schema/User.CountryCode';
import COUNTRY from '@salesforce/schema/User.Country';
import STATE from '@salesforce/schema/User.State';
import CITY from '@salesforce/schema/User.City';

export default class NlsqRequestDevice extends NavigationMixin(LightningElement) {
    objectName = 'Device_Request__c';
    isLoading = true;
    cityValueSize = 0;
    labels = nlsqRequestDeviceLabels;
    statesByCountry;
    userCountryCode = '';

    devices = [];
    @track currentRequest = {};

    reCaptchaResponse;

    uiFields = uiFields;

    connectedCallback() {
        this.isLoading = false;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.currentRequest[uiFields.device] = currentPageReference.state?.id;
        }
    }

    @wire(getRecord, { recordId: userId, fields: [COUNTRY, STATE, CITY, COUNTRY_CODE] })
    wiredUser({ error, data }) {
        if (data) {
            this.setDefaultAddress(data);
        } else if (error) {
            handleError(this, error);
        }
    }

    @wire(getDevices)
    wiredDevices({ error, data }) {
        if (data) {
            this.devices = data;
        } else if (error) {
            handleError(this, error);
        }
    }

    setDefaultAddress(data) {
        this.currentRequest[uiFields.country] = getFieldValue(data, COUNTRY);
        this.currentRequest[uiFields.state] = getFieldValue(data, STATE);
        this.currentRequest[uiFields.city] = getFieldValue(data, CITY);
        this.userCountryCode = getFieldValue(data, COUNTRY_CODE);

        if (this.currentRequest[uiFields.city]) {
            this.cityValueSize = this.currentRequest[uiFields.city].length;
        }
    }

    handleCityLength(value) {
        this.cityValueSize = value.length;
    }

    handleReCaptcha(e) {
        this.reCaptchaResponse = e.detail;
    }

    setRequestField(e) {
        const name = e.target.name;
        const value = e.detail.value;

        if (name === uiFields.city) {
            this.handleCityLength(value);
        }

        this.currentRequest[name] = value;
    }

    setStatesByCountry({ detail }) {
        this.statesByCountry = detail;
    }

    setRequestAddressField({ detail: { value, name, code } }) {
        this.currentRequest[name] = value;

        if (name === uiFields.country) {
            this.currentRequest[uiFields.state] = null;
        }

        if (code) {
            this.userCountryCode = code;
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

        if (!this.currentRequest[uiFields.country]) {
            this.template.querySelector('c-nlsq-country-and-state').reportValidity('country');
            isValid = false;
        }

        if (this.statesByCountry[this.userCountryCode] && !this.currentRequest[uiFields.state]) {
            this.template.querySelector('c-nlsq-country-and-state').reportValidity('state');
            isValid = false;
        }

        return isValid;
    }

    submitRequest() {
        if (!this.reCaptchaResponse) {
            this.template.querySelector('c-nlsq-re-captcha').validate(false);
        }

        const isValid = this.validateRequiredFields();

        if (!isValid || !this.reCaptchaResponse) {
            return;
        }

        this.isLoading = true;

        createRecord({
            deviceRequest: this.currentRequest,
            uiResponse: this.reCaptchaResponse
        })
            .then((response) => {
                this.isLoading = false;
                showToast(this, 'Success', 'The Device Request was created', 'success', 'pester');
                navigateToRecordPage(this, this.objectName, response);
            })
            .catch((error) => {
                this.isLoading = false;
                this.reCaptchaResponse = '';
                this.template.querySelector('c-nlsq-re-captcha').reset();
                handleError(this, error);
            });
    }
}