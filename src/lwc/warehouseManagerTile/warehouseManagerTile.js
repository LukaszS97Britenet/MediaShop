import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import showDetails from '@salesforce/label/c.showDetails';
import name from '@salesforce/label/c.MS_Name';
import capacity from '@salesforce/label/c.Capacity';

export default class WarehouseManagerTile extends NavigationMixin(LightningElement) {

    label = {
        showDetails,
        name,
        capacity
    };
    @api warehouse;

    goToWarehouse() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.warehouse.Id,
                objectApiName: 'Warehouse__c',
                actionName: 'view'
            }
        });
    }

}