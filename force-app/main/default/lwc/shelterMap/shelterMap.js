import { LightningElement, api, wire } from "lwc";
import getSheltersInSameCity from "@salesforce/apex/ShelterMapController.getSheltersInSameCity";

export default class ShelterMap extends LightningElement {
  @api recordId;

  mapMarkers = [];
  selectedMarkerValue = "";
  error;
  zoomLevel = 12;

  @wire(getSheltersInSameCity, { shelterId: "$recordId" })
  wiredShelters({ error, data }) {
    if (data) {
      this.error = undefined;
      this.buildMarkers(data);
    } else if (error) {
      this.error = error.body?.message || "Failed to load shelters.";
      this.mapMarkers = [];
    }
  }

  buildMarkers(shelters) {
    this.mapMarkers = shelters.map((shelter) => ({
      location: {
        Street: shelter.Address__Street__s || "",
        City: shelter.Address__City__s || "",
        State: shelter.Address__StateCode__s || "",
        PostalCode: shelter.Address__PostalCode__s || "",
        Country: shelter.Address__CountryCode__s || ""
      },
      value: shelter.Id,
      title: shelter.Name,
      description: `${shelter.Address__Street__s || ""}, ${shelter.Address__City__s || ""}`,
      icon: "standard:account"
    }));
  }

  get hasMarkers() {
    return this.mapMarkers.length > 0;
  }

  get cardTitle() {
    return `Shelters in the same city (${this.mapMarkers.length})`;
  }
}
