@isTest
public class SnowControllerTest {
  public static testMethod void testRetrieveSnowInformation() {
    SingleReqHttpMock fakeSnowResp = new SingleReqHttpMock(200, 'Complete', '{ "displayFieldName": "PARTIAL_AREA", "fieldAliases": { "OBJECTID": "OBJECTID", "PARTIAL_AREA": "PARTIAL_AREA", "SNOWAREA": "SNOWAREA", "SNOWZONE": "SNOWZONE", "SHAPE.AREA": "SHAPE.AREA", "SHAPE.LEN": "SHAPE.LEN" }, "fields": [ { "name": "OBJECTID", "type": "esriFieldTypeOID", "alias": "OBJECTID" }, { "name": "PARTIAL_AREA", "type": "esriFieldTypeSmallInteger", "alias": "PARTIAL_AREA" }, { "name": "SNOWAREA", "type": "esriFieldTypeSmallInteger", "alias": "SNOWAREA" }, { "name": "SNOWZONE", "type": "esriFieldTypeSmallInteger", "alias": "SNOWZONE" }, { "name": "SHAPE.AREA", "type": "esriFieldTypeDouble", "alias": "SHAPE.AREA" }, { "name": "SHAPE.LEN", "type": "esriFieldTypeDouble", "alias": "SHAPE.LEN" } ], "features": [ { "attributes": { "OBJECTID": 5, "PARTIAL_AREA": 10, "SNOWAREA": 308, "SNOWZONE": 3, "SHAPE.AREA": 0, "SHAPE.LEN": 0 } } ] }', null); 
    Case c = new Case(GeoLocation__Latitude__s = 38.957, GeoLocation__Longitude__s = -76.997);

    Test.setMock(HttpCalloutMock.class, fakeSnowResp);
    c = SnowController.retrieveSnowInformation(c);
    System.assertEquals(c.SnowRoute__c, '308');
    System.assertEquals(c.SnowZone__c, '3');
  }

  public static testMethod void testRetrieveSnowInformationWithTableWrapper() {
    SingleReqHttpMock fakeSnowResp = new SingleReqHttpMock(200, 'Complete', '{ "displayFieldName": "PARTIAL_AREA", "fieldAliases": { "OBJECTID": "OBJECTID", "PARTIAL_AREA": "PARTIAL_AREA", "SNOWAREA": "SNOWAREA", "SNOWZONE": "SNOWZONE", "SHAPE.AREA": "SHAPE.AREA", "SHAPE.LEN": "SHAPE.LEN" }, "fields": [ { "name": "OBJECTID", "type": "esriFieldTypeOID", "alias": "OBJECTID" }, { "name": "PARTIAL_AREA", "type": "esriFieldTypeSmallInteger", "alias": "PARTIAL_AREA" }, { "name": "SNOWAREA", "type": "esriFieldTypeSmallInteger", "alias": "SNOWAREA" }, { "name": "SNOWZONE", "type": "esriFieldTypeSmallInteger", "alias": "SNOWZONE" }, { "name": "SHAPE.AREA", "type": "esriFieldTypeDouble", "alias": "SHAPE.AREA" }, { "name": "SHAPE.LEN", "type": "esriFieldTypeDouble", "alias": "SHAPE.LEN" } ], "features": [ { "attributes": { "OBJECTID": 5, "PARTIAL_AREA": 10, "SNOWAREA": 308, "SNOWZONE": 3, "SHAPE.AREA": 0, "SHAPE.LEN": 0 } } ] }', null); 
    List<AddressValidationResponseWrapper.TableWrapper> listOfWrappers = new List<AddressValidationResponseWrapper.TableWrapper>();
    listOfWrappers.add(new AddressValidationResponseWrapper.TableWrapper('1234','1234 Fake St, Fakeville, MA 12345','Fakeville','MA','12345','38.957','-76.997','Alias','','','1234','1','1234','4321','1','1','2','1a','1','5','1234 Fake','Fake','0', '10', '12345', '123', '-123', '1', '1', '5678'));

    Test.setMock(HttpCalloutMock.class, fakeSnowResp);
    listOfWrappers = SnowController.retrieveSnowInformation(listOfWrappers);
    System.assert(listOfWrappers.size() > 0);
    System.assertEquals(listOfWrappers[0].SnowArea, '308');
    System.assertEquals(listOfWrappers[0].SnowZone, '3');
  }
}