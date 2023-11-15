import { LightningElement, api, wire, track } from 'lwc';
import { handleError } from 'c/nlsqUtils';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getDeviceRequestFilterFields from '@salesforce/apex/DeviceRequestListCtrl.getDeviceRequestFilterFields';
import getDeviceRequestsCount from '@salesforce/apex/DeviceRequestListCtrl.getDeviceRequestsCount';
import getDeviceRequests from '@salesforce/apex/DeviceRequestListCtrl.getDeviceRequests';
import labels from './nlsqDeviceRequestsListLabels';
import NEILSQUIRE_RESOURCES from '@salesforce/resourceUrl/neilsquireResources';

export default class NlsqDeviceRequestsList extends NavigationMixin(LightningElement) {
    @api itemsPerPage;
    @api defaultSortField;
    isLoading = true;
    isNoResult = false;
    currentPage = 1;
    filterFiellds = [];
    deviceRequests = [];
    pageReference;
    noResultImg = NEILSQUIRE_RESOURCES + '/img/requestAndBuilds.svg';

    @track filteringFieldToValue = {
        Country__c: null,
        State__c: null,
        Device__c: null
    };

    get isShouldSorting() {
        return this.deviceRequests.length > 1;
    }

    @wire(CurrentPageReference)
    getStateParameters(data) {
        this.pageReference = data;

        if (data) {
            const { p, Country__c, State__c, Device__c } = data.state;
            this.filteringFieldToValue = { Country__c, State__c, Device__c };
            this.currentPage = p || 1;
        }
    }

    async connectedCallback() {
        try {
            await this.loadFilterFields();
            await this.loadDeviceRequestsCount();
        } catch (error) {
            handleError(this, error);
        } finally {
            this.isLoading = false;
        }
    }

    async loadFilterFields() {
        const filterFields = await getDeviceRequestFilterFields();
        this.setFilters(filterFields);
    }

    async loadDeviceRequestsCount() {
        const requestsCount = await getDeviceRequestsCount({ filteringFieldToValue: this.filteringFieldToValue });
        await this.setPagesCount(requestsCount);
    }

    async loadDeviceRequests() {
        this.isLoading = true;
        const offset = (this.currentPage - 1) * this.itemsPerPage;
        const selectedFilterField = this.filterFiellds.find((item) => item.isSelected === true);
        const orderByType = selectedFilterField.isSortAsc ? 'ASC' : 'DESC';
        const queryParams = {
            lim: this.itemsPerPage,
            offset: offset,
            orderBy: selectedFilterField.fieldApiName + ' ' + orderByType
        };
        this.deviceRequests = await getDeviceRequests({
            queryParams: queryParams,
            filteringFieldToValue: this.filteringFieldToValue
        });
        this.isLoading = false;
        this.isNoResult = !this.deviceRequests.length;
    }

    async setPagesCount(reqCount) {
        await this.loadDeviceRequests();
        if (reqCount > 0) {
            this.template.querySelector('c-nlsq-list-pagination').setPagesCount(reqCount, this.itemsPerPage);
        }
    }

    setFilters(filters) {
        const { so, sf } = this.pageReference.state;
        const sortField = sf || this.defaultSortField;
        const isSortAsc = so ? so === 'ASC' : false;

        this.filterFiellds = filters.map((item) => {
            return item.fieldApiName === sortField ? { ...item, isSelected: true, isSortAsc } : { ...item };
        });
    }

    async handleChangeSortField({ currentTarget }) {
        if (this.isShouldSorting) {
            let fieldName = currentTarget.dataset.name;
            const selectedFilterField = this.filterFiellds.find((item) => item.fieldApiName === fieldName);
            const orderByType = selectedFilterField.isSortAsc ? 'DESC' : 'ASC';
            await this.updateFilters(fieldName);
            await this.reloadDeviceRequests();
            this.updateSearchParams({ sf: fieldName, so: orderByType });
        }
    }

    async reloadDeviceRequests() {
        this.currentPage = 1;
        this.updateSearchParams({ p: this.currentPage });
        await this.loadDeviceRequests();
    }

    async updateFilters(fieldName) {
        this.filterFiellds = this.filterFiellds.map((item) => {
            return item.fieldApiName === fieldName
                ? { ...item, isSortAsc: !item.isSortAsc, isSelected: true }
                : { ...item, isSortAsc: true, isSelected: false };
        });
    }

    handleSetPage({ detail }) {
        if (this.currentPage !== +detail) {
            this.currentPage = +detail;
            this.loadDeviceRequests();
            this.updateSearchParams({ p: this.currentPage });
        }
    }

    showSortMenu() {
        const sortList = this.template.querySelector('.list-menu');
        sortList.classList.toggle('visible-list');
    }

    get labels() {
        return labels;
    }

    async updateListView({ detail }) {
        this.isLoading = true;
        this.filteringFieldToValue = detail;
        this.currentPage = 1;
        this.updateSearchParams({ ...this.filteringFieldToValue, p: this.currentPage });
        await this.loadDeviceRequestsCount();
    }

    updateSearchParams(params) {
        const url = Object.assign({}, this.pageReference, {
            state: Object.assign({}, this.pageReference.state, params)
        });

        this[NavigationMixin.Navigate](url, true);
    }
}