/*
* ClassName   : APIConstants
* Description : Helper class to store constants used through out API.
*/

public  class APIConstants {
    
    public static String CONTENT_TYPE_JSON  = 'application/json';
    public static String CONTENT_TYPE_XML  = 'text/xml';
    
    public static String RESPONSE_XML  = 'xml';
    public static String RESPONSE_JSON  = 'json';
    
    public static String ACCEPT_VERSION     = '2.0.x';
    public static String HTTPPOST           = 'POST';
    public static String HTTPGET            = 'GET';
    public static String HTTPDELETE         = 'DELETE';
    public static String ACCESS_TOKEN_TYPE  = 'Bearer ';
            
    //Http Response Codes
    public static Decimal RESPONSE_CODE_STATUS_OK = 200;
    public static Decimal RESPONSE_CODE_STATUS_CREATED = 200;
    public static Decimal RESPONSE_CODE_401       = 401;
    public static Decimal RESPONSE_CODE_400       = 400; 
    public static Decimal RESPONSE_CODE_404       = 404;    
    
    public static String NOT_FOUND           = 'NOT FOUND';
    
    /* EVENT CODES SENT TO SFDC BY SOAP API */
    public static String EVTCODE_4_NEW ='NEWSR';
    public static String EVTCODE_4_UPDATE ='XUPDSR';  

   

}