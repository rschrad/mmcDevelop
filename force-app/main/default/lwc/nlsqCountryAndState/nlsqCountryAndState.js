import { LightningElement, wire, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { handleError, getStatesByCountry } from 'c/nlsqUtils';
import { getLabel, getFieldValue } from './nlsqCountryAndStateHelper.js';

import BILLING_STATE_CODE from '@salesforce/schema/User.StateCode';
import COUNTRY_CODE from '@salesforce/schema/User.CountryCode';
import labels from './nlsqCountryAndStateLabels';

const defaultRecordTypeId = '012000000000000AAA';

export default class NlsqCountryAndState extends LightningElement {
    @api countryFieldValue;
    @api countryName;
    @api stateFieldValue;
    @api stateName;
    @api countryRequired = false;
    @api stateRequired = false;

    countries = [];
    statesByCountry = {};

    labels = labels;

    @api
    reportValidity(inputName) {
        this.template.querySelector(`[data-input="${inputName}"]`).reportValidity();
    }

    @wire(getPicklistValues, {
        recordTypeId: defaultRecordTypeId,
        fieldApiName: COUNTRY_CODE
    })
    wiredCountries({ data, error }) {
        if (data) {
            this.countries = data.values;
        } else if (error) {
            handleError(this, error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: defaultRecordTypeId,
        fieldApiName: BILLING_STATE_CODE
    })
    wiredStates({ data, error }) {
        if (data) {
            this.statesByCountry = getStatesByCountry(data);

            if (this.stateRequired) {
                this.dispatchEvent(
                    new CustomEvent('getstatesbycountry', {
                        detail: this.statesByCountry
                    })
                );
            }
        } else if (error) {
            handleError(this, error);
        }
    }

    get countryValue() {
        return getFieldValue(this.countries, this.countryFieldValue);
    }

    get stateValue() {
        return getFieldValue(this.states, this.stateFieldValue);
    }

    get states() {
        return this.statesByCountry[this.countryValue] || [];
    }

    handleChange(e) {
        let label;

        if (e.target.name === this.countryName) {
            label = getLabel(this.countries, e.target.value);
        } else {
            label = getLabel(this.states, e.target.value);
        }

        this.dispatchEvent(
            new CustomEvent('changepicklist', {
                detail: {
                    name: e.target.name,
                    value: label,
                    code: this.countryName ? e.target.value : null
                }
            })
        );
    }
}