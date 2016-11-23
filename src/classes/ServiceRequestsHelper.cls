public class ServiceRequestsHelper {

  /**
   * Queries for the specified request by service request id(case id) and returns the corresponding
   * response object.
   *
   * @param id  request's id
   * @return    A response version of the matching request.
   *            If no records are found, it will simply error message saying invalid/not found
   */
  public static Case getRequest(String requestId) {

    string query = buildGetQueryRoot();
    query += 'WHERE Service_Request_Number__c =\'' + requestId + '\' ';
    System.debug('----> query: ' + query);
    List<Case> cases = database.query(query);
    System.debug('----> Number of Case Results: ' + cases.size());
    if (cases.size() == 0) {
      //invalid requestId code provided data could not be found
      throw new CustomException(APIConstants.NOT_FOUND);
    }
    return cases[0];

  }

  public static Case getRequest(Id requestId) {

    string query = buildGetQueryRoot();
    query += 'WHERE Id=\'' + requestId + '\' ';

    List<Case> cases = database.query(query);

    if (cases.size() == 0) {
      //invalid requestId code provided data could not be found
      throw new CustomException(APIConstants.NOT_FOUND);
    }
    return cases[0];

  }

  private static String buildGetQueryRoot() {
    string query = 'Select service_request_number__c, casenumber,status,description,Subject,AgencyCode__c,';
    query += 'SRType__r.Name,SRType__r.Service_Name__c,CreatedDate,LastModifiedDate,Service_Request_Name__c ,';
    query += 'Last_Update_Date__c,ClosedDate,IsClosed,Address__c,AddressID__c,geolocation__latitude__s,reason,';
    query += 'geolocation__longitude__s,media_url__c,Expected_Resolution_Date__c,Contact.firstname,Contact.lastname,';
    query += 'Contact.Phone,Contact.Email,Priority,Origin,Device__c,SLA__c,External_Id__c,External_System_Name__c,Language__c,';
    query += 'IntersectionId__c,Quadrant__c,Ward__c,PolDistrict__c,PSA__c,ANC__c,SMD__c,Cluster__c,XCOORD__c,YCOORD__c,Zipcode__c,';
    query += 'SRType_Jurisdiction__r.Jurisdiction__c,SRType_Jurisdiction__r.Jurisdiction__r.Department__c,Jurisdiction__c,';
    query += 'SRType_Jurisdiction__r.Jurisdiction__r.Name,';
    query += '(Select FlexNote_question__r.Name, questions__c,Order__c, flexNote_question__r.Questions__c, Answer__c, ';
    query += 'flexNote_question__r.Sequence_Number__c,FlexNote_question__r.Answer_Type__c,CodeDescription__c FROM FlexNotes__r ORDER BY Order__c, ID  ),';
    query += '(Select Id,Status__c,Task_Code__c,Task_Short_Name__c,Citizen_Email_On_Complete__c,';
    query += 'Description__c,external_comments__c,outcome__c,Display_Sort_order__c,completion_date__c,';
    query += 'Due_Date__c,Responsible_Party__c FROM OUC_Activities__r ORDER BY Display_Sort_Order__c ),';
    query += '(Select Id, Name, Description, ContentType FROM Attachments ORDER BY CreatedDate ASC )';
    query += 'FROM Case ';

    return query;

  }
  /**
   * Queries for the specified request by service request token and returns the corresponding
   * response object.
   *
   * @param id  request's token
   * @return    A response version of the matching request.
   *            If no records are found, it will simply error message saying invalid/not found
   */
  public static Case getRequestByToken(String requestToken) {

    List<Case> cases = [Select service_request_number__c, casenumber, status, description, Subject,
                        SRType__r.Name, SRType__r.Service_Name__c, CreatedDate,
                        LastModifiedDate, ClosedDate, Address__c, addressid__c, geolocation__latitude__s,
                        geolocation__longitude__s, media_url__c
                        FROM Case WHERE CaseNumber = :requestToken];


    if (cases.size() == 0) {
      //invalid request Id code provided data could not be found
      throw new CustomException(APIConstants.NOT_FOUND);
    }
    return cases[0];

  }

  /**
   * Queries for the specified contact by whom service request is(case id) created and returns the corresponding
   * response object.
   *
   * @param id  map with key first_name,last_name,phone,email
   * @return    A response version of the matching request.
   *            If no records are found, it will create a new contact
   */

  public static Contact createServiceRequestContact(Map<String, String> contactParams) {

    //check if the contact exist
    List<Contact> contact = [Select Id, Name, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingCountry, OtherPhone, Salutation FROM Contact
                             WHERE email = :contactParams.get('email') AND LastName = :contactParams.get('last_name')
                             ORDER BY CreatedDate DESC];
    System.debug('-----> Contact - Mailing Country: ' + contactParams.get('mailing_Country'));
    if (contact.size() > 0) {
      System.debug('----> Contact exists with email: ' + contactParams.get('email'));
      // ER:  Need to consider if provided email exists in multiple contacts 
      //      AND scenario where input information for first_name, Last_name, address, etc might be different from contact record
      //  
      contact[0].lastname = contactParams.get('last_name');
      contact[0].firstname = contactParams.get('first_name');
      contact[0].email = contactParams.get('email');
      contact[0].phone = contactParams.get('phone');
      contact[0].MailingStreet = contactParams.get('mailing_Street');
      contact[0].MailingCity = contactParams.get('mailing_City');
      contact[0].MailingState = contactParams.get('mailing_State');
      //contact[0].MailingCountry = contactParams.get('mailing_Country'); 
      contact[0].OtherPhone = contactParams.get('other_Phone');

      upsert contact[0];
      return contact[0];
    }

    //other wise create a contact:-
    Contact con = new Contact();
    con.lastname = contactParams.get('last_name');
    con.firstname = contactParams.get('first_name');
    con.email = contactParams.get('email');
    con.phone = contactParams.get('phone');

    // Included address
    con.MailingStreet = contactParams.get('mailing_Street');
    con.MailingCity = contactParams.get('mailing_City');
    con.MailingState = contactParams.get('mailing_State');
    con.MailingCountry = contactParams.get('mailing_Country');
    con.OtherPhone = contactParams.get('other_Phone');

    //create account for a contact
    Account acc = createPersonalAccount(contactParams);
    system.debug('accountList ----->' + acc);
    con.AccountId = acc.Id;

    insert con;

    return con;

  }

  /**
   * Queries for list of Requests records and and returns the corresponding
   * response object (list of Requests).  If any non-null parameters are
   * provided, the list will be filtered by the specified field.
   *
   * @param jurisdiction_id    Id of jurisdiction
   * @return              Collection of Requests objects, as an list
   */
  public static List<Case> listAllRequests(String filter) {
    /*String query =    'Select  casenumber,status,description,Subject,AgencyCode__c,';
      query+=' SRType__r.Name,SRType__r.Service_Name__c,CreatedDate,Priority,Origin,Contact.firstname,';
      query+=' Contact.lastname,Contact.Phone,Contact.Email,Last_Update_Date__c,ClosedDate,IsClosed,Address__c,AddressID__c,';                     
      query+=' geolocation__latitude__s,geolocation__longitude__s,media_url__c,Expected_Resolution_Date__c,Device__c,SLA__c,External_Id__c,';                  
      query+=' External_System_Name__c,Language__c,IntersectionId__c,';
      query+=' Quadrant__c,Ward__c,PolDistrict__c,PSA__c,ANC__c,SMD__c,Cluster__c,XCOORD__c,YCOORD__c,' ;
      query+=' (Select FlexNote_question__r.Name, questions__c, flexNote_question__r.Questions__c, Answer__c, ';
      query+=' flexNote_question__r.Sequence_Number__c,FlexNote_question__r.Answer_Type__c FROM FlexNotes__r ORDER BY Order__c, ID ),';
      query+=' (Select Id,Status__c,Task_Code__c,Task_Short_Name__c,Citizen_Email_On_Complete__c,';
      query+='Description__c,external_comments__c,outcome__c,Display_Sort_order__c,completion_date__c,';
      query+='Due_Date__c,Responsible_Party__c FROM OUC_Activities__r ORDER BY Display_Sort_Order__c )';
     
      query+=' FROM Case ';
     */
    string query = buildGetQueryRoot();

    //adding filter
    if (filter == null) {
      query += ' WHERE CreatedDate >= LAST_90_DAYS ';
    }

    if (filter != null) {
      query += ' WHERE ' + filter;
    }

    // ER:  order by needs to by Last_Update_Date__c ASC when Update_Date is passed to GET SERVCIES
    if (filter.containsIgnoreCase('Last_Update_Date__c'))
    query += ' ORDER BY Last_Update_Date__c ASC '; // LIMIT 1000  (need to evaluate if we need LIMIT on this - LIKELY we do)
    else
    query += ' ORDER BY CreatedDate DESC LIMIT 1000 ';
    system.debug('FILTER:' + filter);

    query += ' LIMIT 400';

    return database.query(query);

  }

  public static account createPersonalAccount(map<string, string> contParms) {
    list<account> account = [select id, name from account where name = :contParms.get('firstname') + ' ' + contParms.get('lastName')];
    if (account.size() > 0) return account[0];
    Account acc = new Account();
    acc.Name = contParms.get('firstname') + ' ' + contParms.get('lastname');
    insert acc;
    return acc;
  }

  /**
   * Queries for the specified BulkSchedule__c by whom service request's(Ward__C) and returns the corresponding
   * response object.
   * 
   *
   * @param     wrd  (Ward of ServiceRequest), configName (Custom Setting Record Name for daily Stop limit i.e DailyLimit)
   * @return    A response version of the matching request. 
   *            If no records are found, it will return empty sObject
   */


  public static sObject getFlexNoteDefault(String wrd, string configName) {
    sObject obj;
    Integer counter = 0;
    Integer numOfDays = Integer.valueof(OUCServiceRequestConfig__c.getValues(configName).NumberofDays__c);
    for (BulkSchedule__c bs :[Select Id, Name, ServiceRequestBulkScheduleCount__c, ScheduleDate__c, Ward__c from BulkSchedule__c Where ScheduleDate__c >= :System.today() AND Ward__c LIKE 'Ward%' Order By ScheduleDate__c ASC]) {
      if (counter > numOfDays && bs.Ward__c.contains(wrd)) {
        if (bs.ServiceRequestBulkScheduleCount__c < OUCServiceRequestConfig__c.getValues(configName).BulkScheduleDailyStopLimit__c && bs.ScheduleDate__c > system.today().addDays(numOfDays)) {
          system.debug('result---' + bs);
          obj = (sObject) bs;
          return obj;
        }
      }
      counter++;
    }

    if (obj == null) {
      // i needed check this later
      // throw new CustomException(APIConstants.NOT_FOUND);     
    }
    // if no record found ;
    //return (sObject) new BulkSchedule__c();  
    return null;
  }



  public static sObject getFlexNoteDefault(String Flexnote_Code) {
    //if(Flexnote_Code==Bulk Collection FlexNote){}
    list<BulkSchedule__c> bulkSchedule = [select id, ScheduleDate__c, Ward__c from BulkSchedule__c where ScheduleDate__c > :system.today() Order By ScheduleDate__c ASC limit 1];
    if (bulkSchedule.size() > 0) {
      sObject obj = (sObject) bulkSchedule[0];
      return obj;
    }

    //invalid request Id code provided data could not be found
    throw new CustomException(APIConstants.NOT_FOUND);
  }



  public static map<Id, String> getQuestionCodeAnswerMap(LIST<FlexNoteQuestion__c> fq) {
    map<Id, String> questionCodeAnswerValueMap = new map<Id, String> ();
    String answerValues;

    if (!fq.isEmpty()) {

      List<String> av = new List<String> ();
      for (FlexNoteQuestion__c f : fq) av.add(f.AnswerValues__c);

      list<Decode_Object__c> doc = [Select Id, Name, Code__c, Value__c from Decode_Object__c d where Name IN :av order By Name];
      map<String, List<Decode_Object__c>> decodeObjMap = new map<String, List<Decode_Object__c>> ();

      for (Decode_Object__c f : doc) {
        //decodeObjMap.put(f.Name,decodeObjMap.get(f.Name)==null? new List<Decode_Object__c>{f}:decodeObjMap.get(f.Name).add(f));
        if (decodeObjMap.containsKey(f.Name)) {
          decodeObjMap.get(f.Name).add(f);
        } /*else{
           decodeObjMap.put(f.Name,new list<Decode_Object__c>{f});
           }*/
      }

      for (FlexNoteQuestion__c f : fq) {
        // case 1
        // if flexnote question contains values 
        if (f.AnswerValues__c != null && f.AnswerValues__c.contains(',')) {
          answerValues = f.AnswerValues__c;
          answerValues = answerValues.replace(',', ';');
          system.debug('Log0 : answerValues1  ------------->' + answerValues);
          questionCodeAnswerValueMap.put(f.Id, answerValues);
        }
        // case 2
        // if flexnote question options values are coming from decode object
        if (f.AnswerValues__c != null && !(f.AnswerValues__c.contains(','))) {
          //answerValues = f.AnswerValues__c;                     
          if (decodeObjMap != null) {
            if (decodeObjMap.get(f.AnswerValues__c) != null) {
              for (Decode_Object__c d : decodeObjMap.get(f.AnswerValues__c)) {
                answerValues += d.Code__c + ':' + d.Value__c + ';';
                system.debug('Log0 : answerValues2  ------------->' + answerValues);
              }
            }
          }
          questionCodeAnswerValueMap.put(f.Id, answerValues);

        }
      }
    }

    return questionCodeAnswerValueMap;
  }

  public static void startFlexNoteProcess(list<FlexNote__c> listFlexNotes, list<FlexNoteQuestion__c> fnList) {
    //map<Id,FlexNoteQuestion__c>flexNoteQuestionMap=new map<Id,FlexNoteQuestion__c>([Select Questions__c, Object_Name__c, Name, Answer_Type__c, AnswerValues__c From FlexNoteQuestion__c  where  Id IN (Select FlexNote_Question__c From FlexNote__c where Id IN : listFlexNotes) ]);            
    map<Id, FlexNoteQuestion__c> flexNoteQuestionMap = new map<Id, FlexNoteQuestion__c> (fnList);
    map<string, list<Decode_Object__c>> decodeObjectMap = new map<string, list<Decode_Object__c>> ();
    list<STRING> listAnswerValue = new list<STRING> ();
    FOR (FlexNoteQuestion__c FN : flexNoteQuestionMap.Values()) {
      listAnswerValue.add(FN.AnswerValues__c);
    }

    list<Decode_Object__c> listDecodeObject = new list<Decode_Object__c> ([Select d.Value__c, d.Type__c, d.Short_Description__c, d.Order__c, d.Name, d.Code__c, d.Active__c From Decode_Object__c d where name IN :listAnswerValue]);

    for (Decode_Object__c f : listDecodeObject) {
      //if(decodeObjectMap.containsKey(f.Name) ? decodeObjectMap.get(f.Name).add(f):decodeObjectMap.put(f.Name,new list<Decode_Object__c>{f});
      if (decodeObjectMap.containsKey(f.Name)) {
        decodeObjectMap.get(f.Name).add(f);
      } else {
        decodeObjectMap.put(f.Name, new list<Decode_Object__c> { f });
      }

    }
    system.debug('listDecodeObject---' + decodeObjectMap);
    //invoke codedescription method
    setFlexNoteCodeDescriptionValues(listFlexNotes, flexNoteQuestionMap, decodeObjectMap);

  }

  private static void setFlexNoteCodeDescriptionValues(list<FlexNote__c> listFlexNotes, map<Id, FlexNoteQuestion__c> flexNoteQuestionMap, map<string, list<Decode_Object__c>> decodeObjectMap) {
    // updating code description based on flexnotequestion
    list<Decode_Object__c> decodedList = getDecodeList(decodeObjectMap);
    for (FlexNote__c oFlexNote : listFlexNotes) {
      FlexNoteQuestion__c fnQ = flexNoteQuestionMap.get(oFlexNote.FlexNote_Question__c);

      if (oFlexNote.Answer__c != null) {
        list<string> listAnswers = (oFlexNote.Answer__c != null && oFlexNote.Answer__c.contains(',')) ? oFlexNote.Answer__c.split(',') : new list<string> { oFlexNote.Answer__c };
        map<string, string> codeDescriptionMap = new map<string, string> ();
        string codeDescriptionValue = '';

        // holds code and description values to be converted to json format
        list<CodeDescriptionWrapper> codeDescriptionList = new List<CodeDescriptionWrapper> ();

        // holds code and description 
        map<string, string> codeDescriptionValueMap = new map<string, string> ();


        if (fnQ != null) {

          if (fnQ.AnswerValues__c != null) {
            if (fnQ.Answer_Type__c != null) {
              // datatype multipicklist processing 
              if (fnQ.Answer_Type__c == 'MultiPicklist') {
                if (fnQ.AnswerValues__c.contains(':')) {
                  //map<string,string>codeDescriptionMap=new map<string,string>();
                  list<string> answersOptionsList = (fnQ.AnswerValues__c != null && fnQ.AnswerValues__c.contains(',')) ? fnQ.AnswerValues__c.split(',') : new list<string> { fnQ.AnswerValues__c };
                  // creating map of code description 
                  for (string answerItems : answersOptionsList) {
                    if (answerItems.contains(':')) {
                      codeDescriptionMap.put(answerItems.split(':') [0], answerItems.split(':') [1]);
                    }
                  }
                  // iterating through questions answervalues and matching with answer from flexnotes
                  for (string cD : codeDescriptionMap.KeySet()) {
                    for (string ansItem : listAnswers) {
                      if (ansItem == cD) {
                        codeDescriptionValue += ansItem + ':' + codeDescriptionMap.get(ansItem) + ';';

                        codeDescriptionList.add(new CodeDescriptionWrapper(ansItem, codeDescriptionMap.get(ansItem)));
                        codeDescriptionValueMap.put(ansItem, codeDescriptionMap.get(ansItem));
                      }
                    }
                  }

                }
                else {
                  // iterating through decodeObjectMap ,checking whether it contains given question answervalues
                  if (decodeObjectMap.get(fnQ.AnswerValues__c) != null) {
                    if (decodeObjectMap.containsKey(fnQ.AnswerValues__c)) {
                      //list<string>listAnswers=if(oFlexNote.Answer__c!=null && oFlexNote.Answer__c.contains(',')) ? oFlexNote.Answer__c.split(',') : new list<string>{oFlexNote.Answer__c};

                      for (Decode_Object__c decodeObjectItem : decodedList) {
                        for (string lA : listAnswers) {
                          if (lA == decodeObjectItem.Code__c) {
                            codeDescriptionValue += decodeObjectItem.Code__c + ':' + decodeObjectItem.Value__c + ';';

                            codeDescriptionList.add(new CodeDescriptionWrapper(decodeObjectItem.Code__c, decodeObjectItem.Value__c));
                            codeDescriptionValueMap.put(decodeObjectItem.Code__c, decodeObjectItem.Value__c);
                          }
                        }
                      }
                    }
                  }
                  else {
                    ///if(oFlexNote.Answer__c!=null)codeDescriptionValue+=oFlexNote.Answer__c+';';
                    //
                    for (string lA : listAnswers) {
                      codeDescriptionValue += lA + ';';

                      codeDescriptionList.add(new CodeDescriptionWrapper('', lA));
                      codeDescriptionValueMap.put('', lA);
                    }
                  }
                }
              }

              // datatype picklist processing 
              if (fnQ.Answer_Type__c == 'Picklist') {
                if (fnQ.AnswerValues__c.contains(':')) {
                  //map<string,string>codeDescriptionMap=new map<string,string>();
                  list<string> answersOptionsList = (fnQ.AnswerValues__c != null && fnQ.AnswerValues__c.contains(',')) ? fnQ.AnswerValues__c.split(',') : new list<string> { fnQ.AnswerValues__c };
                  for (string answerItems : answersOptionsList) {
                    if (answerItems.contains(':')) {
                      codeDescriptionMap.put(answerItems.split(':') [0], answerItems.split(':') [1]);
                    }
                  }
                  for (string cD : codeDescriptionMap.KeySet()) {
                    for (string ansItem : listAnswers) {
                      if (ansItem == cD) {
                        codeDescriptionValue += ansItem + ':' + codeDescriptionMap.get(ansItem) + ';';

                        codeDescriptionList.add(new CodeDescriptionWrapper(ansItem, codeDescriptionMap.get(ansItem)));
                        codeDescriptionValueMap.put(ansItem, codeDescriptionMap.get(ansItem));
                      }
                    }
                  }

                } else {
                  // iterating through decodeObjectMap ,checking whether it contains given question answervalues
                  if (decodeObjectMap.get(fnQ.AnswerValues__c) != null) {
                    if (decodeObjectMap.containsKey(fnQ.AnswerValues__c)) {
                      //list<string>listAnswers=if(oFlexNote.Answer__c!=null && oFlexNote.Answer__c.contains(',')) ? oFlexNote.Answer__c.split(',') : new list<string>{oFlexNote.Answer__c};
                      for (Decode_Object__c decodeObjectItem : decodedList) {
                        for (string lA : listAnswers) {
                          if (lA == decodeObjectItem.Code__c) {
                            codeDescriptionValue += decodeObjectItem.Code__c + ':' + decodeObjectItem.Value__c + ';';

                            codeDescriptionList.add(new CodeDescriptionWrapper(decodeObjectItem.Code__c, decodeObjectItem.Value__c));
                            codeDescriptionValueMap.put(decodeObjectItem.Code__c, decodeObjectItem.Value__c);
                          }
                        }
                      }
                    }
                  }
                  else {
                    ///if(oFlexNote.Answer__c!=null)codeDescriptionValue+=oFlexNote.Answer__c+';';
                    for (string lA : listAnswers) {
                      codeDescriptionValue += lA + ';';
                      codeDescriptionList.add(new CodeDescriptionWrapper('', lA));
                      codeDescriptionValueMap.put(lA, lA);
                    }
                  }
                }
              }




            }
          }


          // processing other than multipicklist and picklist datatype 
          if (fnQ.Answer_Type__c != null && fnQ.Answer_Type__c != 'MultiPicklist' && fnQ.Answer_Type__c != 'Picklist') {

            if (fnQ.AnswerValues__c != '' && fnQ.Answer_Type__c == 'Text') {
              if (fnQ.AnswerValues__c == '{!Value}') {
                for (string lA : listAnswers) {
                  System.debug('----> AnswerValues__c == {!Value} && Type == Text: ' + lA);
                  String dateStr = '';
                  // Try to convert the current answer into a date object. If it's not castable then sent the current string.    
                  try {
                    dateStr = String.valueOf(Date.parse(lA));
                    System.debug('----> dateStr: ' + dateStr);
                  } catch(TypeException e) {
                    dateStr = String.valueOf(lA);
                    System.debug('----> Type Exception. Use default value instead: ' + lA);
                  }
                  codeDescriptionValueMap.put(dateStr, dateStr);
                }
              }
            }

            if (fnQ.Answer_Type__c == 'Date/Time') {
              for (string lA : listAnswers) {
                try {
                  codeDescriptionValueMap.put(String.valueOfGmt(DateTime.parse(lA)), String.valueOfGmt(DateTime.parse(lA)));
                } catch(TypeException e) {
                  Map<String, Integer> monthMap = new Map<String, Integer> {
                    'Jan' => 1, 'January' => 1,
                    'Feb' => 2, 'February' => 2,
                    'Mar' => 3, 'March' => 3,
                    'Apr' => 4, 'April' => 4,
                    'May' => 5,
                    'Jun' => 6, 'June' => 6,
                    'Jul' => 7, 'July' => 7,
                    'Aug' => 8, 'August' => 8,
                    'Sept' => 9, 'September' => 9,
                    'Oct' => 10, 'October' => 10,
                    'Nov' => 11, 'November' => 11,
                    'Dec' => 12, 'December' => 12
                  };
                  // Type error means the date string could contain the timezone.
                  String[] breakDate = lA.split(' ');
                  if (lA.contains('-') && breakDate.size() >= 6) {
                    // Add and formate the date into US format.
                    String datetimeStr = monthMap.get(breakDate[1]) + '/' + breakDate[2] + '/' + breakDate[3] + ' ';
                    // Add the time.  
                    String timeStr = breakDate[4];
                    if (timeStr.contains(':')) {
                      List<String> breakTime = timeStr.split(':');
                      Integer hours = Integer.valueOf(breakTime.get(0));
                      // If there are seconds on the time string then remove them. Use the full string otherwise.
                      if (breakTime.size() >= 3) {
                        datetimeStr += (hours > 12 ? (String.valueOf(hours - 12)) : breakTime.get(0));
                        datetimeStr += ':' + breakTime.get(1);  
                      } else {
                        datetimeStr += timeStr;
                      }
                      // Break the string to check for AM/PM.  
                      datetimeStr += ' ' + (hours >= 12 ? 'PM' : 'AM');
                    }
                    System.debug('----> Datetime: ' + datetimeStr);
                    codeDescriptionValueMap.put(String.valueOfGmt(DateTime.parse(datetimeStr)), String.valueOfGmt(DateTime.parse(datetimeStr)));
                  }
                } catch(Exception e) {
                  System.debug('----> An error has occured while trying to add a "Date/Time" datatype: ' + e.getMessage());
                }
              }
            }

            if (fnQ.Answer_Type__c == 'Date') {
              for (string lA : listAnswers) {
                   String datetimeStr = lA;
                   // Format the date into US format from ISO format
                   if (lA.contains('-')) {
                    String[] dateSplit = lA.split('-');
                    datetimeStr = dateSplit[1] + '/' + dateSplit[2] + '/' + dateSplit[0];
                   }
                codeDescriptionValueMap.put(String.valueOf(date.parse(datetimeStr)), String.valueOf(date.parse(datetimeStr)));
              }
            }

            if ((fnQ.Answer_Type__c == 'Text' && fnQ.AnswerValues__c != '{!Value}')) {
              for (string lA : listAnswers) {
                codeDescriptionValueMap.put(lA, lA);
              }
            }

            if ((fnQ.Answer_Type__c == 'TextArea')) {
              for (string lA : listAnswers) {
                codeDescriptionValueMap.put(lA, lA);
              }
            }

          }


        }


        String JSONString = JSON.serialize(codeDescriptionValueMap);
        //String JSONString = JSON.serialize(codeDescriptionList);
        System.debug('Serialized list of codeDescription into JSON format:-- ' + JSONString);
        oFlexNote.CodeDescription__c = JSONString;
        system.debug('codeDescription' + codeDescriptionValue);


        //if(codeDescriptionValue.endsWith(';'))codeDescriptionValue=codeDescriptionValue.substring(0,codeDescriptionValue.length()-1);
        //oFlexNote.CodeDescription__c=codeDescriptionValue;
      }
    }

  }

  private static list<Decode_Object__c> getDecodeList(map<string, list<Decode_Object__c>> decodeObjectMap) {
    list<Decode_Object__c> tempDecodeObjectList = new list<Decode_Object__c> ();
    for (string decodeName : decodeObjectMap.keySet()) {
      tempDecodeObjectList.addAll(decodeObjectMap.get(decodeName));
    }
    return tempDecodeObjectList;
  }

  // No time to refactor - moving common Business Days methods betweeen Case & SR/OUC Acitivities
  // Get appropriate Business Hours
  private static Id getBusinessHoursID() {
    // Calculation needs specific BusinessHours record specified in customSettings
    Id retval;
    list<BusinessHours> lbh = [Select b.Id, b.Name From BusinessHours b where Name = :OUCServiceRequestConfig__c.getValues('DailyLimit').DefaultBusinesshoursName__c and isActive = true];
    if (!lbh.isEmpty()) {
      retval = lbh[0].Id;
    }
    return retval;
  }
  private static DateTime CalculateBusinessDaysDueDateTime(ID BusinessHoursId, DateTime StartDateTime, long SLADays) {
    DateTime SLADateTime = BusinessHours.nextStartDate(BusinessHoursId, StartDateTime);
    long busDaysAs8HourMilliseconds = (SLADays * 8 * 3600 * 1000);
    SLADateTime = BusinessHours.addGMT(BusinessHoursid, SLADateTime, busDaysAs8HourMilliseconds);

    return SLADateTime;
  }

  // getting next business day based on sla and created date - called currently only from Case beforeInsert beforeUpdate trigger
  public static void setExceptedBussinessDateTime(list<case> tempCaseList, list<ServiceRequestType__c> serviceTypeList, boolean Trigger_IsInsert) {
    // Assumes the Bussines work hours are the default for the Org
    // check whether its customer communtiy login license if not proceed,update expected bussines resolution dates

    //list<BusinessHours> stdBusinessHourslist = [Select b.Name, b.Id From BusinessHours b where Name=:OUCServiceRequestConfig__c.getValues('DailyLimit').DefaultBusinesshoursName__c and isActive = true];
    Id stdBusinessHoursId = getBusinessHoursId();

    if (stdBusinessHoursId == null) return;
    map<id, ServiceRequestType__c> serviceTypeMap = new map<id, ServiceRequestType__c> (serviceTypeList);
    for (case cs : tempCaseList) {
      // Update the value for all Inserts - and for updates where the case was not previously Closed (this is before Update logic)
      if ((cs.CreatedDate != NULL) && (stdBusinessHoursId != NULL) && (Trigger_IsInsert || !cs.IsClosed)) {
        string sla;

        // Copy SLA in days into Case.SLA__c if
        if (cs.SLA__c == null) {
          if (serviceTypeMap.get(cs.SRType__c) != null) {
            if (serviceTypeMap.get(cs.SRType__c).SLA__c != null) {
              sla = serviceTypeMap.get(cs.SRType__c).SLA__c;
            }
          }
        }
        else {
          sla = cs.SLA__c;
        }

        if (sla != null) {
          cs.ExpectedBusinessResolutionDate__c = CalculateBusinessDaysDueDateTime(stdBusinessHoursId, cs.CreatedDate, long.ValueOf(sla));
          system.debug('c.ExpectedBusinessResolutionDate__c-->' + cs.ExpectedBusinessResolutionDate__c);
        }
      }
    }
  }

  // Calculate SLA on SR Activity - used only from beforeInsert beforeUpdate trigger
  public static void setSRActivityDueDate(list<OUC_Activity__c> tempActList, boolean Trigger_IsInsert) {
    // Leverages business hour & business day rules from CASE/SR
    // check whether its customer communtiy login license if not proceed,update expected bussines resolution dates

    Id stdBusinessHoursId = getBusinessHoursId();

    // if we don't get any (ie community login) - just exit
    if (stdBusinessHoursId == null) return;

    for (OUC_Activity__c act : tempActList) {
      datetime createddate = act.CreatedDate;
      if (createddate == null) createddate = datetime.now();

      // Update the value for all Inserts - and for updates where the case was not closed and activity is not completed
      if ((createddate != NULL) && (stdBusinessHoursId != NULL) && (Trigger_IsInsert || act.Status__c != 'Completed')) {
        string sla, slaType;
        datetime newDueDate;

        // formula field in OUC_Activity has all logic
        sla = act.Due_Date_SLA__c;
        slaType = act.Due_Date_SLA_Type__c;

        if (sla != null && slaType != null) {
          if (slaType.equalsignorecase('business days'))
          newDueDate = CalculateBusinessDaysDueDateTime(stdBusinessHoursId, createddate, long.ValueOf(sla));
          else if (slaType.equalsignorecase('calendar days')) {
            newDueDate = createddate.addDays(integer.valueOf(sla));
          }
        }
        act.Due_Date_Internal__c = newDueDate;
        system.debug('act.Due_Date_Internal__c-->' + act.Due_Date_Internal__c);
      }
    }
  }
    
  /**
   * getDuplicateServiceRequestsBase
   * 
   * This function will be the base functionality of fetching the duplicate SR's.
   * @author Darkis
   * @modifed 25 July 2016
   */
  public static List<Case> getDuplicateServiceRequestsBase(String srAddress, ServiceRequestType__c serviceType, Decimal sRLongitude, Decimal sRLatitude, Boolean excludeClosedCases) {
    System.debug('----> [getDuplicateServiceRequests] getDuplicateServiceRequestsBase: Start');
    List<Case> serviceRequestList = new List<Case> ();  
      
    try {
      if (serviceType.DuplicateDetectionMethod__c != 'Standard' || serviceType.DuplicateRadius__c == null) {
        return new list<case> ();
      }
        
      String queryStr = buildQueryRoot();
      //filter logic 
      queryStr += ' Where';
	  // If the closed cases are to be excluded add it to the query.
      if (excludeClosedCases) {
        queryStr += ' IsClosed=false AND';
      }
      queryStr += ' SRType__r.Service_Name__c =\'' + serviceType.Service_Name__c + '\' ';
      // Get the duplicate list.  
      serviceRequestList = ServiceRequestsHelper.duplicateServiceRequestProcessing(queryStr, serviceType, srAddress, sRLongitude, sRLatitude);
    } catch(exception e) {
      system.debug('----> [getDuplicateServiceRequests] Unable to complete query process due: ' + e);
    }
    System.debug('----> [getDuplicateServiceRequests] getDuplicateServiceRequestsBase: Exit');
    return serviceRequestList;    
  }

  // fetching potential duplicate service request based on mar details and service type 
  public static list<case> getDuplicateServiceRequests(string srAddress, String ServiceTypeName, decimal sRLongitude, decimal sRLatitude) {
    System.debug('----> [getDuplicateServiceRequests] getDuplicateServiceRequests: Start');
      
    List<Case> serviceRequestList = new List<Case> ();
      
    System.debug('----> [getDuplicateServiceRequests] srAddress: ' + srAddress);
    System.debug('----> [getDuplicateServiceRequests] sRLongitude: ' + sRLongitude);
    System.debug('----> [getDuplicateServiceRequests] sRLatitude: ' + sRLatitude);
      
    try {
      // String param so obtain the service type from the DB.
      ServiceRequestType__c serviceType = getServiceType(ServiceTypeName);
      System.debug('----> [getDuplicateServiceRequests] ServiceType: ' + serviceType);
      System.debug('----> [getDuplicateServiceRequests] serviceType.DuplicateRadius__c: ' + serviceType.DuplicateRadius__c);
      System.debug('----> [getDuplicateServiceRequests] serviceType.Duplicate_Threshold_Period__c: ' + serviceType.Duplicate_Threshold_Period__c);
      //System.debug('----> [getDuplicateServiceRequests] ServiceType\'s with DuplicateRadius: ' + [Select Id, Service_Name__c From ServiceRequestType__c Where DuplicateRadius__c != null]);
      // Call the base function.
	  serviceRequestList = getDuplicateServiceRequestsBase(srAddress, serviceType, sRLongitude, sRLatitude, true);
    } catch(exception e) {
      system.debug('----> [getDuplicateServiceRequests] Unable to complete query process due: ' + e);
    }
    System.debug('----> [getDuplicateServiceRequests] getDuplicateServiceRequests: Exit');
    return serviceRequestList;
  }
  
  public static List<Case> getDuplicateServiceRequests(String srAddress, String ServiceTypeName, Decimal sRLongitude, Decimal sRLatitude, boolean excludeClosedCases) {
    System.debug('----> [getDuplicateServiceRequests] getDuplicateServiceRequests: Start');
      
    List<Case> serviceRequestList = new List<Case>();
      
    System.debug('----> [getDuplicateServiceRequests] srAddress: ' + srAddress);
    System.debug('----> [getDuplicateServiceRequests] sRLongitude: ' + sRLongitude);
    System.debug('----> [getDuplicateServiceRequests] sRLatitude: ' + sRLatitude);  
      
    try {
      ServiceRequestType__c serviceType = getServiceType(ServiceTypeName);
      System.debug('----> [getDuplicateServiceRequests] ServiceType: ' + serviceType);
      System.debug('----> [getDuplicateServiceRequests] serviceType.DuplicateRadius__c: ' + serviceType.DuplicateRadius__c);
      System.debug('----> [getDuplicateServiceRequests] serviceType.Duplicate_Threshold_Period__c: ' + serviceType.Duplicate_Threshold_Period__c);
      //System.debug('----> [getDuplicateServiceRequests] ServiceType\'s with DuplicateRadius: ' + [Select Id, Service_Name__c From ServiceRequestType__c Where DuplicateRadius__c != null]);
        
      serviceRequestList = getDuplicateServiceRequestsBase(srAddress, serviceType, sRLongitude, sRLatitude, excludeClosedCases);
    } catch(exception e) {
      system.debug('----> [getDuplicateServiceRequests] Unable to complete query process due: ' + e);
    }
    System.debug('----> [getDuplicateServiceRequests] getDuplicateServiceRequests: Exit');
    return serviceRequestList;
  }
    
  public static list<case> getDuplicateServiceRequests(string srAddress, ServiceRequestType__c serviceType, decimal sRLongitude, decimal sRLatitude) {
    System.debug('----> [getDuplicateServiceRequests] getDuplicateServiceRequests: Start');
    List<Case> serviceRequestList = new List<Case> ();
      
    System.debug('----> [getDuplicateServiceRequests] srAddress: ' + srAddress);
    System.debug('----> [getDuplicateServiceRequests] sRLongitude: ' + sRLongitude);
    System.debug('----> [getDuplicateServiceRequests] sRLatitude: ' + sRLatitude);
    System.debug('----> [getDuplicateServiceRequests] ServiceType: ' + serviceType);
    System.debug('----> [getDuplicateServiceRequests] serviceType.DuplicateRadius__c: ' + serviceType.DuplicateRadius__c);
    System.debug('----> [getDuplicateServiceRequests] serviceType.Duplicate_Threshold_Period__c: ' + serviceType.Duplicate_Threshold_Period__c);
    //System.debug('----> [getDuplicateServiceRequests] ServiceType\'s with DuplicateRadius: ' + [Select Id, Service_Name__c From ServiceRequestType__c Where DuplicateRadius__c != null]);
      
    try {
      // Call the base function.
	  serviceRequestList = getDuplicateServiceRequestsBase(srAddress, serviceType, sRLongitude, sRLatitude, true);
    } catch(exception e) {
      system.debug('----> [getDuplicateServiceRequests] Unable to complete query process due: ' + e);
    }
    System.debug('----> [getDuplicateServiceRequests] getDuplicateServiceRequests: Exit');
    return serviceRequestList;
  }

  private static List<Case> duplicateServiceRequestProcessing(String queryStr, ServiceRequestType__c serviceType, String srAddress, Decimal sRLongitude, Decimal sRLatitude) {
    List<Case> serviceRequestList = new List<Case> ();
    try {
      if (serviceType.DuplicateDetectionMethod__c != 'Standard' || serviceType.DuplicateRadius__c == null) {
        return new list<case> ();
      }
        
      if (serviceType.DuplicateRadius__c != null && (sRLatitude == null || sRLongitude == null)) {
        return new list<case> ();      
      }

      if (sRLatitude != null && sRLongitude != null && serviceType.DuplicateRadius__c != null) {
        // 1 mile  = 0.000189394 *foot
        decimal limitRadius = (serviceType.DuplicateRadius__c * 0.000189394);
        system.debug('----> [duplicateServiceRequestProcessing] radius: ' + limitRadius);
        queryStr += 'And ( DISTANCE(GeoLocation__c, GEOLOCATION(' + String.valueOf(sRLatitude) + ',' + String.valueOf(sRLongitude) + '),' + '\'mi' + '\') <' + limitRadius + ') ';
      }

      if (serviceType.Duplicate_Threshold_Period__c != null) {
        //SR?s, Case.createddate >= Todays Date - Threshold Days.
        String sDTTM;
        DateTime DTTM = DateTime.newInstance(Date.today().addDays(- integer.valueof(serviceType.Duplicate_Threshold_Period__c)), Time.newInstance(0, 0, 0, 0));
        sDTTM = DTTM.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';
        queryStr += 'And CreatedDate >= ' + sDTTM;
      }

      queryStr += ' order by CreatedDate DESC LIMIT 50';

      if (serviceType.DuplicateRadius__c == null && serviceType.Duplicate_Threshold_Period__c == null) {
        return new list<case> ();
      }

      system.debug('----> [duplicateServiceRequestProcessing] queryresults: ' + queryStr);
      serviceRequestList = database.query(queryStr);
    }
    catch(exception e) {
      system.debug('----> [duplicateServiceRequestProcessing] Unable to complete query process due: ' + e);
    }
    return serviceRequestList;
  }

  // building query string 
  private static string buildQueryRoot() {
    string query = 'Select c.Status,c.Service_Request_Number__c, c.CaseNumber, c.address__c,c.SRType__r.Duplicate_Threshold_Period__c, c.SRType__r.DuplicateRadius__c, c.SRType__r.Service_Name__c, c.SRType__c, c.IsClosed, c.Case_Closure_Comment__c,';
    query += 'c.GeoLocation__c, c.GeoLocation__Longitude__s, c.GeoLocation__Latitude__s, c.CreatedDate,c.SRType__r.DuplicateDetectionMethod__c From Case c';
    return query;
  }

  // retrieve service request type based on service name
  private static ServiceRequestType__c getServiceType(String serviceName) {
    List<ServiceRequestType__c> srtypes = [Select Id, Name, Service_Name__c, Flex_Note_Count__c, External_Description__c, Flex_Notes_Link_Indicator__c, group__c, keywords__c, description__c, Agency__c, SLA__c, DuplicateDetectionMethod__c, Duplicate_Threshold_Period__c, DuplicateRadius__c FROM ServiceRequestType__c where Service_Name__c = :serviceName LIMIT 1];
    system.debug('srtypes-->' + srtypes);
    if (srtypes.isEmpty()) {
      //invalid service code provided data could not be found
      throw new CustomException(APIConstants.NOT_FOUND);
    }
    return srtypes[0];
  }

  // wrapper class used for serialize and deserialize codedescription
  public class CodeDescriptionWrapper {
    string code;
    string description;

    public CodeDescriptionWrapper(string code, string description) {
      this.code = code;
      this.description = description;
    }
  }
    
  /**
   * getDuplicateServiceRequestsBase
   * 
   * This function will be the base functionality of fetching the duplicate SR's.
   * @author Darkis
   * @modifed 27 July 2016
   * @param List<Case> cases The list of cases from the trigger itself to be processed. 
   * @param Map<Id, ServiceRequestType__c> serviceRequestTypeMap A mapping of the SRTypes to allow easy access to type data without unnecessary queries.
   * @param Boolean excludeClosedCases A boolean flag to force the inclusion of closed cases.
   */
  public static String generateDuplicateServiceRequestQuery(List<Case> cases, Map<Id, ServiceRequestType__c> serviceRequestTypeMap, Boolean excludeClosedCases) {
    System.debug('----> [generateDuplicateServiceRequestQuery] Start');
    String queryStr = '';
      
    try {  
      queryStr = buildQueryRoot();
      //filter logic 
      queryStr += ' Where';
	  // If the closed cases are to be excluded add it to the query.
      if (excludeClosedCases) {
        queryStr += ' IsClosed=false';
      }
        
      if (cases.size() > 0) {
        Integer counter = 0;  
        
        queryStr += ' AND (';   
        // Loop through trigger cases.  
        for (Case dupCase : cases) {
          // If the case is indeed closed then generate it's specific query handler. 
          if (dupCase.IsClosed) {
            ServiceRequestType__c srType = serviceRequestTypeMap.containsKey(dupCase.SRType__c) ? serviceRequestTypeMap.get(dupCase.SRType__c) : null;
			// If the SR Type is not null then generate the case specific query statement to add to the overall query.
            if (srType != null) {
              queryStr += generateDuplicatePersonalCaseQueryStr(dupCase, serviceRequestTypeMap);
              // If we have more cases to process add an OR statement to ensure retrival of ALL cases. 
              if (cases.size() != (counter + 1)) {
                queryStr += ' OR';
              }  
            }
          }
          counter++;
        } 
        queryStr += ')';
      }
      // If no cases closed and thus don't require duplicate checking, return an empty string.  
      if (queryStr.contains('AND ()')) {
        return '';      
      }  
      // Order the results bt created date and limit it to a 250 maximum.
      queryStr += ' ORDER BY CreatedDate DESC';
      queryStr += ' LIMIT 250';    
    } catch(exception e) {
      system.debug('----> [generateDuplicateServiceRequestQuery] Unable to complete query process due: ' + e);
    }
    System.debug('----> [generateDuplicateServiceRequestQuery] Exit');
    return queryStr;    
  }
    
  /**
   * generateDuplicatePersonalCaseQueryStr
   * 
   * This function will create a case specific query statement for the collection of duplicates pretaining to this case.
   * @author Darkis
   * @modified 27 Jul 2016
   * @param Case c The case object that requires a duplicate check.
   * @param Map<Id, ServiceRequestType__c> serviceRequestTypeMap A mapping of the SRTypes to allow easy access to type data without unnecessary queries. 
   */
  public static String generateDuplicatePersonalCaseQueryStr(Case c, Map<Id, ServiceRequestType__c> serviceRequestTypeMap) {
    String queryStr = '';
    ServiceRequestType__c serviceType = serviceRequestTypeMap.get(c.SRType__c);  
            
    queryStr += ' (';       
    queryStr += ' SRType__r.Service_Name__c =\'' + serviceType.Service_Name__c + '\' ';
    // If the detection method is not standard or null then return blank.              
    if (serviceType.DuplicateDetectionMethod__c != 'Standard' || serviceType.DuplicateRadius__c == null) {
      return '';
    }
    // If the duplicate radius, lat, or long are not available then return blank.
    if (serviceType.DuplicateRadius__c != null && (c.GeoLocation__Latitude__s == null || c.GeoLocation__Longitude__s == null)) {
      return '';       
    }
	// If all three are available then get the distance quotionant to add to the query.
    if (c.GeoLocation__Latitude__s != null && c.GeoLocation__Longitude__s != null && serviceType.DuplicateRadius__c != null) {
      // 1 mile  = 0.000189394 *foot
      decimal limitRadius = (serviceType.DuplicateRadius__c * 0.000189394);
      queryStr += 'And ( DISTANCE(GeoLocation__c, GEOLOCATION(' + String.valueOf(c.GeoLocation__Latitude__s) + ',' + String.valueOf(c.GeoLocation__Longitude__s) + '),' + '\'mi' + '\') <' + limitRadius + ') ';
    }
	// If there is a date threshold then add it.
    if (serviceType.Duplicate_Threshold_Period__c != null) {
      // NOTE: SR's, Case.createddate >= Todays Date - Threshold Days.
      String sDTTM;
      DateTime DTTM = DateTime.newInstance(Date.today().addDays(- integer.valueof(serviceType.Duplicate_Threshold_Period__c)), Time.newInstance(0, 0, 0, 0));
      sDTTM = DTTM.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';
      queryStr += 'And CreatedDate >= ' + sDTTM;
    }
    // If both the duplicate radius and threshold are null return blank.
    if (serviceType.DuplicateRadius__c == null && serviceType.Duplicate_Threshold_Period__c == null) {
      return '';
    }    
              
    queryStr += ')';        
    return queryStr;
  }
    
  /**
   * HandleDuplicateClosures
   * 
   * This function will handle any duplicate closures necessary for the passed in Case list from the trigger.
   * @author Darkis
   * @modified 27 Jul 2016
   * @param List<Case> caseList A list of cases from the trigger to have duplicates searched for and closed. 
   * @param Boolean isUpdate Is this an update request or Insert.
   */
  public static void HandleDuplicateClosures(List<Case> caseList, boolean isUpdate) {
    if (isUpdate) {
      // On an update of a case check if it's a duplicate or original.
      if (caseList != null && caseList.size() > 0) {
        // Find all the service types for the current case list.
        Set<Id> srTypeIdList = new Set<Id>();
        List<Case> combinedDuplicateUpdateCaseList = new List<Case>();
        // Create a list of SRType Ids.  
        for (Case c : caseList) {
          if (!srTypeIdList.contains(c.SRType__c) && c.IsClosed) {
            srTypeIdList.add(c.SRType__c);    
          }
        }  
        // Fetch all relavent SRTypes and convert into a useful mapping.
        List<ServiceRequestType__c> srTypes = [Select Id, Name, Service_Name__c, Flex_Note_Count__c, External_Description__c, Flex_Notes_Link_Indicator__c, group__c, keywords__c, description__c, Agency__c, SLA__c, DuplicateDetectionMethod__c, Duplicate_Threshold_Period__c, DuplicateRadius__c From ServiceRequestType__c Where Id IN :srTypeIdList];
        Map<Id, ServiceRequestType__c> srTypesMap = new Map<Id, ServiceRequestType__c>(srTypes);
        // Build the query containing all SR's related to the complete list of cases incoming from the trigger.
        String queryStr = generateDuplicateServiceRequestQuery(caseList, srTypesMap, true);
        // Fetch the duplicates.
        List<Case> srDuplicateList = String.isNotBlank(queryStr) ? database.query(queryStr) : new List<Case>();  
        // If the duplicate list contains SR's to process.  
        if (srDuplicateList.size() > 0) {
          // Loop through case list to check for duplicates.   
          for (Case c : caseList) {
            Location baseCaseLocation = Location.newInstance(c.GeoLocation__Latitude__s, c.GeoLocation__Longitude__s);
            // Loop through the newly found duplicate cases.
            for (Case duplicateCase : srDuplicateList) {
              Location queriedCaseLocation = Location.newInstance(duplicateCase.GeoLocation__Latitude__s, duplicateCase.GeoLocation__Longitude__s);  
              Double distBetween = Location.getDistance(queriedCaseLocation, baseCaseLocation, 'mi'); 
              // Fetch the SR type from the mapping.  
              ServiceRequestType__c srType = srTypesMap.get(duplicateCase.SRType__c); 
              // Find the limit radius of the SR Type.
              Decimal limitRadius = (srType.DuplicateRadius__c * 0.000189394);  
              // Verify if this case is indeed a duplicate case to the currently itterated case.      
              if (duplicateCase.SRType__c == c.SRType__c && distBetween < limitRadius && duplicateCase.Status == 'Duplicate (Opened)') {
                // Modify the duplicate case to be closed.
                duplicateCase.Status = 'Duplicate (Closed)';
                duplicateCase.Reason = c.Reason;
                duplicateCase.Case_Closure_Comment__c = c.Case_Closure_Comment__c;
                // If the combined duplicated update list contains elements.    
                if (combinedDuplicateUpdateCaseList.size() > 0) {
                  Boolean isPrepped = false; 
                  // Loop through the existing update list and validate that this case isn't already prepped to update. 
                  for (Case combineCase : combinedDuplicateUpdateCaseList) {
                    if (combineCase.Id == duplicateCase.Id) {
                      isPrepped = true;  
                      break;
                    }    
                  }
                  // If the case has not been added to the update list then add it.
                  if (!isPrepped) { 
                    combinedDuplicateUpdateCaseList.add(duplicateCase);        
                  }
                } else {
                  // If this is the first item for the list then add it.
                  combinedDuplicateUpdateCaseList.add(duplicateCase);  
                }
              }
            }    
          }
        }
        update combinedDuplicateUpdateCaseList;
      }
    }
  }

  /**
  * getDuplicateServiceRequestsByRelation
  *
  * @description This function will accept a case id and give the user a list of duplicate service requests based on the assigned parent id.
  * @author Darkis
  * @param CaseId The case ID that we wish to get duplicates for. 
  * @return List<Case> A list of the duplicates for the case ID provided.
  */
  public static List<Case> getDuplicateServiceRequestsByRelation(String CaseId) {
    List<Case> tempDuplicateCaseList = new List<Case>();
    // If the case id is not blank then continue.
    if (String.isNotBlank(CaseId)) {
      // Query all the cases with the parent id of the given case id. 
      tempDuplicateCaseList = [Select c.Status,c.Service_Request_Number__c, c.CaseNumber, c.address__c,c.SRType__r.Duplicate_Threshold_Period__c, c.SRType__r.DuplicateRadius__c, c.SRType__r.Service_Name__c, c.SRType__c, c.IsClosed, c.Case_Closure_Comment__c, c.GeoLocation__c, c.GeoLocation__Longitude__s, c.GeoLocation__Latitude__s, c.CreatedDate,c.SRType__r.DuplicateDetectionMethod__c From Case c Where ParentId = :CaseId];
    }
    return tempDuplicateCaseList;
  }

  /**
  * @Overide
  * getDuplicateServiceRequestsByRelation
  *
  * @description This function will accept a list of case ids and give the user a list of duplicate service requests based on the assigned parent id.
  * @author Darkis
  * @param CaseIds A list of case IDs that we wish to get duplicates for. 
  * @return List<Case> A list of the duplicates for the case IDs provided.
  */
  public static Map<String, List<Case>> getDuplicateServiceRequestsByRelation(Set<String> CaseIds) {
    Map<String, List<Case>> tempDuplicateCaseMap = new Map<String, List<Case>>();
    // If the ids set provided is not null and contains at least one id.
    if (CaseIds != null && CaseIds.size() > 0) {
      // Go grab all the duplicate cases for all the id's provided.
      List<Case> tempAllDuplicateCases = [Select c.Status,c.Service_Request_Number__c, c.CaseNumber, c.address__c,c.SRType__r.Duplicate_Threshold_Period__c, c.SRType__r.DuplicateRadius__c, c.SRType__r.Service_Name__c, c.SRType__c, c.IsClosed, c.Case_Closure_Comment__c, c.GeoLocation__c, c.GeoLocation__Longitude__s, c.GeoLocation__Latitude__s, c.CreatedDate,c.SRType__r.DuplicateDetectionMethod__c From Case c Where ParentId IN :CaseIds];
      // Loop through the duplicate cases.
      for (Case c : tempAllDuplicateCases) {
        // If the current mapping has a key of the current parent then add to the list of cases. If not then create a new entry and then add to the list.
        if (tempDuplicateCaseMap.containsKey(c.ParentId)) {
          tempDuplicateCaseMap.get(c.ParentId).add(c);
        } else {
          tempDuplicateCaseMap.put(c.ParentId, new List<Case>());
          tempDuplicateCaseMap.get(c.ParentId).add(c);
        }
      }
    }
    return tempDuplicateCaseMap;
  }
    
    /**
   * upsertSRBulkSchedule
   *
   * @author Darkis
   * @description This function will upsert any bulk schedule SR's with the correct schedule date. 
   * @param caseRrd 
   */
  public static void upsertSRBulkSchedule(Map<Date, BulkSchedule__c> bulkScheduleMap, Case caseRrd) {
    List<ServiceRequestBulkSchedule__c> serviceBulkScheduleToUpsert = new List<ServiceRequestBulkSchedule__c> ();
    for (Date bSItem : bulkScheduleMap.keySet()) {
      if (isValidBulkScheduleDate(bSItem, caseRrd.Ward__c)) return;

      ServiceRequestBulkSchedule__c sRBS = new ServiceRequestBulkSchedule__c();
      sRBS.BulkSchedule__c = bulkScheduleMap.get(bSItem).Id;
      sRBS.ServiceRequest__c = caseRrd.Id;
      sRBS.SRBulkScheduleExtId__c = sRBS.BulkSchedule__c + '-' + sRBS.ServiceRequest__c;
      sRBS.Status__c = 'Open';
      serviceBulkScheduleToUpsert.add(sRBS);
    }

    try {
      if (!serviceBulkScheduleToUpsert.isEmpty()) upsert serviceBulkScheduleToUpsert SRBulkScheduleExtId__c;
    } catch(exception e) {
      system.debug('unable to complete Process of Upsert of servicerequestbulkschedule due--' + e);
      throw new CustomException(e); // custom Exception message added
    }
  }

  /**
   * isValidBulkScheduleDate
   *
   * @author Darkis
   * @description This function will determine the given schedule date and ward have a valid bulk schedule date. 
   * @param scheduleDate The prepared scheduled date for processing.
   * @param Ward The designated ward. 
   * @return Boolean 
   */
  public static Boolean isValidBulkScheduleDate(Date scheduleDate, String Ward) {
    for (BulkSchedule__c bs :[Select id, Name, ServiceRequestBulkScheduleCount__c, ScheduleDate__c, Ward__c from BulkSchedule__c where ScheduleDate__c = :scheduleDate Order By ScheduleDate__c ASC limit 1]) {
      if (bs.Ward__c.contains(Ward)) {
        if (bs.ServiceRequestBulkScheduleCount__c > = OUCServiceRequestConfig__c.getValues('DailyLimit').BulkScheduleDailyStopLimit__c) {
          throw new CustomException('DailyStopLimit for bulk schedule has been crossed');
          return true;
        }
      }
    }
    return false;
  }
}