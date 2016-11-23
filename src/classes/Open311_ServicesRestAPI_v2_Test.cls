@IsTest
public class Open311_ServicesRestAPI_v2_Test {
		
		static String restURL =URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/v2/';
		
		/* use case: test no records found */
		public static testmethod void testNoData(){
			
			RestRequest req = new RestRequest();
        
			String endpoint=restURL+'services';
			req.requestURI=endpoint;
				        
			req.httpMethod='GET';
			RestContext.request= req;
			Test.startTest();
				Open311_ServicesRestAPI_v2.getServices();
			Test.stopTest();   
		}
		
		
		public static testmethod void testWithRecordsPresentInJSON(){
			
			TestHelper.createData();  
			
			RestRequest req = new RestRequest();
        
			String endpoint=restURL+'services';
			req.addHeader('Content-Type',APIConstants.CONTENT_TYPE_JSON); 
			req.requestURI=endpoint;
				        
			req.httpMethod='GET';
			RestContext.request= req;
			Test.startTest();
				Open311_ServicesRestAPI_v2.getServices();
			Test.stopTest();   
		}
		
		
		public static testmethod void testWithRecordsPresentInXML(){
			
			TestHelper.createData();  
			
			RestRequest req = new RestRequest();
        
			String endpoint=restURL+'services';			
			req.requestURI=endpoint;
				        
			req.httpMethod='GET';
			RestContext.request= req;
			Test.startTest();
				Open311_ServicesRestAPI_v2.getServices();
			Test.stopTest();   
		}
		
		/* use case: record does not exist*/
		public static testmethod void testWithInvalidId(){
			
			TestHelper.createData();  
			
			RestRequest req = new RestRequest();
        
			String endpoint=restURL+'services/11111111';
			req.requestURI=endpoint;
				        
			req.httpMethod='GET';
			RestContext.request= req;
			Test.startTest();
				Open311_ServicesRestAPI_v2.getServices();
			Test.stopTest();   
		}
		
		
		public static testmethod void testWithValidIdXML(){
			
			TestHelper.createData();  
			
			RestRequest req = new RestRequest();
        
			String endpoint=restURL+'services/'+TestHelper.serviceType1.Name;
			req.requestURI=endpoint; 
				        
			req.httpMethod='GET';
			RestContext.request= req;
			Test.startTest();
				Open311_ServicesRestAPI_v2.getServices();
				
			Test.stopTest();   
		}
		
		/* use case:  */
		public static testmethod void testWithValidIdJSON(){
			
			TestHelper.createData();  
			
			RestRequest req = new RestRequest();
        	req.addHeader('Content-Type',APIConstants.CONTENT_TYPE_JSON);
			String endpoint=restURL+'services/'+TestHelper.serviceType1.Name;
			req.requestURI=endpoint;
				        
			req.httpMethod='GET';
			RestContext.request= req;
			Test.startTest();
				Open311_ServicesRestAPI_v2.getServices();
				
			Test.stopTest();   
		}
}