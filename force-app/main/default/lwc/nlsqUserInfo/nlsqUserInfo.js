import { LightningElement, api } from 'lwc';
import { handleError } from 'c/nlsqUtils';
import labels from './nlsqUserInfoLabels';
import getUser from '@salesforce/apex/UserInfoCtrl.getUser';

const defaultValue = '----';

export default class NlsqUserInfo extends LightningElement {
    @api role;
    @api userId;
    name = defaultValue;
    city = defaultValue;
    state = defaultValue;
    country = defaultValue;

    labels = labels;

    connectedCallback() {
        if (this.userId) {
            this.loadUser(this.userId);
        }
    }

    @api
    loadUser(userId) {
        getUser({ userId: userId })
            .then((response) => {
                this.name = response.Name ? response.Name : this.name;
                this.city = response.City ? response.City : this.city;
                this.state = response.State ? response.State : this.state;
                this.country = response.Country ? response.Country : this.country;
            })
            .catch((error) => handleError(this, error));
    }
}