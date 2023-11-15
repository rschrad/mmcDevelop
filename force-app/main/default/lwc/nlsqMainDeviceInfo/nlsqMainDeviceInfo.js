import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToWebPage } from 'c/nlsqUtils';
import {
    loadDeviceInfo,
    updateCountField,
    loadUserLike,
    setLikeProduct,
    unsetLikeProduct,
    formatNumber
} from './nlsqMainDeviceInfoHelper';
import isGuest from '@salesforce/user/isGuest';
import nlsqMainDeviceInfoLabels from './nlsqMainDeviceInfoLabels';
import nlsqMainDeviceInfoData from './nlsqMainDeviceInfoData';

import {getRecord, getFieldValue } from 'lightning/uiRecordApi';
import DOWNLOAD_LINK_FIELD from '@salesforce/schema/Product2.Download_Link__c'
const fields = [DOWNLOAD_LINK_FIELD];

export default class NlsqMainDeviceInfo extends NavigationMixin(LightningElement) {
    @track device;
    @api recordId;
    @api requestDeviceUrl;
    isGuestMode = true;
    isLikeDisabled = false;
    isDesignerInactiveDevice = false;
    isUserDesigner = false;
    wasChecked = {};
    likeId;
    labels = nlsqMainDeviceInfoLabels;
    deviceInfoData = nlsqMainDeviceInfoData;
    @wire(getRecord, { recordId: "$recordId", fields })
    product2;
    
    get projectLink() {
        return getFieldValue(this.product2.data, DOWNLOAD_LINK_FIELD);
    }

    get likesQuantity() {
        return formatNumber(this.device.Likes_Count__c);
    }

    get downloadsQuantity() {
        return formatNumber(this.device.Downloads_Count__c);
    }

    get sharesQuantity() {
        return formatNumber(this.device.Shares_Count__c);
    }

    get viewsQuantity() {
        return formatNumber(this.device.Views_Count__c);
    }

    get requestLink() {
        return `${this.requestDeviceUrl}?id=${this.recordId}`;
    }

    get likeStyle() {
        return this.likeId ? 'btn-icon btn-red btn-like btn-icon-active' : 'btn-icon btn-red btn-like';
    }

    connectedCallback() {
        this.isGuestMode = isGuest;
        const storage = JSON.parse(localStorage.getItem(this.recordId));
        if (!storage?.Views_Count__c) {
            updateCountField(this, 'Views_Count__c');
            localStorage.setItem(this.recordId, JSON.stringify({ Views_Count__c: true }));
        }
        loadDeviceInfo(this);

        if (!this.isGuestMode) {
            loadUserLike(this);
        }
    }

    updateShares() {
        this.updateCountField('Shares_Count__c');
    }

    downloadRedirect() {
        
                // Extract the filename from the URL
                const url = this.projectLink

                const filename = url.substring(url.lastIndexOf('/') + 1);
        
                // Create a temporary link element
                const link = document.createElement('a');
                link.href = url;
                link.download = filename; // Use the extracted filename
        
        
                // Append the link to the DOM and trigger a click event
                document.body.appendChild(link);
                link.click();
        
                // Remove the link from the DOM
                document.body.removeChild(link);
        this.updateCountField('Downloads_Count__c');
    }

    updateCountField(field) {
        if (!this.wasChecked[field]) {
            this.wasChecked[field] = true;
            updateCountField(this, field);
        }
    }

    handleLike() {
        this.isLikeDisabled = true;
        if (this.likeId) {
            unsetLikeProduct(this);
        } else {
            setLikeProduct(this);
        }
    }

    refreshRating() {
        loadDeviceInfo(this);
    }
}