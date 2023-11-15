import { LightningElement, api } from 'lwc';

export default class NlsqToast extends LightningElement {
    isShown = false;
    type = '';
    message = '';

    @api
    showToast({ type, message }) {
        this.type = type;
        this.message = message;
        this.isShown = true;
    }

    hideToast() {
        this.isShown = false;
    }

    get className() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }

    get iconName() {
        return 'utility:' + this.type;
    }
}