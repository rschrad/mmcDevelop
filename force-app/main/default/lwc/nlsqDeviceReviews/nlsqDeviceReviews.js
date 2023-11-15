import { LightningElement, api, track } from 'lwc';
import getReviewsCount from '@salesforce/apex/DeviceReviewsCtrl.getReviewsCount';
import getReviews from '@salesforce/apex/DeviceReviewsCtrl.getReviews';
import { handleError } from 'c/nlsqUtils';
import nlsqDeviceReviewsLabels from './nlsqDeviceReviewsLabels';
import NEILSQUIRE_RESOURCES from '@salesforce/resourceUrl/neilsquireResources';

export default class NlsqDeviceReviews extends LightningElement {
    @api itemsPerPage;
    @api recordId;
    @track reviews = [];
    isLoading = true;
    currentPage = 1;
    labels = nlsqDeviceReviewsLabels;
    noReviews = NEILSQUIRE_RESOURCES + '/img/requestAndBuilds.svg';

    connectedCallback() {
        getReviewsCount({ recordId: this.recordId })
            .then((count) => {
                if (count) {
                    this.template.querySelector('c-nlsq-list-pagination').setPagesCount(count, this.itemsPerPage);
                    this.loadReviews();
                }
            })
            .catch((error) => handleError(this, error))
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadReviews() {
        const offset = (this.currentPage - 1) * this.itemsPerPage;
        const queryParams = { lim: this.itemsPerPage, offset };
        getReviews({ recordId: this.recordId, queryParams })
            .then((reviews) => (this.reviews = reviews))
            .catch((error) => handleError(this, error));
    }

    handleSetPage({ detail }) {
        if (this.currentPage !== +detail) {
            this.currentPage = +detail;
            this.loadReviews();
        }
    }
}