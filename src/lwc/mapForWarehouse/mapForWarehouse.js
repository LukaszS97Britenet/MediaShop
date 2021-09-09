import { LightningElement, api } from 'lwc';
import searchWarehouse from '@salesforce/apex/WarehouseController.searchWarehouse';
import WAREHOUSE_OBJECT from '@salesforce/schema/Warehouse__c';

import warehouses from '@salesforce/label/c.Warehouses';

export default class MapForWarehouse extends LightningElement {
    label = {
        warehouses
    };
    warehouse;
    mapMarkers = [];
    @api recordId;

    connectedCallback(){
        console.log(this.recordId);
        this.search();
    }

    search() {
        searchWarehouse({ id: this.recordId })
            .then((warehouse) => {
                this.warehouse = warehouse;
                this.handleWarehouseListUpdate(warehouse);
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