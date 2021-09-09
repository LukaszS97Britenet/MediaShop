import { LightningElement, api } from 'lwc';
import deleteWarehouseLineItem from '@salesforce/apex/WarehouseController.deleteWarehouseLineItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WAREHOUSE_LINE_ITEM_OBJECT from '@salesforce/schema/Warehouse_Line_Item__c';

import search from '@salesforce/label/c.Search';
import error from '@salesforce/label/c.errorLwc';
import success from '@salesforce/label/c.SuccessToast';
import name from '@salesforce/label/c.MS_Name';
import capacity from '@salesforce/label/c.Capacity';
import amount from '@salesforce/label/c.amount';
import deleteItem from '@salesforce/label/c.Delete';
import cancel from '@salesforce/label/c.Cancel';
import confirmDeletion from '@salesforce/label/c.Confirm_deletion';
import confirm from '@salesforce/label/c.confirm';
import confirmDeleteWarehouseItem from '@salesforce/label/c.confirmDeleteWarehouseItem';
import itemDeletedSucc from '@salesforce/label/c.itemDeletedSucc';
import ilemDeleteFail from '@salesforce/label/c.ilemDeleteFail';

export default class WarehouseLineItemTile extends LightningElement {

    @api warehouseLineItem;
    productImg = '';
    isModalOpen = false;

    label = {
        name,
        capacity,
        amount,
        deleteItem,
        cancel,
        confirmDeletion,
        confirm,
        confirmDeleteWarehouseItem,
        error,
        success,
        itemDeletedSucc,
        ilemDeleteFail
    };

    connectedCallback(){
        this.productImg = '/sfc/servlet.shepherd/document/download/' + this.warehouseLineItem.Product__r.MainImageId__c;
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    deleteItem(event) {
        console.log('1');
        deleteWarehouseLineItem({ warehouseLineItem: { ...this.warehouseLineItem, sobjectType: WAREHOUSE_LINE_ITEM_OBJECT.objectApiName }})
            .then((response) => {
                console.log(response);
                if(response) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.success,
                            message: itemDeletedSucc,
                            variant: this.label.success
                        })
                    );
                    this.isModalOpen = false;
                    console.log('2');
                    const custEvent = new CustomEvent(
                        'callpasstoparent', {
                        });
                    this.dispatchEvent(custEvent);
                    console.log('4');
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.error,
                            message: ilemDeleteFail,
                            variant: this.label.error
                        })
                    );
                }
            })
            .catch((err) => {
                console.error(err)
            });
    }
}