import { LightningElement, track } from 'lwc';
import getAnimalsWithImages from '@salesforce/apex/AnimalController.getAnimalsWithImages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MissingAnimalsList extends LightningElement {
    dayDelta;
    @track animals = [];
    hasSearched = false;
    isLoading = false;

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
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}