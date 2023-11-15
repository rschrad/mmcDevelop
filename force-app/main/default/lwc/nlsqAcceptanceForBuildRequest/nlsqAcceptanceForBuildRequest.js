import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { convertResult, handleError, getStatesByCountry } from 'c/nlsqUtils';
import acceptRequest from '@salesforce/apex/AcceptanceForBuildRequestCtrl.acceptRequest';
import userId from '@salesforce/user/Id';

import USER_COUNTRY from '@salesforce/schema/User.CountryCode';
import USER_STATE from '@salesforce/schema/User.StateCode';
import USER_CITY from '@salesforce/schema/User.City';
import USER_PORTAL_ROLES from '@salesforce/schema/User.Portal_Roles__c';
import REQUEST_ID from '@salesforce/schema/Device_Request__c.Id';
import REQUEST_MAKER from '@salesforce/schema/Device_Request__c.Maker__c';
import REQUEST_COUNTRY from '@salesforce/schema/Device_Request__c.Country__c';

import labels from './nlsqAcceptanceForBuildRequestLabels';

export default class NlsqAcceptanceForBuildRequest extends LightningElement {
    @api request;
    userRoles = '';
    makerCountryCode = '';
    requestorCountryCode = '';
    statesByCountry = {};

    userFields = {
        USER_COUNTRY,
        USER_CITY,
        USER_STATE
    };

    labels = labels;

    @wire(getRecord, { recordId: userId, fields: [USER_PORTAL_ROLES, USER_COUNTRY] })
    wiredMaker({ error, data }) {
        if (data) {
            this.userRoles = getFieldValue(data, USER_PORTAL_ROLES);
            this.makerCountryCode = getFieldValue(data, USER_COUNTRY);
        } else if (error) {
            handleError(this, error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: USER_STATE
    })
    wiredStates({ data, error }) {
        if (data) {
            this.statesByCountry = getStatesByCountry(data);
        } else if (error) {
            handleError(this, error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: USER_COUNTRY
    })
    wiredCountry({ data, error }) {
        if (data) {
            const country = data.values.find((c) => c.label === this.request[REQUEST_COUNTRY.fieldApiName].value);
            this.requestorCountryCode = country?.value;
        } else if (error) {
            handleError(this, error);
        }
    }

    get isAcceptButtonShown() {
        return this.request[REQUEST_MAKER.fieldApiName].value === null;
    }

    get isAlertShown() {
        return this.requestorCountryCode !== this.makerCountryCode;
    }

    get currentUserId() {
        return userId;
    }

    get states() {
        return this.statesByCountry[this.makerCountryCode] || [];
    }

    submit() {
        if (this.validateRequiredFields()) {
            this.updateRequest();
        }
    }

    updateRequest() {
        const recordInput = { requestId: this.request[REQUEST_ID.fieldApiName].value };

        acceptRequest(recordInput)
            .then((result) => {
                this.template.querySelector('lightning-record-edit-form').submit();
                this.dispatchEvent(new CustomEvent('updaterequest', { detail: convertResult(result) }));
                this.closeModal();
            })
            .catch((error) => handleError(this, error));
    }

    openModal() {
        this.template.querySelector('c-nlsq-modal').open();
    }

    closeModal() {
        this.template.querySelector('c-nlsq-modal').close();
    }

    changeCountry({ target: { value } }) {
        this.makerCountryCode = value;
    }

    validateRequiredFields() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input-field');

        inputFields.forEach((inputField) => {
            inputField.reportValidity();

            if (!inputField.reportValidity()) {
                isValid = false;
            }
        });

        return isValid;
    }
}