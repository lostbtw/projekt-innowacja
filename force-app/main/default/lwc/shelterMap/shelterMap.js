import { LightningElement, api, wire } from 'lwc';
import getSheltersInSameCity from '@salesforce/apex/ShelterController.getSheltersInSameCity';

export default class ShelterMap extends LightningElement {
    @api recordId;

    mapMarkers = [];
    selectedMarkerValue = '';
    error;
    zoomLevel = 12;

    @wire(getSheltersInSameCity, { shelterId: '$recordId' })
    wiredShelters({ error, data }) {
        console.log('>>> recordId:', this.recordId);
        console.log('>>> data:', JSON.stringify(data));
        console.log('>>> error:', JSON.stringify(error));
        if (data) {
            this.error = undefined;
            this.buildMarkers(data);
        } else if (error) {
            this.error = error.body?.message || 'Failed to load shelters.';
            this.mapMarkers = [];
        }
    }

    buildMarkers(shelters) {
        this.mapMarkers = shelters.map(shelter => {
            const isCurrent = shelter.Id === this.recordId;

            return {
                location: {
                    Street: shelter.Street__c || '',
                    City: shelter.City__c || '',
                    State: shelter.State__c || '',
                    PostalCode: shelter.PostalCode__c || '',
                    Country: shelter.Country__c || ''
                },
                value: shelter.Id,
                title: isCurrent
                    ? `⭐ ${shelter.Name} (You are here)`
                    : shelter.Name,
                description: isCurrent
                    ? 'Currently viewed shelter'
                    : `${shelter.Street__c || ''}, ${shelter.City__c || ''}`,
                icon: isCurrent
                    ? 'standard:location'
                    : 'standard:account'
            };
        });

        this.selectedMarkerValue = this.recordId;
    }

    get hasMarkers() {
        return this.mapMarkers.length > 0;
    }

    get cardTitle() {
        return `Shelters in this city (${this.mapMarkers.length})`;
    }
}