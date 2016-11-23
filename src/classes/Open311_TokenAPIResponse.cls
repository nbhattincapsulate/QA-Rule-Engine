public  class Open311_TokenAPIResponse {
	
		public static string sendJSONResponse(Case c){
			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
	                gen.writeStringField('service_request_id',c.CaseNumber); 
	                gen.writeStringField('token',c.CaseNumber);
	        gen.writeEndObject();
	        return gen.getAsString();        
		}
		 
		public static string sendXMLResponse(Case c){
			Dom.Document doc = new Dom.Document();
	        Dom.Xmlnode rootNode = doc.createRootElement('service_requests', null, null); 
	        Dom.Xmlnode reqNode = rootNode.addChildElement('request', null, null);
	        reqNode.addChildElement('service_request_id', null, null).addTextNode(c.CaseNumber);
	        reqNode.addChildElement('token', null, null).addTextNode('');
	        return doc.toXMLString();
		}
	
}