import { LightningElement, api } from 'lwc';

export default class NlsqModal extends LightningElement {
    @api header;
    isOpen = false;

    @api
    open() {
        this.isOpen = true;
    }

    @api
    close() {
        this.isOpen = false;
    }
}