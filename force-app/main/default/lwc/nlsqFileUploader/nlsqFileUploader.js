import { LightningElement, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { handleError } from 'c/nlsqUtils';
import labels from './nlsqFileUploaderLabels';

export default class NlsqFileUploader extends LightningElement {
    @api label;
    @api isMultiple;
    @api fileName;
    @api acceptedFormats;
    @track files = [];
    labels = labels;
    isDeleteBtnDisabled = false;

    handleUploadFinished({ detail: { files } }) {
        if (this.isMultiple) {
            this.processMultipleUpload(files);
        } else {
            this.processSingleUpload(files[0]);
        }
        this.sendFiles();
    }

    processSingleUpload(newFile) {
        if (this.files.length) {
            this.deleteFile(null, this.files[0].ContentDocumentId, newFile);
        } else {
            this.files.push(this.buildContentVersion(newFile));
        }
    }

    processMultipleUpload(files) {
        const fileNames = this.files.map((i) => i.PathOnClient);
        files = files.filter((file) => {
            // filter if added same file again, delete from DB
            if (fileNames.includes(file.name)) {
                this.deleteFile(null, file.documentId);
                return false;
            }
            return true;
        });
        let i = this.files.length + 1;
        files.forEach((file) => {
            this.files.push(this.buildContentVersion(file, `${this.fileName} ${i}`));
            i += 1;
        });
        this.sendFiles();
    }

    setAltText({ target: { dataset, value } }) {
        this.files[dataset.index].Alt_Text__c = value;
    }

    deleteFile(event, fileId, newFile) {
        this.isDeleteBtnDisabled = true;
        const contentDocumentId = event ? event.target.dataset.contentDocumentId : fileId;
        deleteRecord(contentDocumentId)
            .then(() => {
                this.files = this.files.filter((i) => i.ContentDocumentId !== contentDocumentId);
                if (newFile) {
                    this.files.push(this.buildContentVersion(newFile));
                }
                this.updateTitles();
                this.sendFiles();
            })
            .catch((error) => handleError(this, error))
            .finally(() => {
                this.isDeleteBtnDisabled = false;
            });
    }

    updateTitles() {
        if (this.isMultiple) {
            this.files.forEach((file, ind) => {
                const str = file.Title;
                file.Title = `${str.substring(0, str.length - 1)}${ind + 1}`;
            });
        }
    }

    sendFiles() {
        this.dispatchEvent(new CustomEvent('uploadfinished', { detail: this.files }));
    }

    buildContentVersion(file, title = this.fileName) {
        const cv = { sobjectType: 'ContentVersion' };
        cv.Id = file.contentVersionId;
        cv.ContentDocumentId = file.documentId;
        cv.PathOnClient = file.name;
        if (title) {
            cv.Title = title;
        }
        return cv;
    }
}