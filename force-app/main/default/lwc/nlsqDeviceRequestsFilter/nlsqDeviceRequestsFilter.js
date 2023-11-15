/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api, track } from 'lwc';

import labels from './nlsqDeviceRequestFilterLabels';

export default class NlsqDeviceRequestsFilter extends LightningElement {
    countries = [];
    labels = labels;
    timer;
    @track _fieldToValue;

    @api
    get fieldToValue() {
        return this._fieldToValue;
    }

    set fieldToValue(value) {
        this._fieldToValue = value;
    }

    changeDeviceField({ target }) {
        const name = target.name;
        const value = target.value;
        clearTimeout(this.timer);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timer = setTimeout(() => {
            this.searchByDeviceName(name, value);
        }, 500);
    }

    searchByDeviceName(name, value) {
        let params = { ...this.fieldToValue };
        params[name] = value;
        this.fieldToValue = params;
        this.dispatchSearchEvent();
    }

    changeAddressField(e) {
        const name = e.detail.name;
        const value = e.detail.value;
        let params = { ...this.fieldToValue };
        params[name] = value;

        if (name === 'Country__c') {
            params.State__c = null;
        }

        this.fieldToValue = params;
        this.dispatchSearchEvent();
    }

    clearFilters() {
        const params = {
            Country__c: null,
            State__c: null,
            Device__c: null
        };
        this.fieldToValue = params;
        this.clearComboboxValues();
        this.dispatchSearchEvent();
    }

    dispatchSearchEvent() {
        this.dispatchEvent(
            new CustomEvent('search', {
                detail: this.fieldToValue
            })
        );
    }

    clearComboboxValues() {
        this.template.querySelectorAll('lightning-combobox').forEach((box) => {
            box.value = '';
        });
    }
}