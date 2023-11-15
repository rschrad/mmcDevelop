import { LightningElement, api } from 'lwc';

export default class NlsqAlert extends LightningElement {
    @api mainText;
    @api type;
    @api iconName;

    get className() {
        return 'slds-notify slds-notify_alert slds-alert_' + this.type;
    }
}