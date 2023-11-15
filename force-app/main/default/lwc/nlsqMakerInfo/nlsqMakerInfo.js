import { LightningElement,api,wire } from 'lwc';
import DEVICE_OBJECT from '@salesforce/schema/Product2';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';




export default class NlsqMakerInfo extends LightningElement {
    @api recordId;
    isExpanded = true;
    classList = 'device_field';
    fieldLabel;

    @wire(getObjectInfo, { objectApiName: DEVICE_OBJECT })



    expandField() {
        
            this.isExpanded = !this.isExpanded;
    
    }



}