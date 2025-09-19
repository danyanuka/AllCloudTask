import { LightningElement, api, wire} from 'lwc'
import { getRecord } from 'lightning/uiRecordApi'
import { getObjectInfo } from 'lightning/uiObjectInfoApi'
//Schemas
import ACCOUNT_OBJECT from '@salesforce/schema/Account'
import SHIPPING_CITY from '@salesforce/schema/Account.ShippingCity'
import BILLING_CITY from '@salesforce/schema/Account.BillingCity'
import NAME from '@salesforce/schema/Account.Name'
//Apex
import getTomorrowWeatherByCity from '@salesforce/apex/AdressWeatherService.getTomorrowWeatherByCity'


export default class Weather extends LightningElement {
  @api recordId

  weatherInfo
  shippingAddressLabel = ''
  billingAddressLabel = ''
  shippingCity
  billingCity
  accountFirstName

  isLoading = true
  selectedAddress = 'shipping'

  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountObjectInfo({ data }) {
        if (data) {
            this.shippingAddressLabel = data.fields.ShippingAddress.label
            this.billingAddressLabel = data.fields.BillingAddress.label
        }
  }
  
  @wire(getRecord, { recordId: '$recordId', fields: [NAME,SHIPPING_CITY, BILLING_CITY] })
    wiredAccount({ error, data }) {
    console.log('Reached wiredAccount')
        if (data) {
            this.shippingCity = data.fields.ShippingCity.value
            this.billingCity = data.fields.BillingCity.value
            this.accountFirstName = (data.fields.Name.value || `Account's`).split(' ')[0];
            const cityToFetch = this.selectedAddress === 'billing' ? this.billingCity : this.shippingCity
            //cityToFetch !== this.weatherInfo?.cityName prevents redundant API calls
            //On Inital load when weatherInfo does not exist it will evaluate to undef and safely use the default selectedAddress
            if (cityToFetch && cityToFetch !== this.weatherInfo?.cityName) {        
                this.callWeatherService(cityToFetch)
            }
        } else if (error) {
            this.weatherInfo = undefined
            console.error('Error fetching account record', error)
        }
    }

  //This method is called either from the wiredAccount (On Inital load AND when accounts address fields change)
  // Or from Btn click (handleSwitchAddressField)
  async callWeatherService(city) {
      try {
          console.log('Reached Weather Service')
          this.weatherInfo = await getTomorrowWeatherByCity({city})
      } catch (error) {
          console.error('Error fetching weather:', error)
      } finally{
          this.isLoading = false
      }
  }

  handleSwitchAddressField(){
      this.selectedAddress = this.selectedAddress === 'shipping' ? 'billing' : 'shipping'
      const cityToFetch = this.selectedAddress === 'billing' ? this.billingCity : this.shippingCity 
      if (cityToFetch) {
          this.isLoading = true
          this.callWeatherService(cityToFetch)
    } else {
          this.weatherInfo = undefined
    }
  }


  get cardTitle(){
      return `Tomorrow's weather in ${this.accountFirstName}'s`
  }

  get currentAddressLabel() {
      return this.selectedAddress === 'billing' ? this.billingAddressLabel : this.shippingAddressLabel;
  }

  // The opposite of currentAddressLabel   
  get btnAddressLabel(){
      return this.selectedAddress === 'billing' ? this.shippingAddressLabel : this.billingAddressLabel
  }

  get minTempRound(){
      return `${Math.round(this.weatherInfo.minTempC)}°`
  }

  get maxTempRound(){
      return `${Math.round(this.weatherInfo.maxTempC)}°`
  }

}