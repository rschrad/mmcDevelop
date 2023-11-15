import { LightningElement, api } from 'lwc';

export default class NlsqMultiPicklistSelector extends LightningElement {
    @api options = [];
    selectedOptions = new Set();

    handleChange({ target: { value } }) {
        if (this.selectedOptions.has(value)) {
            this.selectedOptions.delete(value);
        } else {
            this.selectedOptions.add(value);
        }
        this.dispatchEvent(new CustomEvent('change', { detail: this.selectedOptions }));
    }
}