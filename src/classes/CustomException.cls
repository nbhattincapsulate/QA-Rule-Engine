/*
* Class : CustomException. Can be used to throw custom exception with User-Wanted message.
* User for: Http API call request error. (when statuscode != 200).
*/
public class CustomException extends Exception{
        string errMsg;
		public void CustomException(String errorMsg){
		    errorMsg=errorMsg;
		}
		
		
		public static string sendJSONApiErrorResponse(String errorMsg){
			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject();
	                gen.writeStringField('error',errorMsg); 
	        gen.writeEndObject();
	        return gen.getAsString();        
		}
		
		public static string sendXMLApiErrorResponse(String errorMsg){
			Dom.Document doc = new Dom.Document();
	        Dom.Xmlnode rootNode = doc.createRootElement('errors', null, null); 
	        Dom.Xmlnode reqNode = rootNode.addChildElement('error', null, null);
	        reqNode.addChildElement('message', null, null).addTextNode(errorMsg);
	        return doc.toXMLString();
		}

}