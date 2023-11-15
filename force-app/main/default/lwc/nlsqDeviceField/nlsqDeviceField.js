import { LightningElement, api, wire } from 'lwc';
import { handleError } from 'c/nlsqUtils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import objectApiName from '@salesforce/schema/Product2';

export default class NlsqDeviceField extends LightningElement {
    @api recordId;
    @api field;
    @api isShowExpander;
    @api isExpandedDefault;
    isExpanded;
    classList = 'device_field';
    fieldLabel;

    get isFieldName() {
        return this.field === 'Name';
    }

    @wire(getObjectInfo, { objectApiName })
    setProductFields({ error, data }) {
        if (data) {
            this.fieldLabel = data.fields[this.field].label;
        } else if (error) {
            handleError(this, error);
        }
    }

    connectedCallback() {
        this.isExpanded = !this.isShowExpander || this.isExpandedDefault;
        this.classList += this.isShowExpander ? ' expandable' : '';
    }

    expandField() {
        if (this.isShowExpander) {
            this.isExpanded = !this.isExpanded;
        }
    }
}