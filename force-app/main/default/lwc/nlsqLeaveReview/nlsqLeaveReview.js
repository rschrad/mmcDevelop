import { LightningElement, track, api } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { handleError } from 'c/nlsqUtils';

import nlsqLeaveReviewLabels from './nlsqLeaveReviewLabels';

export default class NlsqReview extends LightningElement {
    labels = nlsqLeaveReviewLabels;

    @api recordId;

    @track currentRating = 0;
    @track starsColor = '#FDB515';
    @track saveButtonDisabled = false;

    openReviewModal() {
        this.currentRating = 0;
        this.template.querySelector('[data-id="review-modal"]').open();
    }

    setRating(event) {
        this.currentRating = Number(event.detail.rating);
        this.starsColor = '#FDB515';
    }

    checkFields() {
        let fieldsFilled = true;

        if (this.currentRating === 0) {
            this.starsColor = '#EF373E';
            fieldsFilled = false;
        }
        return fieldsFilled;
    }

    saveReview() {
        this.saveButtonDisabled = true;

        if (this.checkFields() === true) {
            this.createComment();
        } else {
            this.showErrorMessage = true;
            this.saveButtonDisabled = false;
        }
    }

    createComment() {
        const commentBody = this.template.querySelector('.review-textarea');

        const fields = {
            Rating__c: this.currentRating,
            Review_Body__c: commentBody.value,
            Device__c: this.recordId
        };

        const recordInput = {
            apiName: 'Device_Review__c',
            fields: fields
        };

        createRecord(recordInput)
            .then(() => {
                this.dispatchEvent(new CustomEvent('commentsave'));
                this.template.querySelector('[data-id="review-modal"]').close();
                this.currentRating = 0;
                this.starsColor = '#FDB515';
                this.saveButtonDisabled = false;
            })
            .catch((error) => handleError(this, error));
    }

    closeModal() {
        this.template.querySelector('c-nlsq-modal').close();
    }
}