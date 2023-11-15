import { api, LightningElement, track } from 'lwc';

export default class AC_RatingStars extends LightningElement {
    @api rating = 0.0;
    @api votes;
    @api editable = false;
    @api color;

    @track ratingList = [];

    constructor() {
        super();

        const abstractRatingList = [];
        for (let index = 0; index < 5; index++) {
            abstractRatingList.push({ id: index });
        }
        this.ratingList.push(...abstractRatingList);
    }

    get ratingVariable() {
        const ratingString = this.rating ? Number(this.rating).toFixed(1) : Number(0.0).toFixed(1);
        return `--rating: ${ratingString};`;
    }

    get isEditable() {
        return this.editable ? 'cursor:pointer;' : 'cursor:initial;';
    }

    get votesString() {
        if (this.votes >= 0) {
            return `${this.votes} reviews`;
        }
        return undefined;
    }

    get starFillColorCSS() {
        return this.color ? this.color : 'inherit';
    }

    get starStrokeColorCSS() {
        return this.color === '#EF373E' ? this.color : '#BEB9BB';
    }

    setRating(event) {
        if (this.editable === false) {
            return;
        }

        let index = event.currentTarget.dataset.index;
        index++;

        const selectedEvent = new CustomEvent('ratingchange', {
            detail: { rating: index }
        });
        this.dispatchEvent(selectedEvent);
    }
}