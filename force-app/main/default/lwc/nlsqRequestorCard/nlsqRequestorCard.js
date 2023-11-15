import { LightningElement, api,track,wire } from 'lwc';
import labels from './nlsqRequestorCardLabels';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getUser from '@salesforce/apex/UserInfoCtrl.getUser';
import { handleError } from 'c/nlsqUtils';
import OWNERID_FIELD from '@salesforce/schema/Device_Request__c.OwnerId';
import CITY_FIELD from '@salesforce/schema/Device_Request__c.City__c';
import STATE_FIELD from '@salesforce/schema/Device_Request__c.State__c';
import COUNTRY_FIELD from '@salesforce/schema/Device_Request__c.Country__c';
import NAME_FIELD from '@salesforce/schema/User.FirstName';
const defaultValue = '----';
const FIELDS = [OWNERID_FIELD, CITY_FIELD, STATE_FIELD, COUNTRY_FIELD]

export default class NlsqRequestorCard extends LightningElement {
    @api role;
    @api userId;
    @api recordId; 
    @api objectApiName;
    labels = labels;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    deviceRequest;

    @wire(getRecord, { recordId: '$userId', fields: NAME_FIELD })
    ownerData;

    connectedCallback() {
        console.log(this.ownerName);

    }

    get city() {
        return getFieldValue(this.deviceRequest.data, 'Device_Request__c.City__c');
    }

    get state() {
        return getFieldValue(this.deviceRequest.data, 'Device_Request__c.State__c');
    }

    get country() {
        return getFieldValue(this.deviceRequest.data, 'Device_Request__c.Country__c');
    }
    
    get ownerName() {
        return getFieldValue(this.ownerData.data, NAME_FIELD);
  
    }
    





    
}