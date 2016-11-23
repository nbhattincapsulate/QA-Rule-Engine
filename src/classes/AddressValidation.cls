public with sharing class AddressValidation {
        public static String verifyAddress(String address){           
            /*
              Make as http callout to validate a address
            */
            String endPoint='http://citizenatlas.dc.gov/newwebservices/locationverifier.asmx/findLocation2';
            endPoint = endPoint + '?str='+EncodingUtil.urlEncode(address, 'UTF-8')+'&f=json';
            System.debug('-----> Endpoint: ' + endPoint);
            //endPoint = endPoint + '?str='+address+'&f=json';
            /*
            make the callout
            */
            Http h = new Http();
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            
            // Send the request, and return a response
           /* HttpResponse testResponse= new  HttpResponse();
            string jsonstring;
            //Handle web service callouts for tests
            if(Test.isRunningTest()){
              jsonstring='{"returnCodes":null,"details":"<STRONG>Parsed:</STRONG></br><EM>Street Name 1: </EM>14TH</br><EM>Street Type 1: </EM></br><EM>Quad 1: </EM></br><EM>Direction 1: </EM></br><EM>Street Name 2: </EM>U</br><EM>Street Type 2: </EM>STREET</br><EM>Quad 2: </EM></br><EM>Direction 2: </EM></br><STRONG>Possible Standard Street Names 1: </STRONG></br>14TH</br><STRONG>Possible Standard Street Names 2: </STRONG>';
              jsonstring+='</br>U</br>","returnDataset":{"Table1":[{"MARID":903573.0,"INTERSECTIONID":15843.0,"STREET1ID":108723.0,"STREET2ID":100140.0,"ST1NAME":"U","ST1TYPE":"STREET","ST1QUAD":"NW","FULLSTREET1DISPLAY":"U STREET NW","ST2NAME":"14TH","ST2TYPE":"STREET","ST2QUAD":"NW","FULLSTREET2DISPLAY":"14TH STREET NW","FULLINTERSECTION":"U STREET NW AND 14TH STREET NW","REFX":397229.13001138,"REFY":138792.67999823,';
              jsonstring+='"NATIONALGRID":"18S UJ 23837 09529","LATITUDE":38.91699812128980,"LONGITUDE":-77.03195073766770,"ConfidenceLevel":62.5},{"MARID":903021.0,"INTERSECTIONID":15289.0,"STREET1ID":300140.0,"STREET2ID":308723.0,"ST1NAME":"14TH","ST1TYPE":"STREET","ST1QUAD":"SE","FULLSTREET1DISPLAY":"14TH STREET SE","ST2NAME":"U","ST2TYPE":"STREET","ST2QUAD":"SE","FULLSTREET2DISPLAY":"U STREET SE",';
              jsonstring+='"FULLINTERSECTION":"14TH STREET SE AND U STREET SE","REFX":401268.25001513,"REFY":133120.61000897,"NATIONALGRID":"18S UJ 27750 03769","LATITUDE":38.86590545932130,"LONGITUDE":-76.985386353798,"ConfidenceLevel":62.5},{"MARID":903021.0,"INTERSECTIONID":15289.0,"STREET1ID":308723.0,"STREET2ID":300140.0,"ST1NAME":"U","ST1TYPE":"STREET","ST1QUAD":"SE","FULLSTREET1DISPLAY":"U STREET SE","ST2NAME":"14TH","ST2TYPE":"STREET","ST2QUAD":"SE","FULLSTREET2DISPLAY":"14TH STREET SE",';
              jsonstring+='"FULLINTERSECTION":"U STREET SE AND 14TH STREET SE","REFX":401268.25001513,"REFY":133120.61000897,"NATIONALGRID":"18S UJ 27750 03769","LATITUDE":38.86590545932130,"LONGITUDE":-76.985386353798,"ConfidenceLevel":62.5},{"MARID":903573.0,"INTERSECTIONID":15843.0,"STREET1ID":100140.0,"STREET2ID":108723.0,"ST1NAME":"14TH","ST1TYPE":"STREET","ST1QUAD":"NW","FULLSTREET1DISPLAY":"14TH STREET NW","ST2NAME":"U","ST2TYPE":"STREET","ST2QUAD":"NW","FULLSTREET2DISPLAY":"U STREET NW",';
              jsonstring+='"FULLINTERSECTION":"14TH STREET NW AND U STREET NW","REFX":397229.13001138,"REFY":138792.67999823,"NATIONALGRID":"18S UJ 23837 09529","LATITUDE":38.91699812128980,"LONGITUDE":-77.03195073766770,"ConfidenceLevel":62.5}]},"returnBlkAddrDataset":null,"returnCDDataSet":{"Address Return Codes":[{"Component":"Street Type 1","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Street Type 2","Parsed & Normalized":"STREET","Assessment":"Valid"},{"Component":"Quad","Parsed & Normalized":"",';
              jsonstring+='"Assessment":"Missing"},{"Component":"Direction","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Street Name 1","Parsed & Normalized":"14TH","Assessment":"Valid"},{"Component":"Street Name 2","Parsed & Normalized":"U","Assessment":"Valid"}]},"UNIT":null,"UNITNUMBER":null,"sourceOperation":"DC Intersection","processTime":null}';          
              testResponse.setBody(jsonstring);
            }*/
            
            // Send the request, and return a response
           // HttpResponse res = !Test.isRunningTest() ? h.send(req):testResponse;
            HttpResponse res = h.send(req);
            system.debug('----> res.getBody: '+res.getBody());
            return res.getBody();
        }
        
        public static String verifyAddressByLatLong(String Latitude,String Longitude){
            /*
              Make as http callout to validate a address
            */
            String endPoint='http://citizenatlas.dc.gov/newwebservices/locationverifier.asmx/findLocation2';
            
            //endPoint = endPoint + '?str='+EncodingUtil.urlEncode(address, 'UTF-8')+'&f=json';
                        
            /*
            make the callout
            */
            Http h = new Http();

            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('GET');           
           
            
            // Send the request, and return a response          
            HttpResponse res = h.send(req);
            system.debug('res.getBody'+res.getBody());
            return res.getBody();

        }


}