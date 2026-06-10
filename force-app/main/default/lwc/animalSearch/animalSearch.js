import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getShelterOptions from '@salesforce/apex/AnimalSearchController.getShelterOptions';
import getBreedOptions from '@salesforce/apex/AnimalSearchController.getBreedOptions';
import searchAnimals from '@salesforce/apex/AnimalSearchController.searchAnimals';

export default class AnimalSearch extends LightningElement {
    @track shelterOptions = [{ label: 'Any', value: '' }];
    @track breedOptions = [{ label: 'Any', value: '' }];
    

    
    @track genderOptions = [
        { label: 'Any', value: '' },
        { label: 'Male', value: 'Male' },
        { label: 'Female', value: 'Female' },
        { label: 'Unknown', value: 'Unknown' }
    ];

    @track selectedShelter = '';
    @track selectedBreed = '';
    @track ageFrom = null;
    @track ageTo = null;
    @track selectedGender = '';

    @track animals = [];
    @track noResults = false;

    connectedCallback() {
        this.fetchOptions();
        this.performSearch();
    }

    fetchOptions() {
        getShelterOptions()
            .then(result => {
                this.shelterOptions = [{ label: 'Any', value: '' }, ...result];
            })
            .catch(error => {
                console.error('Error fetching shelters:', error);
            });

        getBreedOptions()
            .then(result => {
                this.breedOptions = [{ label: 'Any', value: '' }, ...result];
            })
            .catch(error => {
                console.error('Error fetching breeds:', error);
            });
    }

    handleShelterChange(event) {
        this.selectedShelter = event.detail.value;
    }

    handleBreedChange(event) {
        this.selectedBreed = event.detail.value;
    }

    handleAgeFromChange(event) {
        this.ageFrom = event.detail.value;
    }

    handleAgeToChange(event) {
        this.ageTo = event.detail.value;
    }

    handleGenderChange(event) {
        this.selectedGender = event.detail.value;
    }

    handleSearch() {
        if (this.ageFrom && this.ageFrom < 0) {
            this.showToast('Error', 'Age From cannot be negative.', 'error');
            return;
        }
        if (this.ageTo && this.ageTo < 0) {
            this.showToast('Error', 'Age To cannot be negative.', 'error');
            return;
        }
        if (this.ageFrom && this.ageTo && Number(this.ageFrom) > Number(this.ageTo)) {
            this.showToast('Error', 'Age From cannot be greater than Age To.', 'error');
            return;
        }
        this.performSearch();
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    performSearch() {
        searchAnimals({
            shelterId: this.selectedShelter,
            breed: this.selectedBreed,
            ageFrom: this.ageFrom ? Number(this.ageFrom) : null,
            ageTo: this.ageTo ? Number(this.ageTo) : null,
            gender: this.selectedGender
        })
        .then(result => {
            this.animals = result;
            this.noResults = this.animals.length === 0;
        })
        .catch(error => {
            console.error('Error searching animals:', error);
            this.animals = [];
            this.noResults = true;
        });
    }
}