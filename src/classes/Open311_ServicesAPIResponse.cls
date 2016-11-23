global  class Open311_ServicesAPIResponse {
	
	static map<string,string> datatype_map = new map<string,string>{'text'=>'string','multipicklist'=>'multivaluelist','picklist'=>'singlevaluelist','textarea'=>'text','integer'=>'number','date/time'=>'datetime', 'date'=> 'date'};
    
    public static String sendJSONResponse(ServiceRequestType__c obj,List<ServicesHelper.ServiceRequestTypeFlexNote> flexNotes){
          JSONGenerator gen = JSON.createGenerator(true);
          gen.writeStartObject();
          gen.writeStringField('service_code',obj.name);
          
          //add the attributes 
          gen.writeFieldName('attributes');            
               gen.writeStartArray();
               for(ServicesHelper.ServiceRequestTypeFlexNote elem:flexNotes){
               		ServiceRequestTypeFlexNote__c fn =elem.flexnote;
                    gen.writeStartObject();
                        gen.writeStringField('variable',!String.isEmpty(fn.FlexNote_Question__r.Answer_Type__c)?'true':'false');  
                        gen.writeStringField('code',stringValue(fn.FlexNote_Question__r.Name));  
                        string dt=fn.FlexNote_Question__c!=null && fn.FlexNote_Question__r.Answer_Type__c!=null ? datatype_map.get(fn.FlexNote_Question__r.Answer_Type__c.toLowerCase()):'';
                        gen.writeStringField('datatype',stringValue(dt));  
                        gen.writeStringField('required',stringValue(string.valueof(fn.IsRequiredQuestion__c)));  
                        gen.writeStringField('order',stringValue(string.valueof(fn.order__c)));  
                        gen.writeStringField('description',stringValue(fn.FlexNote_Question__r.Questions__c )); 
                        
                        if(fn.FlexNote_Question__r.AnswerValues__c!=null){
	                        gen.writeFieldName('values');  
	                        gen.writeStartArray();
	                        	List<String> valueList= new List<String>();
			               		if(elem.keyValueAns!=null){
			               			for(Decode_Object__c dc:elem.keyValueAns)
			               				valueList.add(dc.code__c+':'+dc.value__c);
			               		}
			               		
	                        	List<String> values = elem.keyValueAns!=null ? valueList:fn.FlexNote_Question__r.AnswerValues__c.split(',');
	                        	for(String val:values){
	                        		gen.writeStartObject();
	                        			gen.writeFieldName('value');gen.writeStartArray(); gen.writeStartObject();
			                                gen.writeStringField('key',!val.contains('{!')?val.split(':')[0]:'');  
			                                gen.writeStringField('name',val.split(':').size()>1 && !val.contains('{!')?val.split(':')[1]:'');  
	                            		gen.writeEndObject();gen.writeEndArray();
	                            	gen.writeEndObject();
	                        	}
	                          
	                        gen.writeEndArray();
                        }     
                    gen.writeEndObject();
               }
               gen.writeEndArray();
          gen.writeEndObject();
          return gen.getAsString();
    }
        
    public static String sendJSONResponse(List<ServiceRequestType__c> obj,Boolean isPrivate){

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(ServiceRequestType__c req:obj){
        	
        	if(req.Allow_Citizen_Web_Intake__c==false)
        		continue;
        		
            gen.writeStartObject();
                gen.writeStringField('service_code',stringValue(req.name));  
                gen.writeStringField('service_name',stringValue(req.External_Name__c));
                gen.writeStringField('agency',stringValue(req.Agency__c));
                gen.writeStringField('metadata',req.Flex_Note_Count__c>0?'true':'false');
                gen.writeStringField('description',stringValue(req.description__c));  
                gen.writeStringField('long_external_description',stringValue(req.LongExternalDescription__c));  
                gen.writeStringField('group',stringValue(req.group__c));   
                gen.writeStringField('keywords',stringValue(req.keywords__c));
                gen.writeStringField('external_name',stringValue(req.External_Name__c));
                gen.writeStringField('sla',stringValue(req.SLA__c));        
                gen.writeStringField('sla_type',stringValue(req.SLAType__c)); 
                gen.writeStringField('service_location_required',String.valueOf(req.ServiceLocationRequired__c));
                
            	/*if(isPrivate)
                {
                    gen.writeStringField('external_name',stringValue(req.External_Name__c));
                    gen.writeStringField('sla',stringValue(req.SLA__c));        
                    gen.writeStringField('sla_type',stringValue(req.SLAType__c)); 
                    gen.writeStringField('service_location_required',String.valueOf(req.ServiceLocationRequired__c)); 
                }*/
            gen.writeEndObject();
        }
        gen.writeEndArray();
        return gen.getAsString(); 
        
    }
    
    public static String sendXMLResponse(ServiceRequestType__c obj,List<ServicesHelper.ServiceRequestTypeFlexNote> flexNotes){
       	Dom.Document doc = new Dom.Document();
        Dom.Xmlnode rootNode = doc.createRootElement('service_definition', null, null); 
        Dom.Xmlnode reqNode = rootNode.addChildElement('service_code', null, null).addTextNode(stringValue(obj.name));
        Dom.Xmlnode attrNode = rootNode.addChildElement('attributes', null, null);
        for(ServicesHelper.ServiceRequestTypeFlexNote elem:flexNotes){
        	ServiceRequestTypeFlexNote__c fn =elem.flexnote;
        	Dom.Xmlnode  childNode = attrNode.addChildElement('attribute', null, null);
        	childNode.addChildElement('variable', null, null).addTextNode(!String.isEmpty(fn.FlexNote_Question__r.Answer_Type__c)?'true':'false');
        	childNode.addChildElement('code', null, null).addTextNode(stringValue(fn.FlexNote_Question__r.Name));
        	childNode.addChildElement('datatype', null, null).addTextNode(fn.FlexNote_Question__r.Answer_Type__c!=null? stringValue(datatype_map.get(fn.FlexNote_Question__r.Answer_Type__c.toLowerCase())):'');
        	childNode.addChildElement('required', null, null).addTextNode(stringValue(String.valueof(fn.IsRequiredQuestion__c)));
        	childNode.addChildElement('order', null, null).addTextNode(stringValue(String.valueof(fn.order__c)));
        	childNode.addChildElement('description', null, null).addTextNode(stringValue(fn.FlexNote_Question__r.Questions__c));
        	
        	if(fn.FlexNote_Question__r.AnswerValues__c!=null){
                	Dom.Xmlnode  valueNode = childNode.addChildElement('values', null, null);
               		List<String> valueList= new List<String>();
               		if(elem.keyValueAns!=null){
               			for(Decode_Object__c dc:elem.keyValueAns)
               				valueList.add(dc.code__c+':'+dc.value__c);
               		}
               		
                	List<String> values = elem.keyValueAns!=null ? valueList: fn.FlexNote_Question__r.AnswerValues__c.split(',');
                	for(String val:values){
                		Dom.Xmlnode valNode = valueNode.addChildElement('value', null, null);
                        valNode.addChildElement('key', null, null).addTextNode(!val.contains('{!')? val.split(':')[0]:'');   
                        valNode.addChildElement('name', null, null).addTextNode(val.split(':').size()>1 && !val.contains('{!') ?val.split(':')[1]:''); 
                           
                	}                                 
            }     
        
        
        }
        return doc.toXMLString();
    }
        
    public static String sendXMLResponse(List<ServiceRequestType__c> obj,Boolean isPrivate){
        Dom.Document doc = new Dom.Document();
        Dom.Xmlnode rootNode = doc.createRootElement('services', null, null); 
        
        for(ServiceRequestType__c req:obj){ 
            if(req.Allow_Citizen_Web_Intake__c==false)
        		continue;
            Dom.Xmlnode reqNode = rootNode.addChildElement('service', null, null);
            reqNode.addChildElement('service_code', null, null).addTextNode(req.name==null? '':req.name);
            reqNode.addChildElement('service_name', null, null).addTextNode(req.External_Name__c==null?'':req.External_Name__c);
            reqNode.addChildElement('description', null, null).addTextNode(req.description__c==null ?'':req.description__c); 
            reqNode.addChildElement('metadata', null, null).addTextNode(req.Flex_Note_Count__c>0?'true':'false');                   
            //reqNode.addChildElement('type', null, null).addTextNode(req.type__c==null?'':req.type__c); 
            reqNode.addChildElement('keywords', null, null).addTextNode(req.keywords__c!=null ? req.keywords__c:''); 
            reqNode.addChildElement('group', null, null).addTextNode(req.group__c==null?'':req.group__c);
            reqNode.addChildElement('external_name', null, null).addTextNode(req.External_Name__c==null? '':req.External_Name__c);
            reqNode.addChildElement('sla', null, null).addTextNode(req.SLA__c==null? '':req.SLA__c);
            reqNode.addChildElement('sla_type', null, null).addTextNode(req.SLAType__c==null? '':req.SLAType__c);
            reqNode.addChildElement('service_location_required', null, null).addTextNode(req.ServiceLocationRequired__c==true? 'true':'false');

            
            /*if(isPrivate)
                {
                    reqNode.addChildElement('external_name', null, null).addTextNode(req.External_Name__c==null? '':req.External_Name__c);
                    reqNode.addChildElement('sla', null, null).addTextNode(req.SLA__c==null? '':req.SLA__c);
                    reqNode.addChildElement('sla_type', null, null).addTextNode(req.SLAType__c==null? '':req.SLAType__c);
                    reqNode.addChildElement('service_location_required', null, null).addTextNode(req.ServiceLocationRequired__c==true? 'true':'false');
                }*/
        }           
        return doc.toXMLString();
    } 
    
    public static string stringValue(String val){
    	return val==null ? '':val;
    }
   
}