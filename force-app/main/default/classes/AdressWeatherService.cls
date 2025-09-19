public class AdressWeatherService {

    @AuraEnabled
    public static WeatherInfo getTomorrowWeatherByCity(String city) {
        String endpoint = 'forecast.json?q=' + EncodingUtil.urlEncode(city, 'UTF-8') + '&days=2';
        try {
            HttpResponse res = sendGetRequest(endpoint);
            if(res.getStatusCode() == 200){
                Map<String, Object> parsedJsonRes = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> tomorrow = getWeatherDay(parsedJsonRes, 1);
                String cityName = (String)((Map<String, Object>)parsedJsonRes.get('location')).get('name');
                WeatherInfo tomorrowsInfo = new WeatherInfo(tomorrow, cityName);
             
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

    private static HttpResponse sendGetRequest(String endpoint){
        HttpRequest req = new HttpRequest();
        // Using a Named Credential
        req.setEndpoint('callout:WeatherApi/' + endpoint); 
        req.setMethod('GET');
    
        Http http = new Http();
        HttpResponse res = http.send(req);

        return res;
    }

    //Tries to make it generic and not specific for tomorrow in case it would scale to more days.
    private static Map<String, Object> getWeatherDay(Map<String, Object> parsedJsonRes, Integer dayIndex ) {
        // Weather API forecast Res Structure
        // res{
        //  "forecast": {
        //      "forecastday": [
        //          {today{day}},
        //          {tommorow{day}}
        // }
        List<Object> forecastDays = (List<Object>) ((Map<String, Object>)parsedJsonRes.get('forecast')).get('forecastday');
        Map<String, Object> tomorrowsData = (Map<String, Object>) forecastDays[dayIndex];
        Map<String, Object> tomorrow = (Map<String, Object>) tomorrowsData.get('day');
    
        return tomorrow;
    }


    public class WeatherInfo {
        @AuraEnabled public String cityName;
        @AuraEnabled public String iconUrl;
        @AuraEnabled public String textDescription;
        @AuraEnabled public Decimal minTempC;
        @AuraEnabled public Decimal maxTempC;
        @AuraEnabled public Decimal avgTempC;

        public WeatherInfo(Map<String, Object> dayData , String cityName) {
           if(dayData != null){
                this.cityName = cityName;
                Map<String, Object> condition = (Map<String, Object>) dayData.get('condition');
                this.iconUrl = (String) condition.get('icon');
                this.textDescription = (String) condition.get('text');
                this.minTempC = (Decimal) dayData.get('mintemp_c');
                this.maxTempC = (Decimal) dayData.get('maxtemp_c');
                this.avgTempC = (Decimal) dayData.get('avgtemp_c');
           }
        }
    }
}