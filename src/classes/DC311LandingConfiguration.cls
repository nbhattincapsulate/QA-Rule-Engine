@RestResource(urlMapping = '/landingConfig')
global class DC311LandingConfiguration {

    @HttpGet
    global static void getLandingConfig() {
        StaticResource doc = [SELECT Body FROM StaticResource WHERE Name = 'DC311LandingConfig' LIMIT 1];
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.responseBody = doc.body;
    }
}