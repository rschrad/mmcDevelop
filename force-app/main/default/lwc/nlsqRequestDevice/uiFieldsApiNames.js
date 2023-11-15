import DEVICE from '@salesforce/schema/Device_Request__c.Device__c';
import COUNTRY from '@salesforce/schema/Device_Request__c.Country__c';
import STATE from '@salesforce/schema/Device_Request__c.State__c';
import CITY from '@salesforce/schema/Device_Request__c.City__c';
import MESSAGE from '@salesforce/schema/Device_Request__c.Request_Notes__c';

export default {
    device: DEVICE.fieldApiName,
    country: COUNTRY.fieldApiName,
    state: STATE.fieldApiName,
    city: CITY.fieldApiName,
    message: MESSAGE.fieldApiName
};