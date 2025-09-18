public with sharing class AdressWeatherService {

    public weatherInfo getTomorrowWeatherByCity(String city) {
        String endpoint = 'forecast.json?q=' + EncodingUtil.urlEncode(city, 'UTF-8') + '&days=2';
        try {
            HttpResponse res = sendGetRequest(endpoint);
            if(res.getStatusCode() == 200){
                Map<String, Object> tomorrow = parseWeatherDay(res.getBody(), 1);
                weatherInfo tomorrowsInfo = new weatherInfo(tomorrow);
                System.debug('Tomorrow summary: ' + tomorrowsInfo);
                return tomorrowsInfo;
            }
            else {
                System.debug('Error: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }

        return null; 
    }

    private HttpResponse sendGetRequest(String endpoint){
        HttpRequest req = new HttpRequest();
        // Using a Named Credential
        req.setEndpoint('callout:WeatherApi/' + endpoint); 
        req.setMethod('GET');
    
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }


    private Map<String, Object> parseWeatherDay(String jsonBody, Integer dayIndex ) {
        // Weather API forecast Res Structure
        // res{
        //  "forecast": {
        //      "forecastday": [
        //          {today{day}},
        //          {tommorow{day}}
        // }
        Map<String, Object> jsonRes = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
        List<Object> forecastDays = (List<Object>) ((Map<String, Object>)jsonRes.get('forecast')).get('forecastday');
        Map<String, Object> tomorrowsData = (Map<String, Object>) forecastDays[dayIndex];
        Map<String, Object> tomorrow = (Map<String, Object>) tomorrowsData.get('day');
    
        return tomorrow;
    }


    public class WeatherInfo {
        @AuraEnabled public String iconUrl;
        @AuraEnabled public String textDescription;
        @AuraEnabled public Decimal minTemp;
        @AuraEnabled public Decimal maxTemp;
        @AuraEnabled public Decimal avgTemp;

        public WeatherInfo(Map<String, Object> dayData) {
           if(dayData != null){
               Map<String, Object> condition = (Map<String, Object>) dayData.get('condition');
               this.iconUrl = (String) condition.get('icon');
               this.textDescription = (String) condition.get('text');
               this.minTemp = (Decimal) dayData.get('mintemp_c');
               this.maxTemp = (Decimal) dayData.get('maxtemp_c');
               this.avgTemp = (Decimal) dayData.get('avgtemp_c');
           }
        }
    }
}