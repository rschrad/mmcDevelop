import { LightningElement, wire,api } from 'lwc';
import Id from '@salesforce/user/Id';
import userStreetFIELD from '@salesforce/schema/User.Street';
import userCityFIELD from '@salesforce/schema/User.City';
import userStateFIELD from '@salesforce/schema/User.State';
import userPostalCodeFIELD from '@salesforce/schema/User.PostalCode';
import userCountryFIELD from '@salesforce/schema/User.Country';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import DEVICE_REQUEST_OBJECT from '@salesforce/schema/Device_Request__c';
import TOY_TYPE_FIELD from '@salesforce/schema/Device_Request__c.Toy_Type__c';
import SWITCH_TYPE_FIELD from '@salesforce/schema/Device_Request__c.Switch_Type__c';
import DEVICE_FIELD from '@salesforce/schema/Device_Request__c.Device__c';
import OWNER_FIELD from '@salesforce/schema/Device_Request__c.OwnerId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_OBJECT from '@salesforce/schema/User';
import ADDRESS_FIELD from '@salesforce/schema/User.Address';
import staticResources from '@salesforce/resourceUrl/neilsquireResources';


export default class NlsqHfthRequestForm extends LightningElement {
    error
    @api userId = Id;
    @api userStreet;
    @api userCity;
    @api userState;
    @api userPostalCode;
    @api userCountry;
    editAddress=false;

    @wire(getRecord, { recordId: '$userId', fields: [userCountryFIELD,userCityFIELD,userStateFIELD,userStreetFIELD,userPostalCodeFIELD] })
    currentuserData({error, data}) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userStreet = getFieldValue(data, userStreetFIELD);
            this.userCity = getFieldValue(data, userCityFIELD);
            this.userState = getFieldValue(data, userStateFIELD);
            this.userPostalCode = getFieldValue(data, userPostalCodeFIELD);
            this.userCountry = getFieldValue(data, userCountryFIELD);
        }
    }

    //Set isCanada to true if userCountry is Canada
    get isCanada() {
        return this.userCountry === 'Canada';
    }

    deviceRequestObject = DEVICE_REQUEST_OBJECT;
    toyTypeField = TOY_TYPE_FIELD;
    switchTypeField = SWITCH_TYPE_FIELD;
    deviceField = DEVICE_FIELD;
    ownerField = OWNER_FIELD;
    userObject = USER_OBJECT;
    addressField = ADDRESS_FIELD;
    handleSuccess() {
        const toastEvent = new ShowToastEvent({
            title: "Success!",
            message: "Toy Request Created",
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
    }


    handleAddressSuccess() {
        const toastEvent = new ShowToastEvent({
            title: "Success!",
            message: "Address Updated Successfully",
            variant: "success"
        });
        this.dispatchEvent(toastEvent);
        this.editAddress=false;
    }
    toyID = "01tJR000000DWy9YAG";


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
        { label: 'Canada', value: 'Canada' }
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

    handleUpdateAddress(event) {
        this.editAddress=true;
    }

    handleSaveAddress(event) {
        this.editAddress=false;

    }


    openToyModal() {
        this.template.querySelector('[data-id="toy-modal"]').open();
    }

    openSwitchModal() {
        this.template.querySelector('[data-id="switch-modal"]').open();
    }

    toyCardArray = [
        {
            id: '1',
            title: 'Bubbles',
            imageUrl: staticResources + '/img/toy-bubbles.png',
            description: 'Hard plastic toys that blow bubbles.',
        },
        {
            id: '2',
            title: 'Light Up Toy',
            imageUrl: staticResources + '/img/toy-light.png',
            description: 'Sensory toys with spinning or static lights. ',
        },
        {
            id: '3',
            title: 'Plush Toy',
            imageUrl: staticResources + '/img/toy-plush.png',
            description: 'Stuffed animal and character toys.',
        },
        {
            id: '4',
            title: 'Remote Control Toy',
            imageUrl: staticResources + '/img/toy-remote-control.png',
            description: 'Remote control vehicles that move backwards and forwards.',
        },
        {
            id: '5',
            title: 'Sound Toy',
            imageUrl: staticResources + '/img/toy-sound.png',
            description: 'Toys that sing educational songs, make animal sounds, or tumble around. ',
        },
        {
            id: '6',
            title: 'Vibration Toy',
            imageUrl: staticResources + '/img/toy-vibration.png',
            description: 'Toys with provide gentle haptic feedback upon activation.',
        }
    ];

    switchCardArray = [
        {
            id: '1',
            title: 'Interact Switch',
            imageUrl: staticResources + '/img/switch-interact.png',
            description: 'A circular switch with a large activation area that requires medium activation force. Suitable for kids with large gross motor movements.',
        },
        {
            id: '2',
            title: 'Light Touch Switch',
            imageUrl: staticResources + '/img/switch-light-touch.png',
            description: 'A small, rectangular switch that requires low activation force. Suitable for use by a finger.',
        },
        {
            id: '3',
            title: 'Low Profile Switch',
            imageUrl: staticResources + '/img/switch-low-profile.png',
            description: 'A thin square-shaped switch that requires low activation force. Suitable for kids with limited range of motion.',
        },
        {
            id: '4',
            title: 'MMC 60 Switch',
            imageUrl: staticResources + '/img/switch-mmc-60.png',
            description: 'A tall circular switch with a large activation area that requires medium activation force. Suitable for kids with large gross motor movements.',
        },
        {
            id: '5',
            title: 'Rocker Switch',
            imageUrl: staticResources + '/img/switch-rocker.png',
            description: 'A thin, rectangular switch with 2 built in buttons. It requires low activation force and is suitable for devices for toys that require 2 switches to operate.',
        },
        {
            id: '5',
            title: 'Raindrop Switch',
            imageUrl: staticResources + '/img/switch-raindrop.png',
            description: 'A small, coin-sized switch that require low activation force. Suitable for use by a finger. ',
        },
        {
            id: '6',
            title: 'Proximity Switch',
            imageUrl: staticResources + '/img/switch-low-profile.png',
            description: 'A small rectangular switch that is motion-activated. It comes with a detachable circular base and is suitable for users with low strength and limited gross motor movement.',
        }

    ];

}