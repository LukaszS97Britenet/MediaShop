import { LightningElement } from 'lwc';
import searchByPhrase from '@salesforce/apex/WarehouseController.searchByPhrase';
import WAREHOUSE_OBJECT from '@salesforce/schema/Warehouse__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import error from '@salesforce/label/c.errorLwc';
import noWarehouses from '@salesforce/label/c.noRecordsFound';
import search from '@salesforce/label/c.Search';
import warehouses from '@salesforce/label/c.Warehouses';

export default class WarehouseManager extends LightningElement {
    label = {
        error,
        noWarehouses,
        search,
        warehouses
    };
    loaded = false;
    searchedPhrase = '';
    warehouses;
    mapMarkers = [];

    handleFieldChange(e) {
        this.searchedPhrase = e.target.value;
    }

    connectedCallback(){
        this.search();
    }

    search () {
        searchByPhrase({ phrase: this.searchedPhrase })
            .then((warehouses) => {
                this.warehouses = warehouses;
                if(this.warehouses.length == 0) {
                    this.loaded = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.error,
                            message: this.label.noWarehouses,
                            variant: this.label.error
                        })
                    );
                } else {
                    this.loaded = true;
                    this.handleWarehouseListUpdate(warehouses)
                }
            })
            .catch((err) => {
                console.error(err)
            });
    }

    handleWarehouseListUpdate(warehouses) {
        this.mapMarkers = warehouses.map(warehouse => {
          const Latitude = warehouse.Geolocation__c.latitude;
          const Longitude = warehouse.Geolocation__c.longitude;
          return {
            location: { Latitude, Longitude },
            title: warehouse.Name,
            description: `Coords: ${Latitude}, ${Longitude}`
          };
        });
      }

}