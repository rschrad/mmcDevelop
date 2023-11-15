import { LightningElement, api, wire, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { handleError, showToast } from 'c/nlsqUtils';
import messageChannel from '@salesforce/messageChannel/discussionForum__c';
import { publish, MessageContext } from 'lightning/messageService';

import getContentKey from '@salesforce/apex/DeviceRequestMainInfoCtrl.getContentKey';

import DEVICE_REQUEST_OBJECT from '@salesforce/schema/Device_Request__c';
import DEVICE_REQUEST_RECORDTYPE_FIELDS from '@salesforce/schema/Device_Request__c.RecordTypeId';
import Id from '@salesforce/schema/Device_Request__c.Id';
import STAGE from '@salesforce/schema/Device_Request__c.Stage__c';
import MAKER from '@salesforce/schema/Device_Request__c.Maker__c';
import OWNER from '@salesforce/schema/Device_Request__c.OwnerId';
import IS_ACTIVE from '@salesforce/schema/Device_Request__c.Is_Active__c';

import userId from '@salesforce/user/Id';

import labels from './nlsqDeviceRequestMainInfoLabels';

export default class NlsqDeviceRequestMainInfo extends LightningElement {
    @api request;
    @api recordId;
    recordTypeId;
    stages;
    @track requestStages = [];
    @track progressStages = [];
    selectedStage;
    imgUrl;

    labels = labels;

    connectedCallback() {
        this.getImgUrl(this.request.Device__r.value.id);
        this.selectedStage = this.stage;
    }

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields: DEVICE_REQUEST_RECORDTYPE_FIELDS })
    getRecordTypeId({ error, data }) {
        if (data) {
            let result = JSON.parse(JSON.stringify(data));
            this.recordTypeId = result.recordTypeId;
        } else if (error) {
            handleError(this, error);
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: DEVICE_REQUEST_OBJECT, recordTypeId: '$recordTypeId' })
    getPicklistData({ data, error }) {
        if (data) {
            let stages = data.picklistFieldValues.Stage__c;
            const lastItem = stages.values.length - 1;
            stages.values.forEach((item, index) => {
                if (index === lastItem) return;
                this.progressStages.push({ value: item.value, label: item.label });
                if (index === 0) return;
                this.requestStages.push({ value: item.value, label: item.label });
            });
        } else if (error) {
            handleError(this, error);
        }
    }

    get showUpdateButton() {
        return this.isCurrentUserIsMaker && !this.isCompleted;
    }

    get receiveBtnDisabled() {
        return this.request[STAGE.fieldApiName].value !== this.labels.shipped;
    }

    get stage() {
        return this.request[STAGE.fieldApiName].value;
    }

    get isCompleted() {
        return this.request[STAGE.fieldApiName].value === this.labels.received;
    }

    get isCurrentUserIsMaker() {
        return this.request[MAKER.fieldApiName].value === userId;
    }

    get isCurrentUserIsRequestor() {
        return this.request[OWNER.fieldApiName].value === userId;
    }

    getImgUrl(deviceId) {
        getContentKey({
            deviceId: deviceId
        })
            .then((response) => {
                this.imgUrl = response[deviceId];
            })
            .catch((error) => handleError(this, error));
    }

    refreshView({ detail }) {
        showToast(this, this.labels.lblSuccess, this.labels.makerAssigned, 'success', 'pester');
        this.template.querySelector('c-nlsq-progress-path').refreshValue(detail.Stage__c.value);
        this.dispatchEvent(new CustomEvent('updaterequest', { detail }));
        publish(this.messageContext, messageChannel, { recordId: userId });
    }

    handleStage(e) {
        this.selectedStage = e.detail.value;
    }

    updateStage() {
        const fields = {};
        fields[Id.fieldApiName] = this.request[Id.fieldApiName].value;
        fields[STAGE.fieldApiName] = this.selectedStage;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.template.querySelector('c-nlsq-progress-path').refreshValue(this.selectedStage);
                this.template.querySelector('c-nlsq-modal').close();
                showToast(
                    this,
                    this.labels.lblSuccess,
                    this.labels.stageChanged + this.selectedStage,
                    'success',
                    'pester'
                );
            })
            .catch((error) => handleError(this, error));
    }

    handleReceive() {
        const fields = {};
        fields[Id.fieldApiName] = this.request[Id.fieldApiName].value;
        fields[STAGE.fieldApiName] = this.labels.received;
        fields[IS_ACTIVE.fieldApiName] = false;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                showToast(
                    this,
                    this.labels.lblSuccess,
                    this.labels.stageChanged + this.labels.received,
                    'success',
                    'pester'
                );
            })
            .catch((error) => handleError(this, error));
    }

    openModal() {
        this.template.querySelector('c-nlsq-modal').open();
    }

    get deviceURL() {
        return `/${this.request.Device__r.value.id}`;
    }
}