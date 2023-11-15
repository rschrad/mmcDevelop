import { LightningElement,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DEVICEREQUESTOBJECT from '@salesforce/schema/Device_Request__c';
import DEVICEFIELD from '@salesforce/schema/Device_Request__c.Device__c';
import QUANTITYFIELD from '@salesforce/schema/Device_Request__c.Quantity__c';
import DEVICEREQUESTORFIELD from '@salesforce/schema/Device_Request__c.Device_Requestor__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';




export default class CreateMMCBuildRequest extends LightningElement {

    deviceRequestObject = DEVICEREQUESTOBJECT;
    fields = [DEVICEFIELD, DEVICEREQUESTORFIELD, QUANTITYFIELD];

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Device Request Created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);
    }

    handleCancel(event) {
        this.dispatchEvent(new CustomEvent('close'));
    }

    @wire (getObjectInfo, {objectApiName: DEVICEREQUESTOBJECT})
    objectInfo;

    get deviceRequestRecordTypeId() {
            if(this.objectInfo.data) {
                const rtis = this.objectInfo.data.recordTypeInfos;
                return Object.keys(rtis).find(rti => rtis[rti].name ===  'MMC Build');
            }
            else {
                return null;
            }
    }
}