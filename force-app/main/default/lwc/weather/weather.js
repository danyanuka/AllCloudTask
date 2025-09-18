import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import SHIPPING_ADDRESS from '@salesforce/schema/Account.ShippingAddress';
import SHIPPING_CITY from '@salesforce/schema/Account.ShippingCity';


export default class Weather extends LightningElement {
  @api recordId
  shippingAddressLabel = ''
  shippingAddress;

  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  wiredObjectInfo({ data }) {
      if (data) {
          this.shippingAddressLabel = data.fields.ShippingAddress.label
      }
  }

  @wire(getRecord, { recordId: '$recordId', fields: [SHIPPING_CITY] })
    wiredAccount({ error, data }) {
        if (data) {
            this.shippingAddress = data.fields.ShippingCity.value
            console.log('shippingAddress' , this.shippingAddress)
            
        } else if (error) {
            this.shippingAddress = undefined
        }
    }



  

  get cardTile(){
    return `Weather In - ${this.shippingAddressLabel}`
  }

  get minMaxTempRange(){
    return `${Math.round(minTempC)}° - ${Math.round(maxTempC)}°`
  }


}