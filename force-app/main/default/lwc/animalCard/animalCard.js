import { LightningElement, api } from 'lwc';

export default class AnimalCard extends LightningElement {
    @api animalName;
    @api imageUrl;
    @api isClickable = false;
    imageError = false;

    get hasImage() {
        return !!this.imageUrl && !this.imageError && String(this.imageUrl).startsWith('http');
    }

    handleImageError() {
        this.imageError = true;
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