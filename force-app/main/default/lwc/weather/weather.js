import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';


export default class Weather extends LightningElement {
  @api recordId
  shippingAddressLabel = ''

  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  wiredObjectInfo({ data }) {
      if (data) {
          this.shippingAddressLabel = data.fields.ShippingAddress.label;
      }
  }

  @wire(getRecord, { recordId: '$recordId', fields: [] })
  account;
  

  get cardTile(){
    return `Weather In - ${this.shippingAddressLabel}`
  }


}