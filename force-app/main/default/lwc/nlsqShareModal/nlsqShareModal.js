import { LightningElement, api } from 'lwc';
import nlsqShareModalLabels from './nlsqShareModalLabels';

export default class NlsqShareDeviceLink extends LightningElement {
    labels = nlsqShareModalLabels;
    copyButtonLabel;

    @api name;

    openShareDeviceLink() {
        this.template.querySelector('[data-id="share-modal"]').open();
        this.copyButtonLabel = this.labels.btnCopyLink;
    }

    copyLink() {
        try {
            let copyText = this.template.querySelector(`[data-name="shareUrl"]`);
            copyText.disabled = false;
            copyText.select();
            document.execCommand('copy');
            copyText.disabled = true;
            this.copyButtonLabel = this.labels.btnCopied;
            this.dispatchEvent(new CustomEvent('copylink'));
        } catch (error) {
            console.error(error);
        }
    }

    get deviceUrl() {
        return window.location.href;
    }
}