import { LightningElement, api, wire , track} from 'lwc'
import { getRecord } from 'lightning/uiRecordApi'
import { getObjectInfo } from 'lightning/uiObjectInfoApi'
//Schemas
import ACCOUNT_OBJECT from '@salesforce/schema/Account'
import SHIPPING_CITY from '@salesforce/schema/Account.ShippingCity'
import NAME from '@salesforce/schema/Account.Name'
//Apex
import getTomorrowWeatherByCity from '@salesforce/apex/AdressWeatherService.getTomorrowWeatherByCity'


export default class Weather extends LightningElement {
  @api recordId

  weatherInfo
  
  shippingAddressLabel = ''
  shippingCity
  accountName
  isLoading = false

  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountObjectInfo({ data }) {
        if (data) {
            this.shippingAddressLabel = data.fields.ShippingAddress.label
            this.billingAddressLabel = data.fields.BillingAddress.label
        }
  }

  //API Req will execute On Initial load and whenever fields[] change. 
  @wire(getRecord, { recordId: '$recordId', fields: [NAME,SHIPPING_CITY] })
    wiredAccount({ error, data }) {
        if (data) {
            const newCity = data.fields.ShippingCity.value;
            if (newCity !== this.shippingCity) { //Avoids redundant API calls
                this.shippingCity = newCity;
                this.accountName = data.fields.Name.value || `Account's`;
                this.callWeatherService();
            }
        } else if (error) {
            this.weatherInfo = undefined;
            this.shippingCity = undefined
            console.error('Error fetching account record', error);
        }
    }

  async callWeatherService() {
      try {
        console.log('RAN!');
        
          this.weatherInfo = await getTomorrowWeatherByCity({ city: this.shippingCity })
      } catch (error) {
          console.error('Error fetching weather:', error)
      } finally{
          this.isLoading = false
      }
  }


  get cardTile(){
      return `Tomorrow's weather in ${this.accountName}'s ${this.shippingAddressLabel}`
  }

  get minTempRound(){
    return `${Math.round(this.weatherInfo.minTempC)}°`
  }

  get maxTempRound(){
    return `${Math.round(this.weatherInfo.maxTempC)}°`
  }


}