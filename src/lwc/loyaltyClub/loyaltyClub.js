import { LightningElement, wire, track } from 'lwc';
import getContact from '@salesforce/apex/ContactController.getContact';
import upsertContact from '@salesforce/apex/ContactController.upsertContact';
import leaveClub from '@salesforce/apex/ContactController.leaveClub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import jointoourclub from '@salesforce/label/c.Jointoourclub';
import success from '@salesforce/label/c.SuccessToast';
import clubTitle from '@salesforce/label/c.ClubTitle';
import youLeftClub from '@salesforce/label/c.You_left_our_club';
import leftClub from '@salesforce/label/c.Left_The_Club';
import contactDataUpdated from '@salesforce/label/c.Contact_data_updated';

export default class LoyaltyClub extends LightningElement {
    label = {
            jointoourclub,
            success,
            contactDataUpdated,
            clubTitle,
            youLeftClub,
            leftClub
        };
    contact = {};
    loaded = false;
    leave;
    stay;

    connectedCallback(){
        this.loadContact();
    }

    loadContact() {
        getContact()
            .then(result => {
                this.contact = JSON.parse(JSON.stringify(result));
                this.changeButtonsEnable();
                this.loaded = true;
            })
            .catch(error => {
                console.error(error);
            });
    }

    leaveClub() {
        leaveClub({ con: { ...this.contact, sobjectType: CONTACT_OBJECT.objectApiName } })
            .then((contact) => {
                this.contact = contact;
                this.changeButtonsEnable();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.success,
                        message: this.label.youLeftClub,
                        variant: this.label.success
                    })
                );
            })
            .catch((err) => console.error(err));
    }

    joinToClub() {
        upsertContact({ con: { ...this.contact, sobjectType: CONTACT_OBJECT.objectApiName } })
            .then((contact) => {
                this.contact = contact;
                this.changeButtonsEnable();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.success,
                        message: this.label.contactDataUpdated,
                        variant: this.label.success
                    })
                );
            })
            .catch((err) => console.error(err));
    }

    handleFieldChange(e) {
        this.contact[e.currentTarget.fieldName] = e.target.value;
    }

    changeButtonsEnable(){
        console.log(this.contact.Is_In_Club__c);
        if(this.contact.Is_In_Club__c) {
            this.leave = false;
            this.stay = true;
        } else {
            this.leave = true;
            this.stay = false;
        }
    }

}