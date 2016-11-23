@RestResource(urlMapping = '/v2/requests/*')
global class Open311_RequestsRestAPI_v2 {

  static string jsonString;

  /*
    @Purpose:-
    Create service requests
   
    Format sent:- Content-Type: application/x-www-form-urlencoded
    HTTP Method POST
    Formats returned    XML/JSON 
    API Key: YES
   
    Sample Call:- https://[API endpoint]/requests.[format]
   
   */
  @HttpPost
  global static void createRequest() {
    Map<Date, BulkSchedule__c> bulkScheduleMap = new Map<Date, BulkSchedule__c>();
      
    System.debug('----> POST: Inside Create Request!');
    RestRequest req = RestContext.request;

    if (RestContext.response == null) RestContext.response = new RestResponse();
    RestResponse response = RestContext.response;
    String format = req.requestURI.split('\\.').size() > 1 ? req.requestURI.split('\\.') [1] : '';

    String responseStr;

    /*
      API KEY SUPPORT             
     */
    String apiKey = req.params.get('api_key');

    APIValidations.APIKeyResponse apiKeyRes = Open311APIHelper.checkAPIKey(apiKey, req, response, format);
    System.debug('----> [Open311-Test] RestAPI_V2 => apiKeyRes for Create: ' + apiKeyRes);
    if (apiKeyRes == null) {
      Open311APIHelper.logRequest(req, 'Error', 'API Key not provided: Unable to create a service request');
      return;
    }
    apiKeyRes.httpMethod = 'post';


    /*
      check to see whether jurisdiction_id is passed
     */
    String jId = (req.params.containsKey('jurisdiction_id') ? req.params.get('jurisdiction_id') : null);
    /*
      validate that the Juridictoion Id is correct 
     */
    System.debug('----> POST: Verifying Jurisdiction');
    if (jId != null && !APIValidations.isValidJuridiction(jId)) {
      //invalid juridiction provided:-
      response.statuscode = 404;
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse('Invalid jurisdiction_id provided') :
      CustomException.sendXMLApiErrorResponse('Invalid jurisdiction_id provided');
      RestContext.response.responseBody = Blob.valueOf(responseStr);

      Open311APIHelper.logRequest(req, 'Error', 'Invalid jurisdiction_id provided : ' + jId);

      return;
    }
    System.debug('----> POST: Verifing Service Code [Available && null]');
    if (req.params.containsKey('service_code') && req.params.get('service_code') == null) {
      response.statuscode = 400;
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse('Service code not provided') :
      CustomException.sendXMLApiErrorResponse('Service code not provided');
      RestContext.response.responseBody = Blob.valueOf(responseStr);
      Open311APIHelper.logRequest(req, 'Error', 'Service code not provided');
      return;
    }
    System.debug('----> POST: Verifing Service Code [Available && NOT Null]');
    System.debug('----> POST: Verifing Service Code: ' + req.params.get('service_code'));
    if (req.params.containsKey('service_code') && req.params.get('service_code') != null) {
    System.debug('----> POST: ApiKey Contents: ' + apiKeyRes);
      List<String> ids = req.params.get('service_code').split(',');
      System.debug('----> Request Types: ' + ids);
      System.debug('----> Allows Types In Key: ' + apiKeyRes.availableSRTypesToQueryForPOST);
      // Verify that all service codes are allowed for the current API user. 
      for (String code : ids) {
        if (!apiKeyRes.availableSRTypesToQueryForPOST.contains(code)) {
          // Restricted code found. Throw error for user. 
          response.statuscode = 404;
          responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
          CustomException.sendJSONApiErrorResponse('Unauthorized Service Type requested. One or more of the service types requested is disabled on your account. Please contact support if you believe this to be incorrect.') :
          CustomException.sendXMLApiErrorResponse('Unauthorized Service Type requested. One or more of the service types requested is disabled on your account. Please contact support if you believe this to be incorrect.');
          RestContext.response.responseBody = Blob.valueOf(responseStr);
          Open311APIHelper.logRequest(req, 'Error', 'Restricted service code has been requested. Service Code: ' + code);
          return;
        }
      }
    }

    System.debug('----> POST: Verifing Address');
    //we need to get the address validation here before doing any transaction
    if (req.params.containsKey('address_id') || req.params.containsKey('address_string')) {
      if (Test.isRunningTest()) {
        jsonstring = TestMARValidationJson();
      } else {
        jsonstring = AddressValidation.verifyAddress(req.params.get('address_id') != null ? req.params.get('address_id') : req.params.get('address_string'));
      }
    }

    System.debug('----> Attempting to get Snow Information');
    Case c = new Case();
    Case tempSnowCase = new Case();

    /*
      @populate address data
     */
    //if(!String.isBlank(req.params.get('address_string')))c.Address__c = req.params.get('address_string');
    if (req.params.containsKey('address_id') || req.params.containsKey('address_string')) {
      c.AddressId__c = req.params.get('address_id');
      c.Address__c = req.params.get('address_string');

      JSONParser parser = JSON.createParser(jsonString);
      AddressValidationResponseWrapper.AddressValidationWrapper m = (AddressValidationResponseWrapper.AddressValidationWrapper) parser.readValueAs(AddressValidationResponseWrapper.AddressValidationWrapper.class);

      //if the address is valid dump the field here
      AddressValidationResponseWrapper.returnDatasetWrapper check_data_in_returnDataset = m.returnDataset;
      List<AddressValidationResponseWrapper.TableWrapper> check_data_in_table = new List<AddressValidationResponseWrapper.TableWrapper> ();
      if (check_data_in_returnDataset != null) {
        check_data_in_table = m.returnDataset.Table1;

        String address;
        String addressId;

        if (check_data_in_table[0].ADDRESS_ID != null) {
          // regular Address entity
          address = check_data_in_table[0].FULLADDRESS;
        } else if (check_data_in_table[0].INTERSECTIONID != null) {
          // Intersection address entity
          address = check_data_in_table[0].FULLINTERSECTION;
        } else {
          address = check_data_in_table[0].BLOCKNAME != null ? check_data_in_table[0].BLOCKNAME : check_data_in_table[0].ALIASNAME;
        }
        address += ',WASHINGTON,DC,USA';
        address += check_data_in_table[0].ZIPCODE != null ? ',' + String.valueof(Integer.valueof(check_data_in_table[0].ZIPCODE)) : '';


        try {
          Integer id = Integer.valueOf(check_data_in_table[0].ADDRESS_ID);
          addressId = String.valueOf(id);
        } catch(Exception e) {
          addressId = '';
        }

        c.GeoLocation__Latitude__s = decimal.valueof(check_data_in_table[0].LATITUDE);
        c.GeoLocation__Longitude__s = decimal.valueof(check_data_in_table[0].LONGITUDE);
        c.IntersectionId__c = check_data_in_table[0].INTERSECTIONID != null ? String.valueof(Integer.valueof(check_data_in_table[0].INTERSECTIONID)) : '';
        c.AliasName__c = check_data_in_table[0].ALIASNAME;
        c.address__c = address; // check_data_in_table[0].FULLADDRESS+' Washington, DC '+check_data_in_table[0].ZIPCODE;
        c.addressid__c = addressId != '' ? addressId : (check_data_in_table[0].MARID != null ? String.valueof(Integer.valueof(check_data_in_table[0].MARID)) : '');
        //c.addressid__c = check_data_in_table[0].ADDRESS_ID!=null?String.valueof(Integer.valueof(check_data_in_table[0].ADDRESS_ID)):''
        c.quadrant__c = check_data_in_table[0].QUADRANT;
        c.anc__c = check_data_in_table[0].ANC;
        c.poldistrict__c = check_data_in_table[0].POLDIST;
        c.psa__c = check_data_in_table[0].PSA;
        c.ward__c = check_data_in_table[0].WARD;
        c.smd__c = check_data_in_table[0].SMD;
        c.cluster__c = check_data_in_table[0].CLUSTER;
        c.xcoord__c = check_data_in_table[0].XCOORD;
        c.ycoord__c = check_data_in_table[0].YCOORD;

        if (c.GeoLocation__Latitude__s != null && c.GeoLocation__Longitude__s != null) {
          if (!Test.isRunningTest()) {
            tempSnowCase = SnowController.retrieveSnowInformation(c);
          }
        }
      }
    }

    System.debug('-----> API Address Check: ' + jsonstring);
    //create a save point
    Savepoint sp = Database.setSavepoint();
    //Create a service request:-
    try {
      // If the usage reset date is not in the same month as today or the same year then reset it.
      if ((apiKeyRes.usageLimitResetDate != null && apiKeyRes.usageLimitResetDate.year() != Date.today().year()) || (apiKeyRes.usageLimitResetDate != null && apiKeyRes.usageLimitResetDate.month() != Date.today().month() && apiKeyRes.usageLimitResetDate.year() == Date.today().year())) {
        Open311APIHelper.resetUsageLimit(apiKeyRes.apiKey);
      }
      // Log this transaction.
      Open311APIHelper.logAPIUsage(apiKey);

      c.Origin = '311-API';
      c.Case_Source__c = apiKeyRes.name;
      populateCaseData(c, req);

      // Update Private Class2 Extended Attributes if appropriate 
      if (apiKeyRes.isPrivate) {
        populatePrivateCaseData(c, req);
      }


      insert c;
      System.debug('----> Newly Inserted Case: ' + c);

      //Update :- Based on the api an expanded set of parameters will be expected 
      if (apiKeyRes.isPrivate && !String.isBlank(req.params.get('tasks'))) {
        createActivities(c.Id, req);
      }
      // Only handle files if the request is private.
      System.debug('-----> HTTP[POST]: apiKeyRes.isPrivate(): ' + apiKeyRes.isPrivate);
      if (apiKeyRes.isPrivate) {
        // Verify a case attachment.
        Boolean resultOfAttachment = Open311_RequestsRestAPI_v2.createRequestAttachment(c, req, response);

        if (!resultOfAttachment) {
          Database.rollback(sp);
          return;
        }
      }

      bulkScheduleMap = createflexNotes(c, req);
      System.debug('----> bulkScheduleMap Result: ' + bulkScheduleMap);
      c = ServiceRequestsHelper.getRequest(c.Id);

      try {
        if (c.SRType__r.Service_Name__c.equalsIgnoreCase('Bulk Collection')) {
          System.debug('----> [Open311_RequestsRestAPI_v2] Attempting to insert new Bulk Schedulable... ');  
          ServiceRequestsHelper.upsertSRBulkSchedule(bulkScheduleMap, c);  
          System.debug('----> [Open311_RequestsRestAPI_v2] Sending email to Contact to inform of Bulk Case Creation...');
          WorkflowProcessUtility.sendTemplatedEmail(new List<String> (), new List<String> (), 'SR_HTML_Creation_Confirm_Bulk_Collection', c.ContactId, c.Id, null, false, null);
        }
      } catch(Exception e) {
        System.debug('----> [Open311_RequestsRestAPI_v2] Attempt to send email failed. No creations email sent to User.');
      }

      //send the response
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      Open311_ServiceRequestsAPIResponse.sendJSONResponse(c, apiKeyRes) :
      Open311_ServiceRequestsAPIResponse.sendXMLResponse(c, apiKeyRes);

      Open311APIHelper.logRequest(req, 'Success', 'Service request successfully created with request id: ' + c.id);

    } catch(Exception e) {
      Database.rollback(sp);
      system.debug(e.getMessage());
      //delete c;
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse('Error encountered while submitting the request:' + e.getMessage()) :
      CustomException.sendXMLApiErrorResponse('Error encountered while submitting the request:' + e.getMessage());

      Open311APIHelper.logRequest(req, 'Error', 'Error encountered while submitting the request:' + e.getMessage());
    }

    RestContext.response.responseBody = Blob.valueOf(responseStr);

  }

  /*
    @Purpose:-
    Updates service requests
   
    Format sent:- Content-Type: application/x-www-form-urlencoded
    HTTP Method PUT
    Formats returned    XML/JSON
    API Key: YES
   
    Sample Call:- https://[API endpoint]/requests.[format]      
   */
  @HttpPut
  global static void doUpdate() {
    System.debug('----> PUT: Begin');
    RestRequest req = RestContext.request;
    if (RestContext.response == null) RestContext.response = new RestResponse();

    RestResponse response = RestContext.response;

    //get the response format
    String format = req.requestURI.split('\\.').size() > 1 ? req.requestURI.split('\\.') [1] : '';

    String responseStr;

    /*
      API KEY SUPPORT             
     */
    String apiKey = req.params.get('api_key');
    System.debug('----> PUT: APIKey Step');
    APIValidations.APIKeyResponse apiKeyRes = Open311APIHelper.checkAPIKey(apiKey, req, response, format);
    if (apiKeyRes == null || apiKeyRes.isPublic) {
      Open311APIHelper.logRequest(req, 'Error', 'Service request could not be updated: ' +
                                  apiKeyRes == null ? 'API Key not provided' : 'Update not available to public');
      return;
    }
    apiKeyRes.httpMethod = 'put';


    /*
      check to see whether case id is passed
     */
    System.debug('----> PUT: Service Request ID Step');
    String requestId = req.params.get('service_request_id');
    if (requestId == null) {
      response.statuscode = 404;
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse('Service_request_id not provided') :
      CustomException.sendXMLApiErrorResponse('Service_request_id not provided');
      RestContext.response.responseBody = Blob.valueOf(responseStr);
      Open311APIHelper.logRequest(req, 'Error', 'Service_request_id not provided for update');
      return;
    }

    /*
      check to see whether jurisdiction_id is passed
     */
    String jId = req.params.get('jurisdiction_id');
    /*
      validate that the Juridictoion Id is correct 
     */
     System.debug('----> PUT: Jurisdiction Step');
    if (jId != null && !APIValidations.isValidJuridiction(jId)) {
      //invalid juridiction provided:-
      response.statuscode = 404;
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse('Invalid jurisdiction_id provided') :
      CustomException.sendXMLApiErrorResponse('Invalid jurisdiction_id provided');
      RestContext.response.responseBody = Blob.valueOf(responseStr);
      Open311APIHelper.logRequest(req, 'Error', 'Invalid jurisdiction_id provided:' + jId);
      return;
    }


    System.debug('----> PUT: Address Step');
    if (req.params.containsKey('address_id') || req.params.containsKey('address_string'))
    if (Test.isRunningTest()) {
      jsonstring = TestMARValidationJson();
    }
    else {
      jsonstring = AddressValidation.verifyAddress(req.params.get('address_id') != null ? req.params.get('address_id') : req.params.get('address_string'));
    }
    System.debug('----> PUT: Comments Step');
    // If comments are required to be sent with the status for the case then verify both are available with entries.
    if (apiKeyRes.isCommentsRequired) {
      String caseStatus = req.params.get('full_status');
      String caseClosureComment = req.params.get('comments');
      if ((caseStatus == null && caseClosureComment != null) || (caseClosureComment == null && caseStatus != null) || (caseStatus != null && String.isBlank(caseStatus)) || (caseClosureComment != null) && String.isBlank(caseClosureComment)) {
        response.statuscode = 404;
        responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
        CustomException.sendJSONApiErrorResponse('If attempting to close the service request, the status (full_status) AND closure comments (comments) must be provided.') :
        CustomException.sendXMLApiErrorResponse('If attempting to close the service request, the status (full_status) AND closure comments (comments) must be provided.');
        RestContext.response.responseBody = Blob.valueOf(responseStr);
        Open311APIHelper.logRequest(req, 'Error', 'SR Status and/or Case Closure Comments not provided.');
        return;
      }
    }

    Savepoint sp = Database.setSavepoint();

    //Create a service request:-
    try {
    System.debug('----> PUT: Usage Step');
      // If the usage reset date is not in the same month as today or the same year then reset it.
      if ((apiKeyRes.usageLimitResetDate != null && apiKeyRes.usageLimitResetDate.year() != Date.today().year()) || (apiKeyRes.usageLimitResetDate != null && apiKeyRes.usageLimitResetDate.month() != Date.today().month() && apiKeyRes.usageLimitResetDate.year() == Date.today().year())) {
        Open311APIHelper.resetUsageLimit(apiKeyRes.apiKey);
      }
      // Log this transaction.
      Open311APIHelper.logAPIUsage(apiKey);
      System.debug('----> PUT: Get exisiting SR Step: ' + requestId);
      Case c = ServiceRequestsHelper.getRequest(requestId);
      System.debug('----> PUT: Check for editible Service Request Types Step');
      System.debug('----> apiKeyRes.availableSRTypesToQueryForPUT: ' + apiKeyRes.availableSRTypesToQueryForPUT);
      if (apiKeyRes.availableSRTypesToQueryForPUT != null && apiKeyRes.availableSRTypesToQueryForPUT.size() > 0) {
        String code = c.srtype__r.Name;
        Boolean isAllowedType = false;

        for (String allowedType : apiKeyRes.availableSRTypesToQueryForPUT) {
          // Verify that all service codes are allowed for the current API user. 
          if (allowedType.equalsIgnoreCase(code)) {
            isAllowedType = true;
          }
        }

        if (!isAllowedType) {
          // Restricted code found. Throw error for user. 
          response.statuscode = 404;
          responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
          CustomException.sendJSONApiErrorResponse('Unauthorized Service Type requested. One or more of the service types requested is disabled on your account. Please contact support if you believe this to be incorrect.') :
          CustomException.sendXMLApiErrorResponse('Unauthorized Service Type requested. One or more of the service types requested is disabled on your account. Please contact support if you believe this to be incorrect.');
          RestContext.response.responseBody = Blob.valueOf(responseStr);
          Open311APIHelper.logRequest(req, 'Error', 'Restricted service code has been requested. Service Code: ' + code);
          return;
        }
      }

      // If the case is already closed and the user attempts to open it then thrown an error.
      if (req.params.containsKey('full_status') && req.params.get('full_status') != null) {
        String requestedStatus = req.params.get('full_status');

        if (c.isClosed && requestedStatus.containsIgnoreCase('open')) {
          response.statuscode = 404;
          responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
          CustomException.sendJSONApiErrorResponse('Unable to change status to Open on request that has previously been closed.') :
          CustomException.sendXMLApiErrorResponse('Unable to change status to Open on request that has previously been closed.');
          RestContext.response.responseBody = Blob.valueOf(responseStr);
          Open311APIHelper.logRequest(req, 'Error', 'Unable to change status to Open on request that has previously been closed.');
          return;
        }
      }

      // workaround data validation rules (no edits to Activities if SR is closed) while still supporting
      //        Workflow rules (standard and custom) that update Case Status
      //    Logically the entire PUT is considered to be a single update even though in SFDC we have to commit separately 
      //        and events take place around each commit (Upsert)
      string StatusBefore = c.Status;

      // Upsert Activities before Updating Case - they may change the Case status which should override a full_status parameter in PUT
      /*Update :- Based on the api an expanded set of parameters will be expected */
      if (apiKeyRes.isPrivate && !String.isBlank(req.params.get('tasks'))) {
        createActivities(c.Id, req);
      }

      // Only handle files if the request is private.
      if (apiKeyRes.isPrivate) {
        // Verify a case attachment.
        Boolean resultOfAttachment = Open311_RequestsRestAPI_v2.createRequestAttachment(c, req, response);

        if (!resultOfAttachment) {
          Database.rollback(sp);
          return;
        }
      }

      // Refetch Case data after Activity workflow/triggers/etc
      c = ServiceRequestsHelper.getRequest(requestId);

      // Get Case status after Activity Upsert - if it changed then this Status overrides whatever was submitted as full_status
      string StatusAfter = c.Status;

      // Update Base Open311 attributes
      populateCaseData(c, req);

      // Update Private Class2 Extended Attributes
      populatePrivateCaseData(c, req);

      // override Case.Status as set by full_status only if the Activity update changed it
      if (StatusBefore != StatusAfter && c.Status != StatusAfter) c.Status = StatusAfter;

      update c;

      c = ServiceRequestsHelper.getRequest(requestId);

      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      Open311_ServiceRequestsAPIResponse.sendJSONResponse(c, apiKeyRes) :
      Open311_ServiceRequestsAPIResponse.sendXMLResponse(c, apiKeyRes);

      Open311APIHelper.logRequest(req, 'Success', 'The given service request has been updated:' + requestId);

    } catch(CustomException e) {
      Database.rollback(sp);
      String message;
      response.statuscode = 400;
      message = e.getMessage();
      if (APIConstants.NOT_FOUND == e.getMessage()) {
        response.statuscode = 404;
        message = 'Invalid service_request_id provided';

      }
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse('Error while updating the record with request id:' + requestId + ' Error message:' + message) :
      CustomException.sendXMLApiErrorResponse('Error while updating the record with request id:' + requestId + ' Error message:' + message);

      Open311APIHelper.logRequest(req, 'Error', 'Error while updating the record with request id:' + requestId + '| Error message:' + message);
    }

    //logging to be done here

    RestContext.response.responseBody = Blob.valueOf(responseStr);

  }

  /*
    GET Service Request(s)
    @Purpose :-
    Query the current status of multiple requests
   
    or 
    When request id is passed:-Query the current status of an individual request
   
    Formats XML /JSON
    HTTP Method - GET
    Requires API  - NO
   
    @Params:-
    jurisdiction_id :- This is only required if the endpoint serves multiple jurisdictions        
    service_code :- The service_code is specified in the main URL path rather than an added query string parameter.
   
    Sample Call:-
    https://[API endpoint]/requests.[format]
    https://[API endpoint]/requests/[requests_id].[format]
   
    1. GET /requests - Returns a collection of sObjects 
   
   
    2. GET /requests/service_request_id - Returns a service  request
   
   */
  @HttpGet
  global static void getRequests() {
    RestRequest req = RestContext.request;

    if (RestContext.response == null) RestContext.response = new RestResponse();

    RestResponse response = RestContext.response;

    String format = req.requestURI.split('\\.').size() > 1 ? req.requestURI.split('\\.') [1] : '';

    String responseStr;


    /*
      API KEY SUPPORT             
     */
    String apiKey = req.params.get('api_key');

    APIValidations.APIKeyResponse apiKeyRes = Open311APIHelper.checkAPIKey(apiKey, req, response, format);
    if (apiKeyRes == null) {
      apiKeyRes = new APIValidations.APIKeyResponse();
      apiKeyRes.isPrivate = false;
      //apiKeyRes.flexNotesLocked=true;
      //apiKeyRes.activitiesLocked=true;
    }
    apiKeyRes.httpMethod = 'get';

    /*
      check to see whether jurisdiction_id is passed
     */
    String jId = req.params.get('jurisdiction_id');

    /*
      validate that the Juridictoion Id is correct 
     */
    if (jId != null && !APIValidations.isValidJuridiction(jId)) {
      //invalid juridiction provided:-
      response.statuscode = 404;
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse('Invalid jurisdiction_id provided') :
      CustomException.sendXMLApiErrorResponse('Invalid jurisdiction_id provided');
      RestContext.response.responseBody = Blob.valueOf(responseStr);
      Open311APIHelper.logRequest(req, 'Error', 'Invalid jurisdiction_id provided:' + jId);
      return;
    }

    try {
      // If the usage reset date is not in the same month as today or the same year then reset it.
      if ((apiKeyRes.usageLimitResetDate != null && apiKeyRes.usageLimitResetDate.year() != Date.today().year()) || (apiKeyRes.usageLimitResetDate != null && apiKeyRes.usageLimitResetDate.month() != Date.today().month() && apiKeyRes.usageLimitResetDate.year() == Date.today().year())) {
        Open311APIHelper.resetUsageLimit(apiKeyRes.apiKey);
      }
      // Log this transaction.
      Open311APIHelper.logAPIUsage(apiKey);
      // see if a service code was  part of the URI
      String requestId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
      requestId = requestId.split('\\.').size() > 1 ? requestId.split('\\.') [0] : requestId;
      if (requestId != '' && !requestId.startsWith('requests')) {
        //we have the service code here  : this is always done only if metadat =true
        responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
        Open311_ServiceRequestsAPIResponse.sendJSONResponse(ServiceRequestHistoryHelper.getRequest(requestId), apiKeyRes) :
        Open311_ServiceRequestsAPIResponse.sendXMLResponse(ServiceRequestHistoryHelper.getRequest(requestId), apiKeyRes);
      } else {

        /*
          @updte support for additional params:
         */
        List<String> filterConditions = new List<String> ();

        // Jurisdiction ID parameter in Open311 URL applies to entire OUC 311 system scope
        // DOES NOT APPLY to custom object jurisdiction
        //if(jId!=null) filterConditions.add(' SRType_Jurisdiction__r.Jurisdiction__c=\''+jId+'\'');

        //service_request_id - when provided overrides all other parameters
        if (req.params.get('service_request_id') != null) {
          List<String> ids = req.params.get('service_request_id').split(',');
          filterConditions.add(' Name IN (\'' + String.join(ids, '\',\'') + '\')');
            
          if (req.params.get('email') != null) {
            filterConditions.add(' Contact_Email__c = \'' + req.params.get('email') + '\'');
          }
        }
        else {
          // used to flag use of update_date parameter
          boolean update_date_set = false;

          // Servicing_agency ONLY available to isPrivate
          if (req.params.get('servicing_agency') != null && apiKeyRes.isPrivate) {
            if (req.params.get('servicing_agency') == 'CityWork-Open311Interface') {
              // DDOT / Cityworks is only custom setting for servicing_agency defined at this time
              filterConditions.add(' External_ID__c=null AND  Servicing_Agency__c=\'DDOT\'');
            } else {
              List<String> ids = req.params.get('servicing_agency').split(',');
              filterConditions.add(' Servicing_Agency__c IN (\'' + String.join(ids, '\',\'') + '\')');
            }
          }
          //else
          // No other options configured/required - parameter ignored if not private and not DDOT specific


          //service_code
          if (String.isNotBlank(apiKey) && req.params.get('service_code') != null) {
            List<String> ids = req.params.get('service_code').split(',');
            System.debug('----> Request Types: ' + ids);
            System.debug('----> Allows Types In Key: ' + apiKeyRes.availableSRTypesToQueryForGET);
            // Verify that all service codes are allowed for the current API user. 
            /*for (String code : ids) {
              if (!apiKeyRes.availableSRTypesToQueryForGET.contains(code)) {
                // Restricted code found. Throw error for user. 
                response.statuscode = 404;
                responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
                CustomException.sendJSONApiErrorResponse('Unauthorized Service Type requested. One or more of the service types requested is disabled on your account. Please contact support if you believe this to be incorrect.') :
                CustomException.sendXMLApiErrorResponse('Unauthorized Service Type requested. One or more of the service types requested is disabled on your account. Please contact support if you believe this to be incorrect.');
                RestContext.response.responseBody = Blob.valueOf(responseStr);
                Open311APIHelper.logRequest(req, 'Error', 'Restricted service code has been requested. Service Code: ' + code);
                return;
              }
            }*/

            filterConditions.add(' Service_Type_Code__c IN (\'' + String.join(ids, '\',\'') + '\')');
          }
          // Remove any types not allowed for this request so long as there is an API key with the restriction.
          if (String.isNotBlank(apiKey) && req.params.get('service_code') == null) {
            if (apiKeyRes.availableSRTypesToQueryForGET != null && apiKeyRes.availableSRTypesToQueryForGET.size() > 0) {
              String allowedTypesStr = '';
              for (String s : apiKeyRes.availableSRTypesToQueryForGET) {
                allowedTypesStr += (allowedTypesStr == '' ? '' : ',') + s;
              }
              filterConditions.add(' Service_Type_Code__c IN (\'' + String.join(new List<String> (apiKeyRes.availableSRTypesToQueryForGET), '\',\'') + '\')');
            }
          }

          //start_date
          if (req.params.get('start_date') != null) {
            //filterConditions.add(' CreatedDate >='+Open311APIHelper.convertTimestamp(req.params.get('start_date')));
            // Open311APIHelper.convertTimestamp returns a string with spaces : submitted w3 time formats are perfectly understood by SOQL
            filterConditions.add(' DateTimeOpened__c >=' + req.params.get('start_date'));
          }

          //end_date
          if (req.params.get('end_date') != null) {
            // see comments on start_date
            filterConditions.add(' DateTimeOpened__c <=' + req.params.get('end_date'));
          }
            
          //String updateDate = req.params.get('update_date')!=null ? :' CreatedDate >= LAST_90_DAYS ';
          if (req.params.get('update_date') != null && apiKeyRes.isPrivate) {
            // - UPDATE_DATE is only available to Private API key holders
            // see comments on start_date
            filterConditions.add(' LastUpdateDateTime__c >=' + req.params.get('update_date'));
            update_date_set = true;
          }

          //String Service_Request_id_Min - used to allow paging of class2=isprivate API responses
          if (req.params.get('service_request_id_min') != null && apiKeyRes.isPrivate && update_date_set)
          // Service_Request_id_Min is only available to Private API key holders
          // parameter can only be used in connection with update_date
          //          When bulk update has many Cases with same update time stamp - need to filter out prior delivered items
          //                -- this parameter alows specification of the last update date and SR ID of the last item received to ensure no items missed nor duplicated
          //filterConditions.add('( NOT (LastUpdateDateTime__c = ' + req.params.get('update_date') + ' AND CaseNumber__c <=\''+req.params.get('service_request_id_min') + '\' ) ) ');
          filterConditions.add('( NOT (LastUpdateDateTime__c = ' + req.params.get('update_date') + ' AND Name <=\'' + req.params.get('service_request_id_min') + '\' ) ) ');

          //status - OPEN311 SPEC public status:  Only Open & Closed are supported - determined based By Case.IsClosed
          System.debug('----> Checking "Status" Parameter...');
          if (req.params.get('status') != null) {
            System.debug('----> Status param available for processing.');
            List<String> ids = req.params.get('status').split(',');
            //filterConditions.add(' Status__c IN (\''+String.join(ids,'\',\'')+'\')');
            boolean open = false;
            boolean closed = false;
            for (string status : ids) {
              System.debug('----> GETCHECK: status: ' + status);
              if (status.equalsignorecase('open')) open = true;
              if (status.equalsignorecase('closed')) closed = true;
            }

            if (open && !closed)
            filterConditions.add(' IsClosed__c=false');
            if (!open && closed)
            filterConditions.add(' IsClosed__c=true');
            System.debug('----> GETCHECK: Open:' + open + '  -- Closed: ' + closed);
          }
          // Check for the full status.
          if (req.params.get('full_status') != null && apiKeyRes != null && apiKeyRes.isPrivate) {
            System.debug('----> Full Status Filter Requested: ' + req.params.get('full_status'));
            String status = req.params.get('full_status');

            if (String.isNotBlank(status)) {
              filterConditions.add(' Status__c=\'' + status + '\'');
            }
          }

          if (filterConditions.size() == 0) {
            filterConditions.add(' DateTimeOpened__c >= LAST_90_DAYS ');
          }
        }
        responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
        Open311_ServiceRequestsAPIResponse.sendJSONResponse(ServiceRequestHistoryHelper.listAllRequests(String.join(filterConditions, ' AND '), apiKeyRes.isPrivate), apiKeyRes) :
        Open311_ServiceRequestsAPIResponse.sendXMLResponse(ServiceRequestHistoryHelper.listAllRequests(String.join(filterConditions, ' AND '), apiKeyRes.isPrivate), apiKeyRes);
      }

      Open311APIHelper.logRequest(req, 'Success', 'Successful return of the requested data. ');

    } catch(CustomException e) {
      String message;
      response.statuscode = 400;
      message = e.getMessage();
      if (APIConstants.NOT_FOUND == e.getMessage()) {
        response.statuscode = 404;
        message = 'Invalid service_request_id provided';

      }
      responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
      CustomException.sendJSONApiErrorResponse(message) :
      CustomException.sendXMLApiErrorResponse(message);

      Open311APIHelper.logRequest(req, 'Error', message);
    }
    RestContext.response.responseBody = Blob.valueOf(responseStr);
  }

  /*
    HELPER METHODS
   */

  /**
   * createRequestAttachment
   *
   * @description This function will determine if an attachment is available, under 25MB, and attach it to the current case.
   * @param mCase The case to attach the file too.
   * @param req The incoming HTTP Request.
   * @param res  The response to the request.
   * @return Boolean Reply if an error has occured or not.
   */
  private static Boolean createRequestAttachment(Case mCase, RestRequest req, RestResponse res) {
    System.debug('----> Inside createRequestAttachment!');

    try {
      String format = req.requestURI.split('\\.').size() > 1 ? req.requestURI.split('\\.') [1] : '';
      System.debug('----> Rest Request: ' + req);
      //System.debug('----> Rest Response: ' + res);

      // Get the file attachment from the File Body if available.
      if (req.requestBody != null && req.requestBody.size() > 0) {
        System.debug('----> Request has a filled requestbody.');
        Blob fileBlob = req.requestBody;
        String fileName = req.params.get('filename');

        // Check the filename is present.
        if (String.isBlank(fileName)) {
          res.statuscode = 404;
          String responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
          CustomException.sendJSONApiErrorResponse(' Filename not provided for uploaded file. Please add one and try again.') :
          CustomException.sendXMLApiErrorResponse(' Filename not provided for uploaded file. Please add one and try again.');
          res.responseBody = Blob.valueOf(responseStr);
          Open311APIHelper.logRequest(req, 'Error', 'Filename was not provided in the GET parameters.');
          return false;
        }

        // Check the size of the blob and enforce a 25MB limit.
        if (fileBlob.size() >= 26214400) {
          res.statuscode = 404;
          String responseStr = req.headers.get('Content-Type') == APIConstants.CONTENT_TYPE_JSON || format == 'json' ?
          CustomException.sendJSONApiErrorResponse(' Uploaded file exceeds 25MB limit. Please reduce your file size or upload a different file.') :
          CustomException.sendXMLApiErrorResponse(' Uploaded file exceeds 25MB limit. Please reduce your file size or upload a different file.');
          res.responseBody = Blob.valueOf(responseStr);
          Open311APIHelper.logRequest(req, 'Error', 'Uploaded file exceeds 25MB limit. Please reduce your file size or upload a different file.');
          return false;
        }

        // File is smaller than 25MB. Continue...
        Attachment attach = new Attachment();
        attach.Body = fileBlob;
        attach.Name = fileName;
        attach.ParentId = mCase.Id;
        System.debug('----> Attachment to Insert: ' + attach);
        insert attach;
      }
    } catch(Exception e) {
      System.debug('----> Exception: ' + e.getMessage());
    }
    return true;
  }

  private static void populateCaseData(Case c, RestRequest req) {

    //if(!String.isBlank(req.params.get('description')))c.subject = req.params.get('description'); 
    if (req.params.containsKey('description')) c.description = req.params.get('description');
    if (req.params.containsKey('device')) c.device__c = req.params.get('device');



    if (req.params.containsKey('service_code')) {
      ServiceRequestType__c srt = ServicesHelper.getService(req.params.get('service_code'));
      c.srtype__c = srt.id;
      c.Subject = srt.service_name__c;
      c.AgencyCode__c = srt.Agency__c;
      c.SLA__c = srt.SLA__c;
    }



    // ER:  If we get valid address/lan/lon from MAR - DO NOT overwrite with submitted lat/lon below
    /*
      if(req.params.get('lat')!=null && req.params.get('long')!=null){
      c.GeoLocation__Latitude__s = decimal.valueof(req.params.get('lat'));
      c.GeoLocation__Longitude__s = decimal.valueof(req.params.get('long'));
      }
     */

    if (req.params.containsKey('media_url')) c.Media_URL__c = req.params.get('media_url');

    /* 
      @ from the other details we will get the contact that will be associated with the case         
      Branch behavior if Contact exists already (with a PUT) or if needs to be created
     */
    if (c.ContactId == null) {
      Boolean skipContact = false;  
        
      if (req.httpMethod == 'PUT' && (String.isBlank(req.params.get('first_name')) || String.isBlank(req.params.get('last_name')))) {
        skipContact = true;    
      }
        
      if (!skipContact) {
        c.ContactId = ServiceRequestsHelper.createServiceRequestContact(req.params).Id;
      }
    }
    else {
      /* Update not supported while sharing applies to contact
        if(!String.isBlank(req.params.get('last_name')))c.Contact.LastName = req.params.get('last_name'); 
        if(!String.isBlank(req.params.get('first_name')))c.Contact.FirstName = req.params.get('first_name'); 
        if(!String.isBlank(req.params.get('phone')))c.Contact.Phone = req.params.get('phone'); 
        if(!String.isBlank(req.params.get('email')))c.Contact.Email = req.params.get('email'); 
       */
    }
  }

  /*
    Handles Private/Class2 attribute updates for POST and for PUT methods
   */
  private static void populatePrivateCaseData(Case c, RestRequest req) {
    if (req.params.containsKey('full_status')) {
      c.Status = req.params.get('full_status');
    }

    if (req.params.containsKey('priority')) {
      c.Priority = req.params.get('priority');
    }

    if (req.params.containsKey('language')) {
      c.Language__c = req.params.get('language');
    }

    if (req.params.containsKey('external_id')) {
      c.External_Id__c = req.params.get('external_id');
    }

    if (req.params.containsKey('external_system_name')) {
      c.External_System_Name__c = req.params.get('external_system_name');
    }

    if (req.params.containsKey('comments')) {
      c.Case_Closure_Comment__c = req.params.get('comments');
    }
  }

  private static Map<Date, BulkSchedule__c> createflexNotes(Case sr, RestRequest req) {
    List<ServiceRequestTypeFlexNote__c> flexnotes;
	Map<Date, BulkSchedule__c> bulkScheduleMap = new Map<Date, BulkSchedule__c>();
    Map<String, ServiceRequestTypeFlexNote__c> flexNoteMap = new Map<String, ServiceRequestTypeFlexNote__c> ();
      
    try {
      flexnotes = ServicesHelper.getServiceMetadata(req.params.get('service_code'));
    } catch(Exception e) {
      if (APIConstants.NOT_FOUND == e.getMessage()) {
        throw new CustomException('Invalid service_code provided');
      } else throw e;
    }
    
    for (ServiceRequestTypeFlexNote__c note : flexnotes) {
      //flexNoteMap.put(note.name,note);
      flexNoteMap.put(note.FlexNote_Question__r.name, note);
    }

    Set<String> codes = new Set<String> ();
    List<FlexNote__c> notes = new List<FlexNote__c> ();
    //Inserting flexnotes if present:-
    //  ER:  Need to handle picklists with code values including multi-select picklists
    //       Incoming submissions will use code values if available - we store answers with 
    //       code values as CODE:Human readable answer
    //       Human readable answer needs to be parsed from the flexnote question potential answers
    //       MULTI-SELECT picklist are same but you need to compile all selected answers with the same attribute[questioncode] key
    system.debug(req.params);
    Map<String, List<String>> flex_note_code_ans_map = new Map<String, List<String>> ();
    for (String key : req.params.keySet()) {
      if (key.startsWith('attribute')) {
        String code = key.substringBetween('[', ']');
        system.debug(code);
        /*
          validation
         */
        if (flexNoteMap.get(code) == null) {
          //invalid question part of data
          throw new CustomException('Invalid flexnote found');
        }

        if (flexNoteMap.get(code) != null && flexNoteMap.get(code).FlexNote_Question__r.Required__c && String.isBlank(req.params.get(key))) {
          throw new CustomException('Required answer for question['+ flexNoteMap.get(code).FlexNote_Question__r.Name +'] is missing: ' + flexNoteMap.get(code).FlexNote_Question__r.Questions__c);
          return null;
        } 

        //updating for mutipicklist handling

        // notes.add(new  FlexNote__c(case__c=caseId,
        //                            FlexNote_Question__c=flexNoteMap.get(code).FlexNote_Question__c,
        //                           Answer__c=req.params.get(key)
        //                            )
        //           );
        // codes.add(code);
        //flexNoteMap.remove(code); 

        List<String> codes_ans = flex_note_code_ans_map.get(code) != null ? flex_note_code_ans_map.get(code) : new List<String> ();
        codes_ans.add(req.params.get(key));
        flex_note_code_ans_map.put(code, codes_ans);
      }
    }   

    for (String code : flex_note_code_ans_map.keySet()) {
      String scheduleAnswer = null;

      if (flexNoteMap.get(code).FlexNote_Question__r.Answer_Type__c == 'Text') {
        if (flexNoteMap.get(code).FlexNote_Question__r.AnswerValues__c != null) {
          if (flexNoteMap.get(code).FlexNote_Question__r.AnswerValues__c == '{!value}') {
            BulkSchedule__c bS = fetchBulkScheduleDetails(sr.ward__c, 'DailyLimit');
            system.debug('bS--' + bS);

            if (bS != null) {
              scheduleAnswer = string.valueOf(bS.ScheduleDate__c.format());
              System.debug('----> Flex Notes Bulk Schedule Date: ' + scheduleAnswer);
                
              if (bS.ScheduleDate__c != null) {
                if (!bulkScheduleMap.containsKey(bS.ScheduleDate__c)) {
                  bulkScheduleMap.put(bS.ScheduleDate__c, bS);
                  System.debug('----> BulkScheduleMap: ' + bulkScheduleMap);
                }
              }
            }
          }
        }
      }

      String flexNoteAnswer = null;
      if (scheduleAnswer != null) {
        flexNoteAnswer = scheduleAnswer;
      } else {
        flexNoteAnswer = String.join(flex_note_code_ans_map.get(code), ',');
      }

      notes.add(new FlexNote__c(case__c = sr.Id,
                                FlexNote_Question__c = flexNoteMap.get(code).FlexNote_Question__c,
                                Questions__c = flexNoteMap.get(code).FlexNote_Question__r.Questions__c,
                                Order__c = decimal.valueof(flexNoteMap.get(code).Order__c),
                                Answer__c = flexNoteAnswer
      ));
      flexNoteMap.remove(code);
    }
    System.debug('----> New FlexNotes: ' + notes);


    //if any flex note left out and it required throw back error 
    if (flexNoteMap.size() > 0) {
      //system.debug(flexNoteMap);
      for (String code : flexNoteMap.keySet()) {
        //if(codes.contains(code)){
        //  continue;
        //}

        ServiceRequestTypeFlexNote__c extra = flexNoteMap.get(code);
        if (extra.FlexNote_Question__r.Required__c) {
          throw new CustomException('Required answer for question['+ extra.FlexNote_Question__r.Name +'] is missing: ' + extra.FlexNote_Question__r.Questions__c);
          return null;
        }
        //system.debug(extra.FlexNote_Question__c);
        notes.add(new FlexNote__c(case__c = sr.Id,
                                  FlexNote_Question__c = extra.FlexNote_Question__c,
                                  Questions__c = extra.FlexNote_Question__r.Questions__c,
                                  Order__c = decimal.valueof(extra.Order__c)
        ));
      }
    }

    //before we insert notes we need to decode the available answer if any get the values from decode object
    /*List<Decode_Object__c> codeList = [Select code__c,Value__c from Decode_Object__c WHERE Code__c IN:codes];
      Map<String,String> codedAns = new Map<String,String>();
      if(codeList.size()>0){
      for(Decode_Object__c obj:codeList)
      codedAns.put(obj.code__c,obj.Value__c);
      }
     
      for(FlexNote__c note: notes){
     
      List<String> answers = new List<String>();
      for(String code: note.answer__c.split(',')){
      answers.add(codedAns.get(code)!=null? code+':'+codedAns.get(code) :code);
      }
     
      note.codedescription__c =  String.join(answers,';');//!String.isBlank(note.answer__c) && codedAns.get(note.answer__c)!=null? note.answer__c+':'+codedAns.get(note.answer__c) :note.answer__c;
      }
     */
    if (notes.size() > 0) insert notes;
    return bulkScheduleMap;
  }


  /**
   *  Get the Bulk schedule date
   *
   */
  private static BulkSchedule__c fetchBulkScheduleDetails(String ward, string DailyLimit) {
    string scheduleDate;
    system.debug('ward--' + ward);
    if (ward == null) {
      throw new CustomException('Please provide address for this service type, then reselect service type');
      return null;
    }
    else {
      sObject sobj = ServiceRequestsHelper.getFlexNoteDefault(ward, DailyLimit);
      if (sobj != null) {
        BulkSchedule__c bS = (BulkSchedule__c) sobj;
        scheduleDate = string.valueOf(bS.ScheduleDate__c.format());
        return bS;
      }
      else {
        throw new CustomException('There are no records for provided address');
        return null;
      }
    }
  }

  private static void createActivities(String caseId, RestRequest req) {
    List<OUC_Activity__c> activities = new List<OUC_Activity__c> ();

    //get existing activities if any?
    Map<String, OUC_Activity__c> existing = new Map<String, OUC_Activity__c> ();
    for (OUC_Activity__c t :[Select Id, Task_Code__c, Citizen_Email_On_Complete__c, Description__c, external_comments__c,
         outcome__c, Display_Sort_order__c, completion_date__c, Status__c, Activity_Date__c, Responsible_Party__c
         FROM OUC_Activity__c WHERE case__c = :caseId])
    existing.put(t.Task_Code__c, t);

    //System.debug('----> req.params.getRequests(tasks): ' + req.params.get('tasks'));
    List<ActivityWrapper> activity = (List<ActivityWrapper>) JSON.deserialize(req.params.get('tasks'), List<ActivityWrapper>.class);

    for (ActivityWrapper act : activity) {
      OUC_Activity__c task = existing.get(act.Task_code) != null ? existing.get(act.Task_code) : new OUC_Activity__c();

      /*
        if at any point there is no task code provided
       */
      if (String.isBlank(act.Task_code)) {
        throw new CustomException('Task code not provided');
      }

      if (act.Task_code != null) task.Task_Code__c = act.Task_code;
      if (act.Task_Short_Name != null) task.Task_short_name__c = act.Task_Short_Name;
      if (act.Citizen_Email_On_Complete != null) task.Citizen_Email_On_Complete__c = act.Citizen_Email_On_Complete.equalsIgnoreCase('true') ? true : false;
      if (act.Internal_Comments != null) task.Description__c = act.Internal_Comments;
      if (act.External_Comments != null) task.external_comments__c = act.External_Comments;
      if (act.Outcome != null) task.outcome__c = act.Outcome;
      if (act.Order != null) task.Display_Sort_order__c = act.Order;
      if (act.Completion_Date != null) task.completion_date__c = act.Completion_date;
      if (act.Status != null) task.Status__c = act.Status;
      //if(act.Due_Date!=null) task.Activity_Date__c = act.Due_Date;
      if (act.Responsible_Party != null) task.Responsible_Party__c = act.Responsible_Party;

      task.case__c = caseId;
      activities.add(task);
    }
    System.debug('----> Activities to Upsert: ' + activities);
    upsert activities;

  }




  /*
    JSON Wrapper Class
   */
  public class ActivityWrapper {
    public string Task_code { get; set; }
    public string Task_Short_Name { get; set; }
    public string Citizen_Email_On_Complete { get; set; }
    public string Internal_Comments { get; set; }
    public string External_Comments { get; set; }
    public string Outcome { get; set; }
    public string Order { get; set; }
    public DateTime Completion_date { get; set; }
    public string Status { get; set; }
    public DateTime Due_Date { get; set; }
    public string Responsible_Party { get; set; }
  }
  /*
    MAR Address CallOut Json return value for running tests
   */
  private static string TestMARValidationJson() {
    string js;
    js = '{"returnCodes":null,"details":"<STRONG>Parsed:</STRONG></br><EM>Street Name 1: </EM>14TH</br><EM>Street Type 1: </EM></br><EM>Quad 1: </EM></br><EM>Direction 1: </EM></br><EM>Street Name 2: </EM>U</br><EM>Street Type 2: </EM>STREET</br><EM>Quad 2: </EM></br><EM>Direction 2: </EM></br><STRONG>Possible Standard Street Names 1: </STRONG></br>14TH</br><STRONG>Possible Standard Street Names 2: </STRONG></br>U</br>",';
    js += '"returnDataset":{"Table1":[{"MARID":903573.0,"INTERSECTIONID":15843.0,"STREET1ID":108723.0,"STREET2ID":100140.0,"ST1NAME":"U","ST1TYPE":"STREET","ST1QUAD":"NW","FULLSTREET1DISPLAY":"U STREET NW","ST2NAME":"14TH","ST2TYPE":"STREET","ST2QUAD":"NW","FULLSTREET2DISPLAY":"14TH STREET NW","FULLINTERSECTION":"U STREET NW AND 14TH STREET NW","REFX":397229.13001138,"REFY":138792.67999823,"NATIONALGRID":"18S UJ 23837 09529","LATITUDE":38.91699812128980,"LONGITUDE":-77.03195073766770,"ConfidenceLevel":62.5},';
    js += '{"MARID":903021.0,"INTERSECTIONID":15289.0,"STREET1ID":300140.0,"STREET2ID":308723.0,"ST1NAME":"14TH","ST1TYPE":"STREET","ST1QUAD":"SE","FULLSTREET1DISPLAY":"14TH STREET SE","ST2NAME":"U","ST2TYPE":"STREET","ST2QUAD":"SE","FULLSTREET2DISPLAY":"U STREET SE","FULLINTERSECTION":"14TH STREET SE AND U STREET SE","REFX":401268.25001513,"REFY":133120.61000897,"NATIONALGRID":"18S UJ 27750 03769","LATITUDE":38.86590545932130,"LONGITUDE":-76.985386353798,"ConfidenceLevel":62.5},';
    js += '{"MARID":903021.0,"INTERSECTIONID":15289.0,"STREET1ID":308723.0,"STREET2ID":300140.0,"ST1NAME":"U","ST1TYPE":"STREET","ST1QUAD":"SE","FULLSTREET1DISPLAY":"U STREET SE","ST2NAME":"14TH","ST2TYPE":"STREET","ST2QUAD":"SE","FULLSTREET2DISPLAY":"14TH STREET SE","FULLINTERSECTION":"U STREET SE AND 14TH STREET SE","REFX":401268.25001513,"REFY":133120.61000897,"NATIONALGRID":"18S UJ 27750 03769","LATITUDE":38.86590545932130,"LONGITUDE":-76.985386353798,"ConfidenceLevel":62.5},';
    js += '{"MARID":903573.0,"INTERSECTIONID":15843.0,"STREET1ID":100140.0,"STREET2ID":108723.0,"ST1NAME":"14TH","ST1TYPE":"STREET","ST1QUAD":"NW","FULLSTREET1DISPLAY":"14TH STREET NW","ST2NAME":"U","ST2TYPE":"STREET","ST2QUAD":"NW","FULLSTREET2DISPLAY":"U STREET NW","FULLINTERSECTION":"14TH STREET NW AND U STREET NW","REFX":397229.13001138,"REFY":138792.67999823,"NATIONALGRID":"18S UJ 23837 09529","LATITUDE":38.91699812128980,"LONGITUDE":-77.03195073766770,"ConfidenceLevel":62.5}]},';
    js += '"returnBlkAddrDataset":null,"returnCDDataSet":{"Address Return Codes":[{"Component":"Street Type 1","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Street Type 2","Parsed & Normalized":"STREET","Assessment":"Valid"},{"Component":"Quad","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Direction","Parsed & Normalized":"","Assessment":"Missing"},{"Component":"Street Name 1","Parsed & Normalized":"14TH","Assessment":"Valid"},';
    js += '{"Component":"Street Name 2","Parsed & Normalized":"U","Assessment":"Valid"}]},"UNIT":null,"UNITNUMBER":null,"sourceOperation":"DC Intersection","processTime":null}';

    return js;

  }

}