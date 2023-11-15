import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { handleError } from 'c/nlsqUtils';

import labels from './nlsqDeviceRequestDetailLabels';
import Id from '@salesforce/schema/Device_Request__c.Id';
import DEVICE_NAME from '@salesforce/schema/Device_Request__c.Device__r.Name';
import DEVICE_ID from '@salesforce/schema/Device_Request__c.Device__r.Id';
import STAGE from '@salesforce/schema/Device_Request__c.Stage__c';
import REQUEST_DATE from '@salesforce/schema/Device_Request__c.Request_Date__c';
import MAKER from '@salesforce/schema/Device_Request__c.Maker__c';
import REQUEST_NOTES from '@salesforce/schema/Device_Request__c.Request_Notes__c';
import OWNER from '@salesforce/schema/Device_Request__c.OwnerId';
import COUNTRY from '@salesforce/schema/Device_Request__c.Country__c';

import userId from '@salesforce/user/Id';

export default class NlsqDeviceRequestDetail extends LightningElement {
    @api recordId;
    @track request;

    labels = labels;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [STAGE, DEVICE_NAME, REQUEST_DATE, MAKER, DEVICE_ID, OWNER, REQUEST_NOTES, Id, COUNTRY]
    })
    wiredRequest({ error, data }) {
        if (data) {
            this.request = data.fields;
        } else if (error) {
            handleError(this, error);
        }
    }

    get isCpmShown() {
        return (
            this.request &&
            (this.request[STAGE.fieldApiName].value === this.labels.lblMakerWanted ||
                this.request[OWNER.fieldApiName].value === userId ||
                this.request[MAKER.fieldApiName].value === userId)
        );
    }

    updateRequest({ detail }) {
        this.request = Object.assign({}, this.request, detail);
        this.template.querySelector('[data-id="maker"]').loadUser(this.request[MAKER.fieldApiName].value);
    }
}