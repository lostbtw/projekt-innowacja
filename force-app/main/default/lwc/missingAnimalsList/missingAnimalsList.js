import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAnimalsWithImages from '@salesforce/apex/AnimalController.getAnimalsWithImages';
import updateFoundStatus from '@salesforce/apex/AnimalController.updateFoundStatus';
import postMissingAnimal from '@salesforce/apex/AnimalController.postMissingAnimal';

export default class MissingAnimalsList extends LightningElement {
    @track animals = [];
    dayDelta;
    isLoading = false;
    hasSearched = false;

    isModalOpen = false;
    selectedAnimalId;
    selectedAnimalName;

    isAddModalOpen = false;
    @track newAnimal = {
        name: '', breed: '', age: null, size: '', imageUrl: '', uniqueFeatures: '',
        disappearanceDate: null, address: '', description: '',
        disappearancePlaceLatitude: null, disappearancePlaceLongitude: null
    };

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

    openAddModal() {
        this.isAddModalOpen = true;
        this.newAnimal = {
            name: '', breed: '', age: null, size: '', imageUrl: '', uniqueFeatures: '',
            disappearanceDate: null, address: '', description: '',
            disappearancePlaceLatitude: null, disappearancePlaceLongitude: null
        };
    }

    closeAddModal() {
        this.isAddModalOpen = false;
    }

    handleAddInputChange(event) {
        const field = event.target.name;
        let val = event.target.value;
        if (field === 'age') {
            val = val ? parseInt(val, 10) : null;
        } else if (field === 'disappearancePlaceLatitude' || field === 'disappearancePlaceLongitude') {
            val = val ? parseFloat(val) : null;
        }
        this.newAnimal = { ...this.newAnimal, [field]: val };
    }

    submitNewAnimal() {
        const allValid = [...this.template.querySelectorAll('.slds-modal_medium lightning-input, .slds-modal_medium lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            
        if (!allValid) {
            this.showToast('Error', 'Please fill in all required fields correctly.', 'error');
            return;
        }

        const hasAddress = !!this.newAnimal.address;
        const hasCoords = (this.newAnimal.disappearancePlaceLatitude != null && this.newAnimal.disappearancePlaceLongitude != null);

        if (!hasAddress && !hasCoords) {
            this.showToast('Error', 'You must provide either an Address or both Latitude and Longitude.', 'error');
            return;
        }

        this.isLoading = true;
        this.isAddModalOpen = false;

        let formattedDate = this.newAnimal.disappearanceDate;
        if (formattedDate) {
            const d = new Date(formattedDate);
            const pad = (n) => n.toString().padStart(2, '0');
            formattedDate = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
        }
        const payload = {
            missingAnimalWrapper: {
            report: {
                address: this.newAnimal.address ? this.newAnimal.address : null,
                disappearancePlaceLongitude: this.newAnimal.disappearancePlaceLongitude,
                disappearancePlaceLatitude: this.newAnimal.disappearancePlaceLatitude,
                disappearanceDate: formattedDate,
                description: this.newAnimal.description ? this.newAnimal.description : null
            },
            animal: {
                name: this.newAnimal.name ? this.newAnimal.name : null,
                imageUrl: this.newAnimal.imageUrl ? this.newAnimal.imageUrl : null,
                breed: this.newAnimal.breed ? this.newAnimal.breed : null,
                age: this.newAnimal.age,
                uniqueFeatures: this.newAnimal.uniqueFeatures ? this.newAnimal.uniqueFeatures : null,
                size: this.newAnimal.size ? this.newAnimal.size : null
            }
            }
        };

        postMissingAnimal({ jsonBody: JSON.stringify(payload) })
            .then(() => {
                this.showToast('Success', 'Missing animal reported successfully.', 'success');
                if (!this.dayDelta) {
                    this.dayDelta = 7;
                }
                this.handleSearch();
            })
            .catch(error => {
                console.error('Post error', error);
                let errorMessage = 'An error occurred while reporting the animal.';
                if (error && error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast('Error', errorMessage, 'error');
                this.isAddModalOpen = true; 
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}