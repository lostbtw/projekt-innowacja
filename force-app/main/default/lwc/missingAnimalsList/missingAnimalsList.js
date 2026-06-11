import { LightningElement, track } from 'lwc';

export default class MissingAnimalsList extends LightningElement {
    dayDelta;
    @track animals = [];
    hasSearched = false;

    mockData = [
        {
            id: "ANO-0001",
            missingDate: "2025-05-20",
            name: "Mr. Whiskers",
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/c/c7/Tabby_cat_with_blue_eyes-3336579.jpg"
        },
        {
            id: "ANO-0002",
            missingDate: "2025-05-18",
            name: "Sir Barkalot",
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/6/69/June_odd-eyed-cat_cropped.jpg"
        },
        {
            id: "ANO-0003",
            missingDate: "2025-05-10",
            name: "Bugs",
            imageUrl: "https://upload.wikimedia.org/wikipedia/commons/8/87/20231125_housecat_south_meadows_PD100306.jpg"
        }
    ];

    handleDayDeltaChange(event) {
        this.dayDelta = event.target.value;
    }

    handleSearch() {
        this.hasSearched = true;
        
        // TODO: 
        // Placeholder for future Apex integration
        // getAnimalsWithImages({ dayDelta: this.dayDelta })
        //     .then(result => { this.animals = result; })
        //     .catch(error => { console.error('Fetch error', error); });

        this.animals = this.mockData;
    }

}