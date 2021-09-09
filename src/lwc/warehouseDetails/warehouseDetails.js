import { LightningElement, api } from 'lwc';
import searchProducts from '@salesforce/apex/WarehouseController.searchProducts';
import searchWarehouseLineItems from '@salesforce/apex/WarehouseController.searchWarehouseLineItems';
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import search from '@salesforce/label/c.Search';
import error from '@salesforce/label/c.errorLwc';
import noProducts from '@salesforce/label/c.noProducts';
import noProductsInWarehouse from '@salesforce/label/c.noProductsInWarehouse';
import cancel from '@salesforce/label/c.Cancel';
import editProductAmountInWarehouse from '@salesforce/label/c.editProductAmountInWarehouse';

export default class WarehouseDetails extends LightningElement {

    label = {
        error,
        search,
        noProducts,
        noProductsInWarehouse,
        cancel,
        editProductAmountInWarehouse
    };
    @api recordId;
    loaded = true;
    searchedPhrase = '';
    searchedPhraseForWarehouse = '';
    products;
    warehouseLineItems;
    isModalOpen = false;

    openModal() {
        this.isModalOpen = true;
        this.searchedPhrase = '';
        this.search();
    }
    closeModal() {
        this.isModalOpen = false;
        this.searchWarehouseLineItems();
    }

    handleFieldChange(e) {
        this.searchedPhrase = e.target.value;
    }

    handleFieldChangeForWarehouse(e) {
        this.searchedPhraseForWarehouse = e.target.value;
    }

    connectedCallback() {
        this.searchWarehouseLineItems();
    }

    searchWarehouseLineItems() {
        searchWarehouseLineItems({ phrase: this.searchedPhraseForWarehouse, warehouseId: this.recordId })
            .then((warehouseLineItems) => {
                this.warehouseLineItems = warehouseLineItems;
                console.log(warehouseLineItems);
                if(this.warehouseLineItems.length == 0) {
                    this.loaded = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.error,
                            message: this.label.noProductsInWarehouse,
                            variant: this.label.error
                        })
                    );
                } else {
                    this.loaded = true;
                }
            })
            .catch((err) => {
                console.error(err)
            });
    }

    search() {
        searchProducts({ phrase: this.searchedPhrase })
            .then((products) => {
                this.products = products;
                if(this.products.length == 0) {
                    this.loaded = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.error,
                            message: this.label.noProducts,
                            variant: this.label.error
                        })
                    );
                } else {
                    this.loaded = true;
                }
            })
            .catch((err) => {
                console.error(err)
            });
    }

    passToParent(event){
        this.searchWarehouseLineItems();
    }
}