@RestResource(urlMapping = '/alerts')
global class MajorAlertsController {

    @HttpGet
    global static List<MajorAlert__c> getMostRecentAlert() {
        return [SELECT Message__c FROM MajorAlert__c WHERE EndDate__c > :System.NOW() ORDER BY StartDate__c LIMIT 1];
    }
}