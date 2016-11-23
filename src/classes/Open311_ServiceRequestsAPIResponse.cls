public class Open311_ServiceRequestsAPIResponse {


  public static String sendJSONResponse(List<Service_Request_History__c> requests, APIValidations.APIKeyResponse apiKeyRes) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartArray();
    for (Service_Request_History__c req : requests) {
      jsonHelper(gen, req, apiKeyRes);
    }
    gen.writeEndArray();
    return gen.getAsString();
  }

  private static void jsonHelper(JSONGenerator gen, Service_Request_History__c req, APIValidations.APIKeyResponse apiKeyRes) {
    gen.writeStartObject();
    gen.writeStringField('service_request_id', stringValue(req.name));
    //gen.writeStringField('status', req.IsClosedOnCreate__c ? 'closed' : 'open');
    gen.writeStringField('status', req.IsClosed__c ? 'closed' : 'open');
    gen.writeStringField('status_notes', '');
    gen.writeStringField('service_name', stringValue(req.srtype__c));
    gen.writeStringField('service_code', stringValue(req.Service_Type_Code__c));
    gen.writeStringField('description', stringValue(req.description__c));

    gen.writeStringField('agency_responsible', stringValue(req.Servicing_Agency__c));
    gen.writeStringField('service_notice', stringValue(req.reason__c));

    gen.writeStringField('requested_datetime', formatDate(req.DateTimeOpened__c).trim());
    gen.writeStringField('updated_datetime', formatDate(req.LastUpdateDateTime__c).trim());
    gen.writeStringField('expected_datetime', formatDate(req.Expected_Resolution_Date__c).trim());

    gen.writeStringField('address', stringValue(req.Address__c));
    gen.writeStringField('address_id', stringValue(req.AddressID__c));
    gen.writeStringField('zipcode', req.Zipcode__c != null ? stringValue(String.valueof(req.Zipcode__c)) : '');
    gen.writeStringField('lat', stringValue(string.valueof(req.geolocation__latitude__s)));
    gen.writeStringField('long', stringValue(string.valueof(req.geolocation__longitude__s)));
    gen.writeStringField('media_url', stringValue(req.media_url__c));

    if (apiKeyRes.isPrivate && (String.isNotBlank(apiKeyRes.httpMethod) && apiKeyRes.getSRTypesToQueryForHttpMethod(apiKeyRes.httpMethod).contains(req.Service_Type_Code__c))) {

      //additional expanded attributes
      gen.writeStringField('full_status', stringValue(req.Status__c));
      gen.writeStringField('priority', stringValue(req.Priority__c));
      gen.writeStringField('origin', stringValue(req.Origin__c));
      gen.writeStringField('contact_last_name', stringValue(req.contactlastname__c));
      gen.writeStringField('contact_first_name', stringValue(req.contactfirstname__c));
      gen.writeStringField('contact_phone', stringValue(string.valueof(req.contactPhone__c)));
      gen.writeStringField('contact_email', stringValue(string.valueof(req.contact_Email__c)));
      gen.writeStringField('device', stringValue(req.Device__c));

      gen.writeStringField('sla', stringValue(req.SLA__c));
      gen.writeStringField('external_id', stringValue(req.External_Id__c));
      gen.writeStringField('external_system_name', stringValue(req.External_System_Name__c));
      gen.writeStringField('language', stringValue(req.Language__c));
      gen.writeStringField('intersection_id', stringValue(req.IntersectionID__c));
      gen.writeStringField('quadrant', stringValue(req.Quadrant__c));
      gen.writeStringField('ward', stringValue(req.Ward__c));
      gen.writeStringField('poldist', stringValue(req.District__c));
      gen.writeStringField('psa', stringValue(req.PSA__c));
      gen.writeStringField('anc', stringValue(req.ANC__c));
      gen.writeStringField('smd', stringValue(req.SMD__c));
      gen.writeStringField('cluster', stringValue(req.Neighbor_Hood_Cluster__c));
      gen.writeStringField('xcoord', stringValue(req.XCOORD__c));
      gen.writeStringField('ycoord', stringValue(req.YCOORD__c));

      gen.writeStringField('Servicing_agency_code', stringValue(req.Jurisdiction_Code__c));
      gen.writeStringField('Servicing_agency_description', stringValue(req.Jurisdiction_Description__c));

      //FlexNotes or Attributes:
      //Check if Flexnotes are locked for this API user and send flex notes if NOT locked
      if (!apiKeyRes.flexNotesLocked) {
        //additional Flex Notes attributes 
        if (req.Flex_Note_Histories__r != null && req.Flex_Note_Histories__r.size() > 0) {
          gen.writeFieldName('attributes');
          gen.writeStartArray();
          for (Flex_Note_History__c f : req.Flex_Note_Histories__r) {
            if (!f.IsSecure__c) {
              gen.writeStartObject();
              //put in the attribute fields
              gen.writeStringField('code', stringValue(string.valueof(f.FlexNote_Question__c)));
              gen.writeStringField('question', stringValue(string.valueof(f.questions__c)));
              gen.writeStringField('order', f.order__c != null ? stringValue(String.valueof(f.order__c)) : '');

              if (f.codedescription__c != null) {
                gen.writeFieldName('values'); gen.writeStartArray();
                Map<String, String> code_map = (Map<String, String>) JSON.deserialize(f.codedescription__c, Map<String, String>.class);
                for (String ans : code_map.keySet()) {
                  gen.writeStartObject();
                  List<String> code_ans = ans.split(':');
                  gen.writeFieldName('value'); gen.writeStartArray(); gen.writeStartObject();
                  // answer fields need to be split into a collection for multi-select picklists
                  gen.writeStringField('answer', stringValue(ans));
                  // answer_name needs to be retrieved from code-decode where applicable
                  gen.writeStringField('answer_name', stringValue(code_map.get(ans)));
                  gen.writeEndObject(); gen.writeEndArray();
                  gen.writeEndObject();
                }
                gen.writeEndArray();
              }
              gen.writeEndObject();
            }

          }
          gen.writeEndArray();
        }
      }

      //Activities or Tasks:
      //Check if Activities are locked for this API user and send flex notes if NOT locked
      if (!apiKeyRes.activitiesLocked) {
        //add attributes to the list
        if (req.OUC_Activity_Histories__r != null && req.OUC_Activity_Histories__r.size() > 0) {
          gen.writeFieldName('tasks');
          gen.writeStartArray();
          for (OUC_Activity_History__c t : req.OUC_Activity_Histories__r) {
            gen.writeStartObject();
            //put in the task fields
            gen.writeStringField('task_code', stringValue(string.valueof(t.Task_Code__c)));
            gen.writeStringField('task_short_name', stringValue(string.valueof(t.Task_short_name__c)));
            gen.writeStringField('citizen_email_on_complete', stringValue(string.valueof(t.Citizen_Email_On_Complete__c)));
            gen.writeStringField('internal_comments', stringValue(string.valueof(t.Description__c)));
            gen.writeStringField('external_comments', stringValue(string.valueof(t.external_comments__c)));
            gen.writeStringField('outcome', stringValue(string.valueof(t.outcome__c)));
            gen.writeStringField('order', stringValue(string.valueof(t.Display_Sort_order__c)));
            gen.writeStringField('completion_date', formatDate(t.completion_date__c).trim());
            gen.writeStringField('status', stringValue(string.valueof(t.Status__c)));
            gen.writeStringField('due_date', formatDate(t.Due_Date__c).trim());
            gen.writeStringField('responsible_party', stringValue(string.valueof(t.Responsible_Party__c)));

            gen.writeEndObject();
          }
          gen.writeEndArray();
        }
      }

      if (req.Attachments != null && req.Attachments.size() > 0) {
        gen.writeFieldName('attachments');
        gen.writeStartArray();
        for (Attachment a : req.Attachments) {
          gen.writeStartObject();
          gen.writeStringField('name', stringValue(String.valueOf(a.Name)));
          gen.writeStringField('description', stringValue(String.valueOf(a.Description)));
          gen.writeStringField('content_type', stringValue(String.valueOf(a.ContentType)));
          gen.writeEndObject();
        }
        gen.writeEndArray();
      }
    }
    gen.writeEndObject();
  }

  public static String sendJSONResponse(Service_Request_History__c req, APIValidations.APIKeyResponse apiKeyRes) {
    JSONGenerator gen = JSON.createGenerator(true);
    jsonHelper(gen, req, apiKeyRes);
    return gen.getAsString();
  }

  public static String sendXMLResponse(List<Service_Request_History__c> requests, APIValidations.APIKeyResponse apiKeyRes) {
    //Dom.Document doc = new Dom.Document();
    //Dom.Xmlnode rootNode = doc.createRootElement('service_requests', null, null); 
    String xml = '<?xml version="1.0" encoding="UTF-8"?><service_requests>';
    for (Service_Request_History__c req : requests) {
      //xmlHelper(rootNode,req,isPrivate);
      xml += xmlHelper(req, apiKeyRes);
    }

    xml += '</service_requests>';
    return xml;
    //return doc.toXMLString();
  }

  public static String sendXMLResponse(Service_Request_History__c req, APIValidations.APIKeyResponse apiKeyRes) {
    //Dom.Document doc = new Dom.Document();
    //Dom.Xmlnode rootNode = doc.createRootElement('service_requests', null, null); 
    //xmlHelper(rootNode,req,isPrivate);
    String xml = '<?xml version="1.0" encoding="UTF-8"?><service_requests>';
    xml += xmlHelper(req, apiKeyRes);
    xml += '</service_requests>';
    return xml;
    //return doc.toXMLString();
  }

  private static string xmlHelper(Service_Request_History__c req, APIValidations.APIKeyResponse apiKeyRes) {
    System.debug('----> Inside xmlHelper(Service_Request_History__c req,Boolean isPrivate) => 1');
    String xml = '';
    xml += '<request>';
    xml += '<service_request_id>' + stringValue(req.name) + '</service_request_id>';
    //xml += '<status>' + stringValue(req.IsClosedOnCreate__c ? 'closed' : 'open') + '</status>';
    xml += '<status>' + stringValue(req.IsClosed__c ? 'closed' : 'open') + '</status>';
    xml += '<status_notes></status_notes>';
    xml += '<service_name>' + stringValue(req.SRType__c) + '</service_name>';
    xml += '<service_code>' + stringValue(req.Service_Type_Code__c) + '</service_code>';
    xml += '<description>' + stringValue(req.description__c) + '</description>';
    xml += '<agency_responsible>' + stringValue(req.Servicing_Agency__c) + '</agency_responsible>';
    xml += '<service_notice>' + stringValue(req.reason__c) + '</service_notice>';
    xml += '<requested_datetime>' + formatDate(req.DateTimeOpened__c).trim() + '</requested_datetime>';
    xml += '<updated_datetime>' + formatDate(req.LastUpdateDateTime__c).trim() + '</updated_datetime>';
    xml += '<expected_datetime>' + formatDate(req.Expected_Resolution_Date__c).trim() + '</expected_datetime>';

    xml += '<address>' + stringValue(req.address__c) + '</address>';
    xml += '<address_id>' + stringValue(req.addressid__c) + '</address_id>';
    // Not returning at all.
    if (req.Zipcode__c != null) {
      System.debug('----> Zipcode is not null');
      xml += '<zipcode>' + stringValue(String.valueof(req.Zipcode__c)) + '</zipcode>';
    } else {
      System.debug('----> Zipcode is null');
      xml += '<zipcode></zipcode>';
    }
    xml += '<lat>' + stringValue(string.valueof(req.geolocation__latitude__s)) + '</lat>';
    xml += '<long>' + stringValue(string.valueof(req.geolocation__longitude__s)) + '</long>';

    xml += '<media_url>' + stringValue(req.media_url__c) + '</media_url>';

    if (apiKeyRes.isPrivate && (String.isNotBlank(apiKeyRes.httpMethod) && apiKeyRes.getSRTypesToQueryForHttpMethod(apiKeyRes.httpMethod).contains(req.Service_Type_Code__c))) {
      //additional expanded attributes
      xml += '<full_status>' + stringValue(req.Status__c) + '</full_status>';
      xml += '<priority>' + stringValue(req.Priority__c) + '</priority>';
      xml += '<origin>' + stringValue(req.Origin__c) + '</origin>';
      xml += '<contact_last_name>' + stringValue(req.ContactLastName__c) + '</contact_last_name>';
      xml += '<contact_first_name>' + stringValue(req.ContactFirstName__c) + '</contact_first_name>';
      xml += '<contact_phone>' + stringValue(string.valueof(req.ContactPhone__c)) + '</contact_phone>';
      xml += '<contact_email>' + stringValue(req.contact_Email__c) + '</contact_email>';

      xml += '<device>' + stringValue(req.Device__c) + '</device>';
      xml += '<sla>' + stringValue(req.SLA__c) + '</sla>';
      xml += '<external_id>' + stringValue(req.External_Id__c) + '</external_id>';
      xml += '<external_system_name>' + stringValue(req.External_System_Name__c) + '</external_system_name>';
      xml += '<language>' + stringValue(req.Language__c) + '</language>';
      xml += '<intersection_id>' + stringValue(req.IntersectionID__c) + '</intersection_id>';

      xml += '<quadrant>' + stringValue(req.quadrant__c) + '</quadrant>';
      xml += '<ward>' + stringValue(req.ward__c) + '</ward>';
      xml += '<poldist>' + stringValue(req.District__c) + '</poldist>';
      xml += '<psa>' + stringValue(req.psa__c) + '</psa>';
      xml += '<anc>' + stringValue(req.anc__c) + '</anc>';
      xml += '<smd>' + stringValue(req.smd__c) + '</smd>';
      xml += '<cluster>' + stringValue(req.Neighbor_Hood_Cluster__c) + '</cluster>';
      xml += '<xcoord>' + stringValue(req.xcoord__c) + '</xcoord>';
      xml += '<ycoord>' + stringValue(req.ycoord__c) + '</ycoord>';

      xml += '<Servicing_agency_code>' + stringValue(req.Jurisdiction_Code__c) + '</Servicing_agency_code>';
      xml += '<Servicing_agency_description>' + stringValue(req.Jurisdiction_Description__c) + '</Servicing_agency_description>';

      //Check if Flexnotes are locked for this API user and send flex notes if NOT locked
      if (!apiKeyRes.flexNotesLocked) {
        //additional Flex Notes attributes              
        if (req.Flex_Note_Histories__r != null && req.Flex_Note_Histories__r.size() > 0) {
          xml += '<attributes>';
          for (Flex_Note_History__c f : req.Flex_Note_Histories__r) {
            if (!f.IsSecure__c) {
              xml += '<attribute>';
              xml += '<code>' + stringValue(f.FlexNote_Question__c) + '</code>';
              xml += '<question>' + stringValue(f.Questions__c) + '</question>';
              if (f.order__c != null) xml += '<order>' + stringValue(String.valueof(f.order__c)) + '</order>';
              else xml += '<order></order>';


              if (f.codedescription__c != null) {
                xml += '<values>';
                Map<String, String> code_map = (Map<String, String>) JSON.deserialize(f.codedescription__c, Map<String, String>.class);
                for (String ans : code_map.keySet()) {
                  List<String> code_ans = ans.split(':');
                  xml += '<value>';
                  xml += '<answer>' + stringValue(ans) + '</answer>';
                  //xml+='<answer_name>'+ if(code_ans.size()>1) code_ans[1] else ''+'</answer_name>';
                  xml += '<answer_name>' + stringValue(code_map.get(ans)) + '</answer_name>';
                  xml += '</value>';
                }
                xml += '</values>';
              }
              xml += '</attribute>';
            }

          }
          xml += '</attributes>';
        }
      }

      //Activities or Tasks:
      //Check if Activities are locked for this API user and send flex notes if NOT locked
      if (!apiKeyRes.activitiesLocked) {
        //add attributes to the list
        if (req.OUC_Activity_Histories__r != null && req.OUC_Activity_Histories__r.size() > 0) {
          xml += '<tasks>';
          for (OUC_Activity_History__c t : req.OUC_Activity_Histories__r) {
            xml += '<task>';
            xml += '<task_code>' + stringValue(string.valueof(t.Task_Code__c)) + '</task_code>';
            xml += '<task_short_name>' + stringValue(string.valueof(t.Task_short_name__c)) + '</task_short_name>';
            xml += '<citizen_email_on_complete>' + stringValue(string.valueof(t.Citizen_Email_On_Complete__c)) + '</citizen_email_on_complete>';
            xml += '<internal_comments>' + stringValue(string.valueof(t.Description__c)) + '</internal_comments>';
            xml += '<external_comments>' + stringValue(string.valueof(t.external_comments__c)) + '</external_comments>';
            xml += '<outcome>' + stringValue(t.outcome__c) + '</outcome>';
            xml += '<order>' + stringValue(string.valueof(t.Display_Sort_order__c)) + '</order>';
            xml += '<completion_date>' + formatDate(t.completion_date__c).trim() + '</completion_date>';
            xml += '<status>' + stringValue(string.valueof(t.status__c)) + '</status>';
            xml += '<due_date>' + formatDate(t.Due_Date__c).trim() + '</due_date>';
            xml += '<responsible_party>' + stringValue(string.valueof(t.Responsible_Party__c)) + '</responsible_party>';
            xml += '</task>';
          }
          xml += '</tasks>';

        } //end tasks
      }

      if (req.Attachments != null && req.Attachments.size() > 0) {
        xml += '<attachments>';
        for (Attachment a : req.Attachments) {
          xml += '<attachment>';
          xml += '<name>' + stringValue(String.valueOf(a.Name)) + '</name>';
          xml += '<description>' + stringValue(String.valueOf(a.Description)) + '</description>';
          xml += '<content_type>' + stringValue(String.valueOf(a.ContentType)) + '</content_type>';
          xml += '</attachment>';
        }
        xml += '</attachments>';
      }
    }

    xml += '</request>';
    return xml;
  }

  public static String sendJSONResponse(List<Case> requests, APIValidations.APIKeyResponse apiKeyRes) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartArray();
    for (Case req : requests) {
      jsonHelper(gen, req, apiKeyRes);
    }
    gen.writeEndArray();
    return gen.getAsString();
  }

  private static void jsonHelper(JSONGenerator gen, Case req, APIValidations.APIKeyResponse apiKeyRes) {
    gen.writeStartObject();
    gen.writeStringField('service_request_id', stringValue(req.service_request_number__c));
    gen.writeStringField('status', req.isclosed ? 'closed' : 'open');
    gen.writeStringField('status_notes', '');
    gen.writeStringField('service_name', stringValue(req.srtype__r.service_name__c));
    gen.writeStringField('service_code', stringValue(req.srtype__r.name));
    gen.writeStringField('description', stringValue(req.description));

    gen.writeStringField('agency_responsible', stringValue(req.AgencyCode__c));
    gen.writeStringField('service_notice', stringValue(req.reason));

    gen.writeStringField('requested_datetime', formatDate(req.CreatedDate).trim());
    gen.writeStringField('updated_datetime', formatDate(req.Last_Update_Date__c).trim());
    gen.writeStringField('expected_datetime', formatDate(req.Expected_Resolution_Date__c).trim());

    gen.writeStringField('address', stringValue(req.Address__c));
    gen.writeStringField('address_id', stringValue(req.AddressID__c));
    gen.writeStringField('zipcode', req.Zipcode__c != null ? stringValue(String.valueof(req.Zipcode__c)) : '');
    gen.writeStringField('lat', stringValue(string.valueof(req.geolocation__latitude__s)));
    gen.writeStringField('long', stringValue(string.valueof(req.geolocation__longitude__s)));
    gen.writeStringField('media_url', stringValue(req.media_url__c));

    if (apiKeyRes.isPrivate && (String.isNotBlank(apiKeyRes.httpMethod) && apiKeyRes.getSRTypesToQueryForHttpMethod(apiKeyRes.httpMethod).contains(req.srtype__r.name))) {

      //additional expanded attributes
      gen.writeStringField('full_status', stringValue(req.Status));
      gen.writeStringField('priority', stringValue(req.Priority));
      gen.writeStringField('origin', stringValue(req.Origin));
      gen.writeStringField('contact_last_name', stringValue(req.Contact.lastname));
      gen.writeStringField('contact_first_name', stringValue(req.Contact.firstname));
      gen.writeStringField('contact_phone', stringValue(string.valueof(req.Contact.Phone)));
      gen.writeStringField('contact_email', stringValue(string.valueof(req.Contact.Email)));
      gen.writeStringField('device', stringValue(req.Device__c));

      gen.writeStringField('sla', stringValue(req.SLA__c));
      gen.writeStringField('external_id', stringValue(req.External_Id__c));
      gen.writeStringField('external_system_name', stringValue(req.External_System_Name__c));
      gen.writeStringField('language', stringValue(req.Language__c));
      gen.writeStringField('intersection_id', stringValue(req.IntersectionID__c));
      gen.writeStringField('quadrant', stringValue(req.Quadrant__c));
      gen.writeStringField('ward', stringValue(req.Ward__c));
      gen.writeStringField('poldist', stringValue(req.PolDistrict__c));
      gen.writeStringField('psa', stringValue(req.PSA__c));
      gen.writeStringField('anc', stringValue(req.ANC__c));
      gen.writeStringField('smd', stringValue(req.SMD__c));
      gen.writeStringField('cluster', stringValue(req.Cluster__c));
      gen.writeStringField('xcoord', stringValue(req.XCOORD__c));
      gen.writeStringField('ycoord', stringValue(req.YCOORD__c));

      gen.writeStringField('Servicing_agency_code', stringValue(req.SRType_Jurisdiction__r.Jurisdiction__r.Name));
      gen.writeStringField('Servicing_agency_description', stringValue(req.SRType_Jurisdiction__r.Jurisdiction__r.Department__c));

      //Check if Flexnotes are locked for this API user and send flex notes if NOT locked
      if (!apiKeyRes.flexNotesLocked) {
        //additional Flex Notes attributes 
        if (req.FlexNotes__r != null && req.FlexNotes__r.size() > 0) {
          gen.writeFieldName('attributes');
          gen.writeStartArray();
          for (FlexNote__c f : req.FlexNotes__r) {

            gen.writeStartObject();
            //put in the attribute fields
            gen.writeStringField('code', stringValue(string.valueof(f.FlexNote_question__r.Name)));
            gen.writeStringField('question', stringValue(string.valueof(f.FlexNote_question__r.Questions__c)));
            gen.writeStringField('order', f.order__c != null ? stringValue(String.valueof(f.order__c)) : '');

            if (f.codedescription__c != null) {
              gen.writeFieldName('values'); gen.writeStartArray();
              Map<String, String> code_map = (Map<String, String>) JSON.deserialize(f.codedescription__c, Map<String, String>.class);
              for (String ans : code_map.keySet()) {
                gen.writeStartObject();
                List<String> code_ans = ans.split(':');
                gen.writeFieldName('value'); gen.writeStartArray(); gen.writeStartObject();
                // answer fields need to be split into a collection for multi-select picklists
                gen.writeStringField('answer', stringValue(ans));
                // answer_name needs to be retrieved from code-decode where applicable
                gen.writeStringField('answer_name', stringValue(code_map.get(ans)));
                gen.writeEndObject(); gen.writeEndArray();
                gen.writeEndObject();
              }
              gen.writeEndArray();
            }
            gen.writeEndObject();
          }
          gen.writeEndArray();
        }

      }


      //Activities or Tasks:
      //Check if Activities are locked for this API user and send flex notes if NOT locked
      if (!apiKeyRes.activitiesLocked) {
        //add attributes to the list
        if (req.OUC_Activities__r != null && req.OUC_Activities__r.size() > 0) {
          gen.writeFieldName('tasks');
          gen.writeStartArray();
          for (OUC_Activity__c t : req.OUC_Activities__r) {
            gen.writeStartObject();
            //put in the task fields
            gen.writeStringField('task_code', stringValue(string.valueof(t.Task_Code__c)));
            gen.writeStringField('task_short_name', stringValue(string.valueof(t.Task_short_name__c)));
            gen.writeStringField('citizen_email_on_complete', stringValue(string.valueof(t.Citizen_Email_On_Complete__c)));
            gen.writeStringField('internal_comments', stringValue(string.valueof(t.Description__c)));
            gen.writeStringField('external_comments', stringValue(string.valueof(t.external_comments__c)));
            gen.writeStringField('outcome', stringValue(string.valueof(t.outcome__c)));
            gen.writeStringField('order', stringValue(string.valueof(t.Display_Sort_order__c)));
            gen.writeStringField('completion_date', formatDate(t.completion_date__c).trim());
            gen.writeStringField('status', stringValue(string.valueof(t.Status__c)));
            gen.writeStringField('due_date', formatDate(t.Due_Date__c).trim());
            gen.writeStringField('responsible_party', stringValue(string.valueof(t.Responsible_Party__c)));

            gen.writeEndObject();
          }
          gen.writeEndArray();
        }
      }

      if (req.Attachments != null && req.Attachments.size() > 0) {
        gen.writeFieldName('attachments');
        gen.writeStartArray();
        for (Attachment a : req.Attachments) {
          gen.writeStartObject();
          gen.writeStringField('name', stringValue(String.valueOf(a.Name)));
          gen.writeStringField('description', stringValue(String.valueOf(a.Description)));
          gen.writeStringField('content_type', stringValue(String.valueOf(a.ContentType)));
          gen.writeEndObject();
        }
        gen.writeEndArray();
      }
    }
    gen.writeEndObject();
  }

  public static String sendJSONResponse(Case req, APIValidations.APIKeyResponse apiKeyRes) {
    JSONGenerator gen = JSON.createGenerator(true);
    jsonHelper(gen, req, apiKeyRes);
    return gen.getAsString();
  }

  public static String sendXMLResponse(List<Case> requests, APIValidations.APIKeyResponse apiKeyRes) {
    //Dom.Document doc = new Dom.Document();
    //Dom.Xmlnode rootNode = doc.createRootElement('service_requests', null, null); 
    String xml = '<?xml version="1.0" encoding="UTF-8"?><service_requests>';
    for (Case req : requests) {
      //xmlHelper(rootNode,req,isPrivate);
      xml += xmlHelper(req, apiKeyRes);
    }

    xml += '</service_requests>';
    return xml;
    //return doc.toXMLString();
  }

  public static String sendXMLResponse(Case req, APIValidations.APIKeyResponse apiKeyRes) {
    //Dom.Document doc = new Dom.Document();
    //Dom.Xmlnode rootNode = doc.createRootElement('service_requests', null, null); 
    //xmlHelper(rootNode,req,isPrivate);
    String xml = '<?xml version="1.0" encoding="UTF-8"?><service_requests>';
    xml += xmlHelper(req, apiKeyRes);
    xml += '</service_requests>';
    return xml;
    //return doc.toXMLString();
  }

  private static string xmlHelper(Case req, APIValidations.APIKeyResponse apiKeyRes) {
    System.debug('----> Inside xmlHelper(Case req,Boolean isPrivate) => 2');
    String xml = '';
    xml += '<request>';
    xml += '<service_request_id>' + stringValue(req.service_request_number__c) + '</service_request_id>';
    xml += '<status>' + stringValue(req.isclosed ? 'closed' : 'open') + '</status>';
    xml += '<status_notes></status_notes>';
    xml += '<service_name>' + stringValue(req.srtype__r.service_name__c) + '</service_name>';
    xml += '<service_code>' + stringValue(req.srtype__r.name) + '</service_code>';
    xml += '<description>' + stringValue(req.description) + '</description>';
    xml += '<agency_responsible>' + stringValue(req.AgencyCode__c) + '</agency_responsible>';
    xml += '<service_notice>' + stringValue(req.reason) + '</service_notice>';
    xml += '<requested_datetime>' + formatDate(req.CreatedDate).trim() + '</requested_datetime>';
    xml += '<updated_datetime>' + formatDate(req.Last_Update_Date__c).trim() + '</updated_datetime>';
    xml += '<expected_datetime>' + formatDate(req.Expected_Resolution_Date__c).trim() + '</expected_datetime>';

    xml += '<address>' + stringValue(req.address__c) + '</address>';
    xml += '<address_id>' + stringValue(req.addressid__c) + '</address_id>';
    if (req.Zipcode__c != null) {
      System.debug('----> Zipcode is not null');
      xml += '<zipcode>' + stringValue(String.valueof(req.Zipcode__c)) + '</zipcode>';
    } else {
      System.debug('----> Zipcode is null');
      xml += '<zipcode></zipcode>';
    }
    xml += '<lat>' + stringValue(string.valueof(req.geolocation__latitude__s)) + '</lat>';
    xml += '<long>' + stringValue(string.valueof(req.geolocation__longitude__s)) + '</long>';

    xml += '<media_url>' + stringValue(req.media_url__c) + '</media_url>';

    if (apiKeyRes.isPrivate && (String.isNotBlank(apiKeyRes.httpMethod) && apiKeyRes.getSRTypesToQueryForHttpMethod(apiKeyRes.httpMethod).contains(req.srtype__r.name))) {
      //additional expanded attributes
      xml += '<full_status>' + stringValue(req.Status) + '</full_status>';
      xml += '<priority>' + stringValue(req.Priority) + '</priority>';
      xml += '<origin>' + stringValue(req.Origin) + '</origin>';
      xml += '<contact_last_name>' + stringValue(req.Contact.lastname) + '</contact_last_name>';
      xml += '<contact_first_name>' + stringValue(req.Contact.firstname) + '</contact_first_name>';
      xml += '<contact_phone>' + stringValue(string.valueof(req.Contact.Phone)) + '</contact_phone>';
      xml += '<contact_email>' + stringValue(req.Contact.email) + '</contact_email>';

      xml += '<device>' + stringValue(req.Device__c) + '</device>';
      xml += '<sla>' + stringValue(req.SLA__c) + '</sla>';
      xml += '<external_id>' + stringValue(req.External_Id__c) + '</external_id>';
      xml += '<external_system_name>' + stringValue(req.External_System_Name__c) + '</external_system_name>';
      xml += '<language>' + stringValue(req.Language__c) + '</language>';
      xml += '<intersection_id>' + stringValue(req.IntersectionID__c) + '</intersection_id>';

      xml += '<quadrant>' + stringValue(req.quadrant__c) + '</quadrant>';
      xml += '<ward>' + stringValue(req.ward__c) + '</ward>';
      xml += '<poldist>' + stringValue(req.PolDistrict__c) + '</poldist>';
      xml += '<psa>' + stringValue(req.psa__c) + '</psa>';
      xml += '<anc>' + stringValue(req.anc__c) + '</anc>';
      xml += '<smd>' + stringValue(req.smd__c) + '</smd>';
      xml += '<cluster>' + stringValue(req.cluster__c) + '</cluster>';
      xml += '<xcoord>' + stringValue(req.xcoord__c) + '</xcoord>';
      xml += '<ycoord>' + stringValue(req.ycoord__c) + '</ycoord>';

      xml += '<Servicing_agency_code>' + stringValue(req.SRType_Jurisdiction__r.Jurisdiction__r.Name) + '</Servicing_agency_code>';
      xml += '<Servicing_agency_description>' + stringValue(req.SRType_Jurisdiction__r.Jurisdiction__r.Department__c) + '</Servicing_agency_description>';

      //Check if Flexnotes are locked for this API user and send flex notes if NOT locked
      if (!apiKeyRes.flexNotesLocked) {
        //additional Flex Notes attributes              
        if (req.FlexNotes__r != null && req.FlexNotes__r.size() > 0) {
          xml += '<attributes>';
          for (FlexNote__c f : req.FlexNotes__r) {
            xml += '<attribute>';
            xml += '<code>' + stringValue(f.FlexNote_question__r.Name) + '</code>';
            xml += '<question>' + stringValue(f.FlexNote_question__r.Questions__c) + '</question>';
            if (f.order__c != null) xml += '<order>' + stringValue(String.valueof(f.order__c)) + '</order>';
            else xml += '<order></order>';


            if (f.codedescription__c != null) {
              xml += '<values>';
              Map<String, String> code_map = (Map<String, String>) JSON.deserialize(f.codedescription__c, Map<String, String>.class);
              for (String ans : code_map.keySet()) {
                List<String> code_ans = ans.split(':');
                xml += '<value>';
                xml += '<answer>' + stringValue(ans) + '</answer>';
                //xml+='<answer_name>'+ if(code_ans.size()>1) code_ans[1] else ''+'</answer_name>';
                xml += '<answer_name>' + stringValue(code_map.get(ans)) + '</answer_name>';
                xml += '</value>';
              }
              xml += '</values>';
            }
            xml += '</attribute>';
          }
          xml += '</attributes>';
        }

      }

      //Activities or Tasks:
      //Check if Activities are locked for this API user and send flex notes if NOT locked
      if (!apiKeyRes.activitiesLocked) {
        //add attributes to the list
        if (req.OUC_Activities__r != null && req.OUC_Activities__r.size() > 0) {
          xml += '<tasks>';
          for (OUC_Activity__c t : req.OUC_Activities__r) {
            xml += '<task>';
            xml += '<task_code>' + stringValue(string.valueof(t.Task_Code__c)) + '</task_code>';
            xml += '<task_short_name>' + stringValue(string.valueof(t.Task_short_name__c)) + '</task_short_name>';
            xml += '<citizen_email_on_complete>' + stringValue(string.valueof(t.Citizen_Email_On_Complete__c)) + '</citizen_email_on_complete>';
            xml += '<internal_comments>' + stringValue(string.valueof(t.Description__c)) + '</internal_comments>';
            xml += '<external_comments>' + stringValue(string.valueof(t.external_comments__c)) + '</external_comments>';
            xml += '<outcome>' + stringValue(t.outcome__c) + '</outcome>';
            xml += '<order>' + stringValue(string.valueof(t.Display_Sort_order__c)) + '</order>';
            xml += '<completion_date>' + formatDate(t.completion_date__c).trim() + '</completion_date>';
            xml += '<status>' + stringValue(string.valueof(t.status__c)) + '</status>';
            xml += '<due_date>' + formatDate(t.Due_Date__c).trim() + '</due_date>';
            xml += '<responsible_party>' + stringValue(string.valueof(t.Responsible_Party__c)) + '</responsible_party>';
            xml += '</task>';
          }
          xml += '</tasks>';

        } //end tasks
      }

      if (req.Attachments != null && req.Attachments.size() > 0) {
        xml += '<attachments>';
        for (Attachment a : req.Attachments) {
          xml += '<attachment>';
          xml += '<name>' + stringValue(String.valueOf(a.Name)) + '</name>';
          xml += '<description>' + stringValue(String.valueOf(a.Description)) + '</description>';
          xml += '<content_type>' + stringValue(String.valueOf(a.ContentType)) + '</content_type>';
          xml += '</attachment>';
        }
        xml += '</attachments>';
      }
    }

    xml += '</request>';
    return xml;
  }

  public static string stringValue(String val) {
    if (val != null) {
      val = val.replace('&', '&amp;').replace('"', '&quot;').replace('\'', '&apos;').replace('<', '&lt;').replace('>', '&gt;');
    }
    return val == null ? '' : val;
  }

  public static String formatDate(Datetime dt) {
    return dt != null ? dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\' ') : '';
  }
}