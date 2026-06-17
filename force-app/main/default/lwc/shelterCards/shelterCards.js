import { LightningElement, track } from 'lwc';
import getShelters from '@salesforce/apex/ShelterController.getShelters';

export default class ShelterCards extends LightningElement {
    @track shelters = [];
    searchKey = '';
    searchInput = '';
    pageSize = 18;
    pageNumber = 1;
    isLoading = false;

    connectedCallback() {
        this.fetchShelters();
    }

    fetchShelters() {
        this.isLoading = true;
        getShelters({ 
            searchKey: this.searchKey, 
            pageSize: this.pageSize, 
            pageNumber: this.pageNumber 
        })
        .then(data => {
            const processed = data.map(s => {
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
            this.shelters = processed;
        })
        .catch(error => {
            console.error('ERROR:', error);
            this.shelters = [];
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    handleInputChange(event) {
        this.searchInput = event.target.value;
    }

    handleSearch() {
        this.searchKey = this.searchInput;
        this.pageNumber = 1;
        this.fetchShelters();
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.fetchShelters();
        }
    }

    handleNext() {
        this.pageNumber++;
        this.fetchShelters();
    }

    get disablePrevious() {
        return this.pageNumber <= 1;
    }

    get disableNext() {
        return this.shelters.length < this.pageSize;
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