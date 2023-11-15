import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToRecordPage } from 'c/nlsqUtils';
import labels from './nlsqDeviceRequestTileLabels';

export default class NlsqDeviceRequestTile extends NavigationMixin(LightningElement) {
    @api deviceRequest;

    openDeviceRequest() {
        navigateToRecordPage(this, 'Device_Request__c', this.deviceRequest.Id);
    }

    get labels() {
        return labels;
    }
}