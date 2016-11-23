global with sharing class SRPortalControllerExtension {
	
    // Stub controller
    // We're only using RemoteActions, so this never runs
    public SRPortalControllerExtension(SRPortalController ctl){ 
    
    }
     
    @RemoteAction
    global static string getDCAddressByLatitudeLongitude(string latitude, string longitude){
    	String DCAddress = null;
    	
    	if(latitude != null && latitude != '' && longitude != null && longitude != ''){
    		DCAddress = reverseGeoCodeDCAddressLatLng(latitude, longitude);
    	}
    	return DCAddress;
    }
    
    public static string reverseGeoCodeDCAddressLatLng(string x, string y){
        String DCAddress = null;
        string format = 'xml';
        
        if(x != null && y != null && format != null) {
            String endPoint='http://citizenatlas.dc.gov/newwebservices/locationverifier.asmx/reverseLatLngGeocoding2';
            endPoint = endPoint + '?lat='+ EncodingUtil.urlEncode(x, 'UTF-8') +'&lng='+ EncodingUtil.urlEncode(y, 'UTF-8') +'&f='+EncodingUtil.urlEncode(format, 'UTF-8');
            
            //make the callout
            Http h = new Http();
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            
            // Send the request, and get a response
            HttpResponse res = h.send(req);
            system.debug('res.getBodyDocument ->> '+res.getBodyDocument().toXmlString());
            string dcFullAddress = getValueFromXMLString(res.getBodyDocument().toXmlString(), 'FULLADDRESS', 0);
            if(dcFullAddress != null && dcFullAddress != '')
            {
                DCAddress = dcFullAddress;
            }
        }
        return DCAddress;
    }
    
    
    public static string getValueFromXMLString(string xmlString, string keyField, integer location){
	    string valueFound = '';
	    if(xmlString.contains('<' + keyField + '>') && xmlString.contains('</' + keyField + '>')){
	      try{
	          valueFound = xmlString.substring(xmlString.indexOf('<' + keyField + '>', location) + keyField.length() + 2,
	            xmlString.indexOf('</' + keyField + '>', location));   
	        }catch (exception e){
	            system.debug('Error in getValueFromXMLString.  Details: ' + e.getMessage() + ' keyfield: ' + keyfield);
	        }           
	    }
	    return valueFound;
	}
}