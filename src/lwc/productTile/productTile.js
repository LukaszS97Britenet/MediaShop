import { LightningElement, api } from 'lwc';
import Product2_OBJECT from '@salesforce/schema/Product2';
import addWarehouseItem from '@salesforce/apex/WarehouseController.addWarehouseItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import name from '@salesforce/label/c.MS_Name';
import capacity from '@salesforce/label/c.Capacity';
import success from '@salesforce/label/c.SuccessToast';
import error from '@salesforce/label/c.errorLwc';
import removeError from '@salesforce/label/c.removeError';
import capacityError from '@salesforce/label/c.capacityError';
import successAddProdToWarehouse from '@salesforce/label/c.successAddProdToWarehouse';
import notZero from '@salesforce/label/c.notZero';
import amountPlaceholder from '@salesforce/label/c.amountPlaceholder';

export default class ProductTile extends LightningElement {

    @api product;
    @api recordId;
    productImg = '';
    amount;

    label = {
        name,
        capacity,
        success,
        error,
        removeError,
        capacityError,
        successAddProdToWarehouse,
        notZero,
        amountPlaceholder
    };

    handleFieldChange(e) {
        this.amount = e.target.value;
    }

    connectedCallback(){
        this.productImg = '/sfc/servlet.shepherd/document/download/' + this.product.MainImageId__c;
    }

    changeProductAmount() {
        if(this.amount === 0 || this.amount === undefined) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.error,
                    message: this.label.notZero,
                    variant: this.label.error
                })
            );
        } else {
            addWarehouseItem({ amount: this.amount.match(/[+\-0-9]+/g)[0], warehouseId: this.recordId, product: { ...this.product, sobjectType: Product2_OBJECT.objectApiName } })
                   .then((response) => {
                       this.amount = 0;
                       if(response === 'Remove_Error') {
                           this.dispatchEvent(
                               new ShowToastEvent({
                                   title: this.label.error,
                                   message: this.label.removeError,
                                   variant: this.label.error
                               })
                           );
                       } else if(response === 'Capacity_Error') {
                           this.dispatchEvent(
                               new ShowToastEvent({
                                   title: this.label.error,
                                   message: this.label.capacityError,
                                   variant: this.label.error
                               })
                           );
                       } else {
                           this.dispatchEvent(
                               new ShowToastEvent({
                                   title: this.label.success,
                                   message: this.label.successAddProdToWarehouse,
                                   variant: this.label.success
                               })
                           );
                       }
                   })
                   .catch((err) => console.error(err));
        }
    }
}