import { LightningElement, wire } from 'lwc';
import getShelters from '@salesforce/apex/ShelterController.getShelters';

export default class ShelterCards extends LightningElement {
    shelters = [];

    @wire(getShelters)
    wiredShelters({ data, error }) {
        if (data) {
            this.shelters = data.map(s => {
                return {
                    ...s,

                    mon: this.formatDay(s.Monday_Open__c, s.Monday_Close__c),
                    tue: this.formatDay(s.Tuesday_Open__c, s.Tuesday_Close__c),
                    wed: this.formatDay(s.Wednesday_Open__c, s.Wednesday_Close__c),
                    thu: this.formatDay(s.Thursday_Open__c, s.Thursday_Close__c),
                    fri: this.formatDay(s.Friday_Open__c, s.Friday_Close__c),
                    sat: this.formatDay(s.Saturday_Open__c, s.Saturday_Close__c),
                    sun: this.formatDay(s.Sunday_Open__c, s.Sunday_Close__c)
                };
            });
        } else if (error) {
            console.error('ERROR:', error);
        }
    }

    formatDay(open, close) {
        if (!open || !close) {
            return 'Closed';
        }

        return `${this.formatTime(open)} - ${this.formatTime(close)}`;
    }

    formatTime(ms) {
        if (ms === null || ms === undefined) return '';

        const date = new Date(ms);

        return date.toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit'
        });
    }
}