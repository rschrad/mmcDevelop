import { LightningElement, api } from 'lwc';

export default class NlsqProgressPath extends LightningElement {
    @api options;
    @api value;
    @api completed = false;

    renderedCallback() {
        this.refreshValue(this.value);
    }

    @api
    refreshValue(value) {
        const index = this.options.findIndex((option) => option.value === value);

        this.template.querySelectorAll('.slds-path__item').forEach((el, idx) => {
            el.className = 'slds-path__item';
            let className = this.completed ? 'slds-is-complete' : 'slds-is-incomplete';

            if (index !== -1) className = idx <= index ? 'slds-is-complete' : 'slds-is-incomplete';

            el.classList.add(className);
        });
    }
}