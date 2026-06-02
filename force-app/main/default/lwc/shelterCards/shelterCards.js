import { LightningElement, wire } from 'lwc';
import getShelters from '@salesforce/apex/ShelterController.getShelters';

export default class ShelterCards extends LightningElement {
    shelters = [];

    @wire(getShelters)
    wiredShelters({ data, error }) {
        if (data) {
            this.shelters = data;
            console.log('SHELTERS:', data);
        } else if (error) {
            console.error(error);
        }
    }
}