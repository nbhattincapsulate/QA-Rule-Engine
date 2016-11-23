@isTest
public class Open311_ServiceDiscoveryRestAPI_v2_Test {

	static String restURL =URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/v2/';
	
	static void testData(){
		Open311ServiceConfig__c config = new Open311ServiceConfig__c();
		config.Open311ProductionURL__c='test';
		config.name='v2';
		config.Open311TestURL__c='test';
		config.support_email__c='test@test.com';
		config.support_phone__c='11111111';
		insert config;
		
	}
	
	/* use case:json response*/
	public static testmethod void testResponseJSON(){
		
		testData();
		
		RestRequest req = new RestRequest();
    
		String endpoint=restURL+'discovery.json';
		req.addHeader('Content-Type',APIConstants.CONTENT_TYPE_JSON);
		req.requestURI=endpoint;
			        
		req.httpMethod='GET';
		RestContext.request= req;
		Test.startTest();
			Open311_ServiceDiscoveryRestAPI_v2.doGet();
			
		Test.stopTest();   
	}
	
	/* use case:xml response*/
	public static testmethod void testResponseXML(){
		testData();
		RestRequest req = new RestRequest();
    
		String endpoint=restURL+'discovery.xml';
		req.requestURI=endpoint;
			        
		req.httpMethod='GET';
		RestContext.request= req;
		Test.startTest();
			Open311_ServiceDiscoveryRestAPI_v2.doGet();
			
		Test.stopTest();   
	}
    
}