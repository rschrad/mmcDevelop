import { LightningElement,api, wire } from 'lwc';
import { handleError } from 'c/nlsqUtils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import DEVICE_OBJECT from '@salesforce/schema/Product2';
import OVERVIEW_FIELD from '@salesforce/schema/Product2.Overview__c';
import HOWTOUSE_FIELD from '@salesforce/schema/Product2.How_To_Use__c';
import APPLICABLE_DISABILITES_FIELD from '@salesforce/schema/Product2.Disability_Type_Description__c';
import ESTIMATED_COST_FIELD from '@salesforce/schema/Product2.Est_Cost_CAD__c';

export default class NlsqDeviceDetails extends LightningElement {
    @api recordId; 
    @api objectApiName;
    @wire(getObjectInfo, { objectApiName: DEVICE_OBJECT })

    overviewField = OVERVIEW_FIELD;
    howToUseField = HOWTOUSE_FIELD;
    applicableDisabilitiesField = APPLICABLE_DISABILITES_FIELD;
    estimatedCostField = ESTIMATED_COST_FIELD;
    deviceObject = DEVICE_OBJECT;


  

}