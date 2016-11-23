global class SnowAttributesFetchBatch implements Database.Batchable < sObject >, Database.AllowsCallouts {

  global static boolean isSnowAttributeBatchRunning = false;

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String queryStr = '' +
    'SELECT ' +
    'c.CaseNumber,' +
    'c.Address__c,' +
    'c.ANC__c, ' +
    'c.SMD__c,' +
    'c.Quadrant__c,' +
    'c.Zipcode__c,' +
    'c.PSA__c,' +
    'c.POlDistrict__c,' +
    'c.Cluster__c,' +
    'c.SRType__r.Agency__c,' +
    'c.Servicing_Agency__c,' +
    'c.SRType__c,' +
    'c.Ward__c,' +
    'c.Jurisdiction__c,' +
    'c.AgencyCode__c,' +
    'c.YCOORD__c,' +
    'c.XCOORD__c ' +
    'FROM Case c ' +
    'WHERE ';
    queryStr += ' c.XCOORD__c != null';
    queryStr += ' AND c.YCOORD__c != null';
    queryStr += ' AND ((Servicing_Agency__c =\'' + String.escapesingleQuotes('SNOW') + '\'';
    queryStr += ' AND SnowZone__c = null)';
    queryStr += ' OR (Ward__c = null))';
    return Database.getQueryLocator(queryStr);
  }

  global void execute(Database.BatchableContext BC, List<Case> scope) {
    // to avoid the future method to call'd from this batch class
    isSnowAttributeBatchRunning = true;
    // holds case to update with snow attributes
    List<Case> caseListToUpdate = new List<Case> ();
    for (Case caseRrd : scope) {
      //case caseRrd = (case)s;

      if (caseRrd.XCOORD__c != null && caseRrd.YCOORD__c != null) {
        String address = caseRrd.Address__c;
        List<String> jsonResponse = executeSnowScenarios(caseRrd);

        if (jsonResponse != null) {
          //string jsonstring= jsonResponse;
          for (String jr : jsonResponse) {
            String newJsonstring = jr.replace('"SHAPE.AREA":', '"AREA":');
            String newJsonstring1 = jr.replace('"SHAPE.LEN":', '"LEN":');
            JSONParser parser = JSON.createParser(newJsonstring1);
            snowAttributes.SnowAttributesWrapper snowAttritubeWrap = (SnowAttributes.SnowAttributesWrapper) parser.readValueAs(snowAttributes.SnowAttributesWrapper.class);

            if (snowAttritubeWrap.features != null && snowAttritubeWrap.features.size() >= 1) {
              SnowAttributes.attributes att = snowAttritubeWrap.features[0].attributes;
              if (att != null) {
                if (att.SNOWAREA != null) caseRrd.SnowRoute__c = string.valueof(att.SNOWAREA);
                if (att.SNOWZONE != null) caseRrd.SnowZone__c = string.valueof(att.SNOWZONE);
                if (att.SMD_ID != null) caseRrd.SMD__c = 'SMD ' + att.SMD_ID;
                if (att.ANC_ID != null) caseRrd.ANC__c = 'ANC ' + att.ANC_ID;
                if (att.WARD != null) caseRrd.Ward__c = 'Ward ' + att.WARD;
                if (att.QUADRANT != null) caseRrd.Quadrant__c = att.QUADRANT;
                if (att.POLDIST != null) caseRrd.POlDistrict__c = 'Police District - ' + att.POLDIST;
                if (att.CLUSTER != null) caseRrd.Cluster__c = 'Cluster ' + att.CLUSTER;
                if (att.PSA != null) caseRrd.PSA__c = 'Police Service Area ' + att.PSA;
                if (att.ZIPCODE != null) caseRrd.Address__c = address + ',' + att.ZIPCODE;
              }
            }
          }
          // collecting cases to update with snowzone and snow area values
          caseListToUpdate.add(caseRrd);
        }
      }
    }

    if (!caseListToUpdate.isEmpty()) {
      Update(caseListToUpdate);
    }
  }

  global void finish(Database.BatchableContext BC) {
    //Scheduling the batch every 5 min
    Datetime sysTime = System.now();
    sysTime = sysTime.addSeconds(300);

    String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
    System.schedule('Snow-AddressBatch' + sysTime.getTime(), chron_exp, new ScheduleSnowAttributeBatch());
  }

  /*
   * Method name  : dowebServiceCallout
   * Description  : Dispatch method
   * Return Type  : String
   * Parameter      : url parameter
   */
  private string doWebServiceCallout(String endUrlStr) {
    string jsonResponse;

    if (Test.isRunningTest()) {
      jsonResponse = '{ "displayFieldName": "PARTIAL_AREA", "fieldAliases": { "OBJECTID": "OBJECTID", "PARTIAL_AREA": "PARTIAL_AREA", "SNOWAREA": "SNOWAREA", "SNOWZONE": "SNOWZONE", "SHAPE.AREA": "SHAPE.AREA", "SHAPE.LEN": "SHAPE.LEN" }, "fields": [ { "name": "OBJECTID", "type": "esriFieldTypeOID", "alias": "OBJECTID" }, { "name": "PARTIAL_AREA", "type": "esriFieldTypeSmallInteger", "alias": "PARTIAL_AREA" }, { "name": "SNOWAREA", "type": "esriFieldTypeSmallInteger", "alias": "SNOWAREA" }, { "name": "SNOWZONE", "type": "esriFieldTypeSmallInteger", "alias": "SNOWZONE" }, { "name": "SHAPE.AREA", "type": "esriFieldTypeDouble", "alias": "SHAPE.AREA" }, { "name": "SHAPE.LEN", "type": "esriFieldTypeDouble", "alias": "SHAPE.LEN" } ], "features": [ { "attributes": { "OBJECTID": 5, "PARTIAL_AREA": 10, "SNOWAREA": 308, "SNOWZONE": 3, "SHAPE.AREA": 0, "SHAPE.LEN": 0 } } ] }';
    } else {
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
    }
    return jsonResponse;
  }

  /*
   * Method name  : executeSnowScenarios
   * Description  : execute different Snow Scenarios
   * Return Type  : String
   * Parameter    : Case
   */
  private List<String> executeSnowScenarios(Case caseRrd) {
    String endUrlStr;
    String jsonResponse;
    List<String> jRList = new List<String> ();

    //For Scenario 1
    if (caseRrd.Servicing_Agency__c == 'SNOW') {
      endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/1/query';
      // geometry parameters
      endUrlStr += '?geometry=' + caseRrd.XCOORD__c + ',+' + caseRrd.YCOORD__c;
      endUrlStr += '&geometryType=esriGeometryPoint&inSR=26985&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';
      jsonResponse = doWebServiceCallout(endUrlStr);
      jRList.add(jsonResponse);
    }

    //For Scenario 2
    if (caseRrd.Ward__c == null) {
      endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/4/query';
      // geometry parameters
      endUrlStr += '?geometry=' + caseRrd.XCOORD__c + ',+' + caseRrd.YCOORD__c;
      endUrlStr += '&geometryType=esriGeometryPoint&inSR=26985&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';

      jsonResponse = doWebServiceCallout(endUrlStr);
      jRList.add(jsonResponse);
    }

    //For Scenario 3
    if (caseRrd.ANC__c == null || caseRrd.SMD__c == null) {
      endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/3/query';
      // geometry parameters
      endUrlStr += '?geometry=' + caseRrd.XCOORD__c + ',+' + caseRrd.YCOORD__c;
      endUrlStr += '&geometryType=esriGeometryPoint&inSR=26985&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';

      jsonResponse = doWebServiceCallout(endUrlStr);
      jRList.add(jsonResponse);
    }

    //For Scenario 4
    if (caseRrd.Quadrant__c == null) {
      endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/5/query';
      // geometry parameters
      endUrlStr += '?geometry=' + caseRrd.XCOORD__c + ',+' + caseRrd.YCOORD__c;
      endUrlStr += '&geometryType=esriGeometryPoint&inSR=26985&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';

      jsonResponse = doWebServiceCallout(endUrlStr);
      jRList.add(jsonResponse);
    }

    //For Scenario 5
    if (caseRrd.POlDistrict__c == null) {
      endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/6/query';
      // geometry parameters
      endUrlStr += '?geometry=' + caseRrd.XCOORD__c + ',+' + caseRrd.YCOORD__c;
      endUrlStr += '&geometryType=esriGeometryPoint&inSR=26985&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';

      jsonResponse = doWebServiceCallout(endUrlStr);
      string newJsonstring = jsonResponse.replace('"NAME":', '"POLDIST":');
      jRList.add(newJsonstring);
    }

    //For Scenario 6
    if (caseRrd.Cluster__c == null) {
      endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/7/query';
      // geometry parameters
      endUrlStr += '?geometry=' + caseRrd.XCOORD__c + ',+' + caseRrd.YCOORD__c;
      endUrlStr += '&geometryType=esriGeometryPoint&inSR=26985&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';

      jsonResponse = doWebServiceCallout(endUrlStr);
      string newJsonstring = jsonResponse.replace('"NAME":', '"CLUSTER":');
      jRList.add(newJsonstring);
    }

    //For Scenario 7
    if (caseRrd.PSA__c == null) {
      endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/8/query';
      // geometry parameters
      endUrlStr += '?geometry=' + caseRrd.XCOORD__c + ',+' + caseRrd.YCOORD__c;
      endUrlStr += '&geometryType=esriGeometryPoint&inSR=26985&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';

      jsonResponse = doWebServiceCallout(endUrlStr);
      jRList.add(jsonResponse);
    }

    //For Scenario 8
    if (caseRrd.Zipcode__c == null) {
      endUrlStr = 'http://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_APPS/GeoAreas_311/MapServer/9/query';
      // geometry parameters
      endUrlStr += '?geometry=' + caseRrd.XCOORD__c + ',+' + caseRrd.YCOORD__c;
      endUrlStr += '&geometryType=esriGeometryPoint&inSR=26985&spatialRel=esriSpatialRelIntersects&outFields=*&returnGeometry=false&f=pjson';

      jsonResponse = doWebServiceCallout(endUrlStr);
      jRList.add(jsonResponse);
    }
    return jRList;
  }
}