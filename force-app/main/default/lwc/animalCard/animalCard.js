import { LightningElement, api } from 'lwc';

export default class AnimalCard extends LightningElement {
    @api animalName;
    @api imageUrl;
    @api isClickable = false;

    get hasImage() {
        return !!this.imageUrl;
    }

    get titleClass() {
        return this.isClickable ? 'pet-name clickable-name' : 'pet-name';
    }

    handleTitleClick() {
        if (this.isClickable) {
            this.dispatchEvent(new CustomEvent('animalclick'));
        }
    }
}