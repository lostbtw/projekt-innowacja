import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAnimalsWithImages from '@salesforce/apex/AnimalController.getAnimalsWithImages';
import updateFoundStatus from '@salesforce/apex/AnimalController.updateFoundStatus';

export default class MissingAnimalsList extends LightningElement {
    @track animals = [];
    dayDelta;
    isLoading = false;
    hasSearched = false;

    isModalOpen = false;
    selectedAnimalId;
    selectedAnimalName;

    handleDayDeltaChange(event) {
        this.dayDelta = event.target.value;
    }

    handleSearch() {
        this.hasSearched = true;
        this.isLoading = true;
        
        const delta = this.dayDelta ? parseInt(this.dayDelta, 10) : null;

        getAnimalsWithImages({ dayDelta: delta })
            .then(result => { 
                this.animals = result; 
            })
            .catch(error => { 
                console.error('Fetch error', error); 
                let errorMessage = 'An error occurred while fetching animals.';
                if (error && error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast('Error', errorMessage, 'error');
                this.animals = [];
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    handleAnimalClick(event) {
        this.selectedAnimalId = event.currentTarget.dataset.id;
        const animal = this.animals.find(a => a.id === this.selectedAnimalId);
        this.selectedAnimalName = animal ? animal.name : this.selectedAnimalId;
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedAnimalId = null;
        this.selectedAnimalName = null;
    }

    confirmFound() {
        this.isLoading = true;
        this.isModalOpen = false;
        
        updateFoundStatus({ animalId: this.selectedAnimalId, found: true })
            .then(() => {
                this.showToast('Success', `${this.selectedAnimalName} has been marked as found.`, 'success');
                this.animals = this.animals.filter(a => a.id !== this.selectedAnimalId);
            })
            .catch(error => {
                console.error('Update error', error);
                let errorMessage = 'An error occurred while updating status.';
                if (error && error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}