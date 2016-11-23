public class SnowController {

  public static Case retrieveSnowInformation(Case c) {
    SnowAttributes.Attributes att = getSnowAttributes(String.valueOf(c.GeoLocation__Latitude__s), String.valueOf(c.GeoLocation__Longitude__s));
    if (att.SNOWAREA != null) c.SnowRoute__c = string.valueof(att.SNOWAREA);
    if (att.SNOWZONE != null) c.SnowZone__c = string.valueof(att.SNOWZONE);
    return c;
  }

  public static List<AddressValidationResponseWrapper.TableWrapper> retrieveSnowInformation(List<AddressValidationResponseWrapper.TableWrapper> addrTable) {
    for (AddressValidationResponseWrapper.TableWrapper wrapper : addrTable) {
      SnowAttributes.attributes att = getSnowAttributes(wrapper.LATITUDE, wrapper.LONGITUDE);
      if (att.SNOWAREA != null) wrapper.SNOWAREA = string.valueof(att.SNOWAREA);
      if (att.SNOWZONE != null) wrapper.SNOWZONE = string.valueof(att.SNOWZONE);
    }
    return addrTable;
  }

  private static SnowAttributes.attributes getSnowAttributes(String lat, String lng) {
    System.debug('----> Latitude: ' + lat + ', Longitude: ' + lng);

    if (lat != null && lng != null) {
      List<String> jsonResponse = executeSnowScenarios(lat, lng);

      if (jsonResponse != null) {
        //string jsonstring= jsonResponse;
        for (String jr : jsonResponse) {
          String newJsonstring = jr.replace('"SHAPE.AREA":', '"AREA":');
          String newJsonstring1 = jr.replace('"SHAPE.LEN":', '"LEN":');
          JSONParser parser = JSON.createParser(newJsonstring1);
          snowAttributes.SnowAttributesWrapper snowAttributeWrap = (SnowAttributes.SnowAttributesWrapper) parser.readValueAs(snowAttributes.SnowAttributesWrapper.class);

          if (snowAttributeWrap.features != null && snowAttributeWrap.features.size() >= 1) {
            SnowAttributes.attributes att = snowAttributeWrap.features[0].attributes;
            if (att != null) {
              return att;
            }
          }
        }
      }
    }
    return new SnowAttributes.Attributes();
  }

  /*
   * Method name  : dowebServiceCallout
   * Description  : Dispatch method
   * Return Type  : String
   * Parameter      : url parameter
   */
  private static string doWebServiceCallout(String endUrlStr) {
    string jsonResponse;

    // Instantiate a new http object
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    req.setEndpoint(endUrlStr);
    req.setMethod('GET');
    try {
      //Execute web service call here		
      res = h.send(req);
      //Helpful debug messages
      System.debug(res.toString());
      System.debug('STATUS:' + res.getStatus());
      System.debug('STATUS_CODE:' + res.getStatusCode());

    } catch(System.CalloutException e) {
      //Exception handling goes here....
      system.debug('unable to complete due to -' + e);
    }
    jsonResponse = res.getBody();
    System.debug('----> Response Body: ' + res.getBody());
    return jsonResponse;
  }

  /*
   * Method name  : executeSnowScenarios
   * Description  : execute different Snow Scenarios
   * Return Type  : String
   * Parameter    : Case
   */
  private static List<String> executeSnowScenarios(String lat, String lng) {
    String endUrlStr;
    String jsonResponse;
    List<String> jRList = new List<String> ();

    endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/1/query';
    // geometry parameters
    endUrlStr += '?geometry=' + lng + ',+' + lat;
    endUrlStr += '&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';
    jsonResponse = doWebServiceCallout(endUrlStr);
    jRList.add(jsonResponse);
    return jRList;
  }
}