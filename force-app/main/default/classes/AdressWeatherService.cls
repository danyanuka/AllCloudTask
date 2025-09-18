public with sharing class AdressWeatherService {

    public void getTomorrowWeatherByCity(String city) {
        String endpoint = 'forecast.json?q=' + EncodingUtil.urlEncode(city, 'UTF-8') + '&days=2';
        try {

            HttpRequest req = new HttpRequest();
            // Using a Named Credential
            req.setEndpoint('callout:WeatherApi/' + endpoint); 
            req.setMethod('GET');
        
            Http http = new Http();
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == 200){
                Map<String, Object> jsonRes = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> forecastDays = (List<Object>) ((Map<String, Object>)jsonRes.get('forecast')).get('forecastday');
                
                Map<String, Object> tomorrowsData = (Map<String, Object>) forecastDays[1];
                Map<String, Object> tomorrow = (Map<String, Object>) tomorrowsData.get('day');
                weatherInfo tomorrowsInfo = new weatherInfo(tomorrow);
                
                System.debug('Tomorrow summary: ' + tomorrowsInfo);
            }
            else {
                System.debug('Error: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }


    public class WeatherInfo {
        @AuraEnabled public String textDescription;
        @AuraEnabled public String iconUrl;
        @AuraEnabled public Decimal minTemp;
        @AuraEnabled public Decimal maxTemp;
        @AuraEnabled public Decimal avgTemp;

        public WeatherInfo(Map<String, Object> dayData) {
           if(dayData != null){
               Map<String, Object> condition = (Map<String, Object>) dayData.get('condition');
               this.textDescription = (String) condition.get('text');
               this.iconUrl = (String) condition.get('icon');
               this.minTemp = (Decimal) dayData.get('mintemp_c');
               this.maxTemp = (Decimal) dayData.get('maxtemp_c');
               this.avgTemp = (Decimal) dayData.get('avgtemp_c');
           }
        }
    }
}