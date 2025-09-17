public with sharing class AdressWeatherService {

    public void getTomorrowWeatherByCity(String city) {
        String endpoint = 'forecast.json?q=' + EncodingUtil.urlEncode(city, 'UTF-8') + '&days=2';
        try {

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:WeatherApi/' + endpoint); 
            req.setMethod('GET');
        
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('res' + res);

            if(res.getStatusCode() == 200){
                Map<String, Object> jsonRes = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> forecastDays = (List<Object>) ((Map<String, Object>)jsonRes.get('forecast')).get('forecastday');
                
                Map<String, Object> tomorrowsData = (Map<String, Object>) forecastDays[1];
                Map<String, Object> day = (Map<String, Object>) tomorrowsData.get('day');
                
                System.debug('Tomorrow summary: ' + day);
            }
            else {
                System.debug('Error: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }


    public class WeatherInfo {
        @AuraEnabled public String condition;
        @AuraEnabled public String iconUrl;
        @AuraEnabled public Decimal maxTempC;
        @AuraEnabled public Decimal minTempC;
    }
}