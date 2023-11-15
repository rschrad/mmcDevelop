import { LightningElement, api } from 'lwc';

export default class NlsqMap extends LightningElement {
    @api street;
    @api city;
    @api country;
    @api title;
    @api zoomLevel;

    get mapMarker() {
        return [
            {
                location: {
                    Street: this.street,
                    City: this.city,
                    Country: this.country
                },
                title: this.title
            }
        ];
    }
}