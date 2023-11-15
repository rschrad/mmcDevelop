import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { handleError, navigateToCommunityPage, navigateToRecordPage } from 'c/nlsqUtils';
import { CurrentPageReference } from 'lightning/navigation';
import nlsqMyDevicesLabels from './nlsqMyDevicesLabels.js';
import NEILSQUIRE_RESOURCES from '@salesforce/resourceUrl/neilsquireResources';

import getDevicesCount from '@salesforce/apex/MyDevicesCtrl.getDevicesCount';
import getDevices from '@salesforce/apex/MyDevicesCtrl.getDevices';

export default class NlsqMyDevices extends NavigationMixin(LightningElement) {
    @api recordId;
    @api itemsPerPage;
    @api fullListView;
    @api viewAllLink;
    @api submitDeviceLink;
    @track devices;
    isLoading = true;
    isNoResults = false;
    currentPage = 1;
    userId;
    labels = nlsqMyDevicesLabels;
    myBuildsAndRequestsImg = NEILSQUIRE_RESOURCES + '/img/requestAndBuilds.svg';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.userId = currentPageReference.state?.id;
        }
    }
    connectedCallback() {
        this.userId = !this.recordId ? this.userId : this.recordId;
        if (this.userId) this.getDevicesCount();
    }

    getDevicesCount() {
        getDevicesCount({ userId: this.userId })
            .then(async (result) => {
                if (this.fullListView) {
                    this.template.querySelector('c-nlsq-list-pagination').setPagesCount(result, this.itemsPerPage);
                }
                await this.loadDevices();
            })
            .catch((error) => handleError(this, error))
            .finally(() => {
                this.isLoading = false;
            });
    }

    async loadDevices() {
        const offset = (this.currentPage - 1) * this.itemsPerPage;
        const queryParams = { lim: this.itemsPerPage, offset: offset };
        return getDevices({ userId: this.userId, queryParams: queryParams })
            .then((response) => {
                this.devices = response;
                this.isNoResults = !this.devices.length;
            })
            .catch((error) => handleError(this, error));
    }

    handleSetPage({ detail }) {
        if (this.currentPage !== +detail) {
            this.currentPage = +detail;
            this.loadDevices();
        }
    }

    openAllDevicesPage() {
        navigateToCommunityPage(this, this.viewAllLink, { id: this.recordId });
    }

    openSubmitDevice() {
        navigateToCommunityPage(this, this.submitDeviceLink);
    }

    openDevice({ target: { dataset } }) {
        navigateToRecordPage(this, 'Product2', dataset.id);
    }
}