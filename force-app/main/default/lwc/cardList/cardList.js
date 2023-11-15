import { LightningElement, api } from 'lwc';

export default class CardList extends LightningElement {
    @api cardData = [];
    @api cardStyle = ''; // You can use this to pass CSS styles as a string
}