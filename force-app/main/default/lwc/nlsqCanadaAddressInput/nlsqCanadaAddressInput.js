import { LightningElement, api } from 'lwc';

export default class InputAddressBase extends LightningElement {
    address = {

    };

    @api initialCountry;
    @api initialProvince;
    @api initialCity;
    @api initialPostalCode;
    @api initialStreet;

//if initialCountry is not empty, set address.country to initialCountry
    connectedCallback() {
        if (this.initialCountry) {
            this.address.country = this.initialCountry;
        }
        if (this.initialProvince) {
            this.address.province = this.initialProvince;
        }   
        if (this.initialCity) {
            this.address.city = this.initialCity;
        }
        if (this.initialPostalCode) {
            this.address.postalCode = this.initialPostalCode;
        }
        if (this.initialStreet) {
            this.address.street = this.initialStreet;
        }
    }
    _country = 'Canada';

    countryProvinceMap = {
        Canada: [
            { label: 'Alberta', value: 'Alberta' },
            { label: 'British Columbia', value: 'British Columbia' },
            { label: 'Manitoba', value: 'Manitoba' },
            { label: 'New Brunswick', value: 'New Brunswick' },
            { label: 'Newfoundland and Labrador', value: 'Newfoundland and Labrador' },
            { label: 'Northwest Territories', value: 'Northwest Territories' },
            { label: 'Nova Scotia', value: 'Nova Scotia' },
            { label: 'Nunavut', value: 'Nunavut' },
            { label: 'Ontario', value: 'Ontario' },
            { label: 'Prince Edward Island', value: 'Prince Edward Island' },
            { label: 'Quebec', value: 'Quebec' },
            { label: 'Saskatchewan', value: 'Saskatchewan' },
            { label: 'Yukon', value: 'Yukon' },
        ],
    };

    countryOptions = [
        { label: 'Canada', value: 'Canada' },
        { label: 'United States', value: 'United States'}
    ];

    get getProvinceOptions() {
        return this.countryProvinceMap[this._country];
    }
    get getCountryOptions() {
        return this.countryOptions;
    }

    handleChange(event) {
        this._country = event.detail.country;
    }

    //on submit, set the address for the current user to the values in the form
    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Street = this.address.street;
        fields.City = this.address.city;
        fields.State = this.address.province;
        fields.PostalCode = this.address.postalCode;
        fields.Country = this.address.country;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
}