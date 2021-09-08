import { LightningElement } from 'lwc';
import getUsers from '@salesforce/apex/ContactController.getUsers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import noMembers from '@salesforce/label/c.NoMembers';

export default class LoyaltyManager extends LightningElement {
    label = {
            noMembers
        };
    loaded = false;
    isArrayEmpty = true;
    users;

    passToParent(event){
        this.loadUsers();
        console.log(this.users);
    }

    connectedCallback(){
        this.loadUsers();
    }

    loadUsers() {
        getUsers()
            .then(result => {
                this.users = JSON.parse(JSON.stringify(result));
                if(this.users.length == 0) {
                    this.isArrayEmpty = true;
                } else {
                    this.isArrayEmpty = false;
                }
                this.loaded = true;
            })
            .catch(error => {
                console.error(error);
            });
    }
}