import { LightningElement, api, wire, track } from 'lwc';
import leaveClub from '@salesforce/apex/ContactController.leaveClub';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import deleteFromClub from '@salesforce/label/c.Delete_From_Club';
import userDeletedFromClub from '@salesforce/label/c.User_deeted_fro_club';
import success from '@salesforce/label/c.SuccessToast';

export default class LoyaltyTile extends LightningElement {

    label = {
            deleteFromClub,
            userDeletedFromClub,
            success
        };
    @api user;

    deleteFromClub(event) {
        leaveClub({ con: { ...this.user.Contact, sobjectType: CONTACT_OBJECT.objectApiName } })
              .then((contact) => {
                  const custEvent = new CustomEvent(
                      'callpasstoparent', {
                      });
                  this.dispatchEvent(custEvent);
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: this.label.success,
                          message: this.label.userDeletedFromClub,
                          variant: this.label.success
                      })
                  );
              })
              .catch((err) => console.error(err));
    }
}