import { api, LightningElement, track } from 'lwc';

export default class NlsqListPagination extends LightningElement {
    @api get currentPage() {
        return this.activePage;
    }
    set currentPage(value) {
        this.activePage = +value;
        this.setPageButtons();
    }
    @track pageBtns;
    activePage;
    pagesCount = 0;
    get isCmpShown() {
        return this.pagesCount > 1;
    }
    get isNoPrev() {
        return !(this.currentPage > 1);
    }
    get isNoNext() {
        return !(this.currentPage < this.pagesCount);
    }

    @api
    setPagesCount(recordsCount, itemsPerPage) {
        this.pagesCount =
            recordsCount % itemsPerPage === 0
                ? recordsCount / itemsPerPage
                : (recordsCount - (recordsCount % itemsPerPage)) / itemsPerPage + 1;
        this.setPageButtons();
    }

    setPageButtons() {
        if (!(this.pagesCount > 1)) {
            return;
        }
        const pageBtns = [this.createPage(1)];
        for (let i = 2; i < this.pagesCount; i++) {
            if (
                i === this.currentPage ||
                (i > this.currentPage && i <= this.currentPage + 2) ||
                (i < this.currentPage && i >= this.currentPage - 2)
            ) {
                pageBtns.push(this.createPage(i));
            } else if (i === this.currentPage + 3 || i === this.currentPage - 3) {
                pageBtns.push(this.createPage('...'));
            }
        }
        pageBtns.push(this.createPage(this.pagesCount));
        this.pageBtns = pageBtns;
    }

    changePage({ target: { dataset } }) {
        this.dispatchPage(this.currentPage + +dataset.value);
    }

    setPage({ target: { dataset } }) {
        this.dispatchPage(dataset.value);
    }

    dispatchPage(page) {
        if (+page !== this.currentPage) {
            this.dispatchEvent(new CustomEvent('setpage', { detail: page }));
        }
    }

    createPage(value) {
        let className = 'page_btn';
        if (value === this.currentPage) {
            className = 'page_btn current';
        } else if (typeof value === 'string') {
            className = 'page_btn empty';
        }
        return { value, className, disabled: typeof value === 'string' };
    }
}