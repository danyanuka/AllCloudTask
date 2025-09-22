@isTest
private class AdressWeatherService_TEST{

    @testSetup
    static void testData() {
        Account account = new Account(
            Name = 'Weather Test Account',
            BillingCountry = 'Israel',
            BillingCity = 'Tel Aviv',
            ShippingCity = 'Haifa'
        );
        insert account;
    }

    // --- Correct HttpCalloutMock implementation (must implement respond)
    private class WeatherApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            res.setBody(
                '{' +
                    '"location": {"name": "Tel Aviv"},' +
                    '"forecast": {"forecastday": [' +
                        '{"day":{"mintemp_c":20,"maxtemp_c":28,"avgtemp_c":24,"condition":{"icon":"//cdn.weather.com/icon.png","text":"Sunny"}}},' +
                        '{"day":{"mintemp_c":21,"maxtemp_c":29,"avgtemp_c":25,"condition":{"icon":"//cdn.weather.com/icon2.png","text":"Clear"}}}' +
                    ']}' +
                '}'
            );

            return res;
        }
    }


    private class WeatherApiErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }


    // Covers everything except the else block and the exception
    @isTest
    static void testGetTomorrowWeatherByCity() {
        Account account = [SELECT BillingCity FROM Account LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new WeatherApiMock());

        Test.startTest();
            AdressWeatherService.WeatherInfo weatherInfo = AdressWeatherService.getTomorrowWeatherByCity(account.BillingCity);
        Test.stopTest();

        Assert.areEqual('Tel Aviv', weatherInfo.cityName, 'City name should match');
        Assert.areEqual(Decimal.valueOf(29), weatherInfo.maxTempC, 'Max temp should match');
        Assert.areEqual('//cdn.weather.com/icon2.png', weatherInfo.iconUrl, 'Icon should match');
    }

    //Covers the else block
    @isTest
    static void testErrorResponse() {
        Account account = [SELECT ShippingCity FROM Account LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new WeatherApiErrorMock());

        Test.startTest();
            AdressWeatherService.WeatherInfo weatherInfo = AdressWeatherService.getTomorrowWeatherByCity(account.ShippingCity);
        Test.stopTest();

        Assert.areEqual(null, weatherInfo, 'Should return null when status code is not 200');
    }

    //Covers exception (catch block)
    @isTest
    static void testNullCity() {
        Test.startTest();
            AdressWeatherService.WeatherInfo weatherInfo =
                AdressWeatherService.getTomorrowWeatherByCity(null);
        Test.stopTest();

        Assert.areEqual(null, weatherInfo, 'Should return null when city is null');
    }

}
