import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { handleError, navigateToCommunityPage } from 'c/nlsqUtils';
import { CurrentPageReference } from 'lightning/navigation';
import nlsqMyReviewsLabels from './nlsqMyReviewsLabels';
import NEILSQUIRE_RESOURCES from '@salesforce/resourceUrl/neilsquireResources';

import getReviewsCount from '@salesforce/apex/MyReviewsCtrl.getReviewsCount';
import getReviews from '@salesforce/apex/MyReviewsCtrl.getReviews';

export default class NlsqMyDevices extends NavigationMixin(LightningElement) {
    @api recordId;
    @api itemsPerPage;
    @api fullListView;
    @api viewAllLink;
    @track reviews;
    isLoading = true;
    isNoResults = false;
    currentPage = 1;
    userId;
    labels = nlsqMyReviewsLabels;
    myBuildsAndRequestsImg = NEILSQUIRE_RESOURCES + '/img/requestAndBuilds.svg';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.userId = currentPageReference.state?.id;
        }
    }
    connectedCallback() {
        this.userId = !this.recordId ? this.userId : this.recordId;
        if (this.userId) this.getReviewsCount();
    }

    getReviewsCount() {
        getReviewsCount({ userId: this.userId })
            .then(async (result) => {
                if (this.fullListView) {
                    this.template.querySelector('c-nlsq-list-pagination').setPagesCount(result, this.itemsPerPage);
                }
                await this.loadReviews();
            })
            .catch((error) => handleError(this, error))
            .finally(() => {
                this.isLoading = false;
            });
    }

    async loadReviews() {
        const offset = (this.currentPage - 1) * this.itemsPerPage;
        const queryParams = { lim: this.itemsPerPage, offset: offset };
        return getReviews({ userId: this.userId, queryParams: queryParams })
            .then((response) => {
                this.reviews = response;
                this.isNoResults = !this.reviews.length;
            })
            .catch((error) => handleError(this, error));
    }

    handleSetPage({ detail }) {
        if (this.currentPage !== +detail) {
            this.currentPage = +detail;
            this.loadReviews();
        }
    }

    openAllReviewsPage() {
        navigateToCommunityPage(this, this.viewAllLink, { id: this.recordId });
    }
}