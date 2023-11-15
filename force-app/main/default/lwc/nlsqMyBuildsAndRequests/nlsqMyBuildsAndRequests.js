import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { handleError, navigateToRecordPage, navigateToCommunityPage } from 'c/nlsqUtils';
import { CurrentPageReference } from 'lightning/navigation';
import labels from './nlsqMyBuildsAndRequestsLabels';
import getRequests from '@salesforce/apex/MyBuildsAndRequestsCtrl.getRequests';
import getRequestsCount from '@salesforce/apex/MyBuildsAndRequestsCtrl.getRequestsCount';
import NEILSQUIRE_RESOURCES from '@salesforce/resourceUrl/neilsquireResources';

export default class NlsqMyBuildsAndRequests extends NavigationMixin(LightningElement) {
    @api recordId;
    @api itemsPerPage;
    @api showFullList;
    @api viewAllPageApiName;
    @track requests = [];
    isLoading = true;
    isNoResults = false;
    userId;
    currentPage = 1;
    labels = labels;
    myBuildsAndRequestsImg = NEILSQUIRE_RESOURCES + '/img/requestAndBuilds.svg';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.userId = currentPageReference.state?.id;
        }
    }

    connectedCallback() {
        this.userId = !this.recordId ? this.userId : this.recordId;

        if (this.userId) this.getRequestsCount();
    }

    getRequestsCount() {
        getRequestsCount({ userId: this.userId })
            .then(async (response) => {
                if (this.showFullList) {
                    this.template.querySelector('c-nlsq-list-pagination').setPagesCount(response, this.itemsPerPage);
                }
                await this.loadRequests();
            })
            .catch((error) => handleError(this, error))
            .finally(() => {
                this.isLoading = false;
            });
    }

    async loadRequests() {
        const offset = (this.currentPage - 1) * this.itemsPerPage;
        const queryParams = { lim: this.itemsPerPage, offset: offset };
        return getRequests({ userId: this.userId, parameters: queryParams })
            .then((response) => {
                this.requests = response;
                this.isNoResults = !this.requests.length;
            })
            .catch((error) => handleError(this, error));
    }

    handleSetPage({ detail }) {
        if (this.currentPage !== +detail) {
            this.currentPage = +detail;
            this.loadRequests();
        }
    }

    openRequest(e) {
        navigateToRecordPage(this, 'Device_Request__c', e.target.dataset.id);
    }

    openAllRequestsPage() {
        navigateToCommunityPage(this, this.viewAllPageApiName, { id: this.recordId });
    }
}