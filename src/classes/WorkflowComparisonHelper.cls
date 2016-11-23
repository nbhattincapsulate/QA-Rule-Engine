public with sharing class WorkflowComparisonHelper {
		 /*
      STRING COMPARISONS
    */
    public static Boolean isValid(String value1 , String value2 ,String op ){
        
        if (value1!=null) value1 = value1 .trim();
        if (value2!=null) value2=   value2 .trim();   
       
        if(op.equalsIgnoreCase('Equals')){
            return ( value1 == value2 ) ? true : false;
            
        }
        if(op.equalsIgnoreCase('Not Equal To')){
            return ( value1 != value2 ) ? true : false;
             
        }      
                    
        if(op.equalsIgnoreCase('Contains'))
            return ( value1.contains(value2) ) ? true : false;
             
        if(op.equalsIgnoreCase('Does Not Contain'))
            return ( value1.contains(value2) ) ? false: true;
      
        if(op.equalsIgnoreCase('Is Null'))
             return String.isBlank(value1) ;
         
         if(op.equalsIgnoreCase('Is Not Null'))
             return String.isNotBlank(value1);    
      
        //updated SH : starts with & ends with to work with multiple values                   
            if(op.equalsIgnoreCase('Starts With')){
                Boolean result = false;
                for(String value : value2.split(',')){
                    result= value1.startsWith(value) || value1.startsWith('('+value) ? true:false;
                    if(result) break;
                }
                return result; 
                //return ( value1.startsWith(value2) ) ? true : false;                
            }
             
            if(op.equalsIgnoreCase('Ends With')){
                Boolean result = false;
                for(String value : value2.split(',')){
                    result= value1.endsWith(value)|| value1.startsWith(value+')') ? true:false;
                    if(result) break;
                }
                return result; 
                //return ( value1.endsWith(value2) ) ? true : false;  
            } 
        
       if(op.equalsIgnoreCase('Does Not Start With'))
             return ( value1.startsWith(value2) ) ? false: true;                
         
         if(op.equalsIgnoreCase('Does Not End With'))
             return ( value1.endsWith(value2) ) ? false: true;      
         
        if(op.equalsIgnoreCase('Regular Expression')){
            Matcher conMatcher = Pattern.compile(value2).matcher(value1);
            return conMatcher.matches();            
        }
        
        
         if(op.equalsIgnoreCase('includes')){
             Boolean result = false;
             for(String value : value2.split(',')){
             	   value = value.trim();
                    result= value1.equalsIgnoreCase(value);
                    if(result) break;
             }
             
             return result;  
         }
        
        if(op.equalsIgnoreCase('excludes') ){
             Boolean result = false;
             for(String value : value2.split(',')){
             	    value = value.trim();
                    result= value1.equalsIgnoreCase(value);
                    if(result) break;
             }
             return !result;
         } 
         return false;

    }
    
    /*
      DECIMAL/NUMBER COMPARISONS
    */
        public static Boolean isValid(Decimal value1 , Decimal value2 ,String op,WorkflowRuleCriteria__c cr ){
       
            if(op.equalsIgnoreCase('Equals'))
                return ( value1 == value2 ) ? true : false;
            
            if(op.equalsIgnoreCase('Not Equal To'))
                return ( value1 != value2 ) ? true : false;
            
            if(op.equalsIgnoreCase('Greater Than'))
                return ( value1 > value2 ) ? true : false;
             
            if(op.equalsIgnoreCase('Less Than'))
                return ( value1 < value2 ) ? true : false;
             
            if(op.equalsIgnoreCase('Greater or Equal'))
                return ( value1 >= value2 ) ? true : false;
                 
            if(op.equalsIgnoreCase('Less or Equal'))
                return ( value1 <= value2 ) ? true : false;
        
            if(op.equalsIgnoreCase('Is Null'))
                 return ( value1 == null) ? true : false;

             
             if(op.equalsIgnoreCase('Is Not Null'))
                 return ( value1 != null) ? true: false;      
                 
             if(op.equalsIgnoreCase('between')){
                Decimal min = decimal.valueOf(cr.Minimum_Value__c);
                Decimal max = decimal.valueOf(cr.Maximum_Value__c);
                return  (value1 >min && value1 < max) ? true:false;                 
             } 
             if(op.equalsIgnoreCase('Not Between')){
                Decimal min = decimal.valueOf(cr.Minimum_Value__c);
                Decimal max = decimal.valueOf(cr.Maximum_Value__c);
                return  (value1 < min || value1 > max) ? true:false;                 
             }  
             
               
            //other wise it is an invlaid operator on this datatype:-                   
            return false;
        }
        
         /*
      DATE COMPARISONS
    */
    public static Boolean isValid(Date value1 , Date value2 ,String op,WorkflowRuleCriteria__c cr ){
      
        if(op.equalsIgnoreCase('Equals'))
            return ( value1 == value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Not Equal To'))
            return ( value1 != value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater Than'))
            return ( value1 > value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Less Than'))
            return ( value1 < value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater or Equal'))
            return ( value1 >= value2 ) ? true : false;
             
        if(op.equalsIgnoreCase('Less or Equal'))
            return ( value1 <= value2 ) ? true : false;
             
        if(op.equalsIgnoreCase('between')){
            
            Date min = Date.parse(cr.Minimum_Value__c);
            Date max = Date.parse(cr.Maximum_Value__c);
             
            return  (value1 > min && value1 < max) ? true:false;                
        }    
        if(op.equalsIgnoreCase('Not Between')){
            
            Date min = Date.parse(cr.Minimum_Value__c);
            Date max = Date.parse(cr.Maximum_Value__c);
             
            return  (value1 < min || value1 > max) ? true:false;                
        }  
        
              
        //other wise it is an invlaid operator on this datatype:-                   
        return false;
    }
    
     /*
       DATETIME COMPARISONS
    */
    public static Boolean isValid(Datetime value1 , Datetime value2 ,String op,WorkflowRuleCriteria__c cr ){
     
        if(op.equalsIgnoreCase('Equals'))
            return ( value1 == value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Not Equal To'))
            return ( value1 != value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater Than'))
            return ( value1 > value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Less Than'))
            return ( value1 < value2 ) ? true : false;
        
        if(op.equalsIgnoreCase('Greater or Equal'))
            return ( value1 >= value2 ) ? true : false;
             
        if(op.equalsIgnoreCase('Less or Equal'))
            return ( value1 <= value2 ) ? true : false;
     
        if(op.equalsIgnoreCase('Is Null'))
             return ( value1 == null) ? true : false;
         
         if(op.equalsIgnoreCase('Is Not Null'))
             return ( value1 != null) ? true: false;              
     
        if(op.equalsIgnoreCase('between')){
            
            Datetime min = Datetime.parse(cr.Minimum_Value__c);
            Datetime max = Datetime.parse(cr.Maximum_Value__c);
            
            return  (value1 >min && value1<max) ? true:false;               
        } 
         if(op.equalsIgnoreCase('Not Between')){
            
            Datetime min = Datetime.parse(cr.Minimum_Value__c);
            Datetime max = Datetime.parse(cr.Maximum_Value__c);
            
            return  (value1 < min || value1 > max) ? true:false;               
        } 
         
             
        //other wise it is an invlaid operator on this datatype:-                   
        return false;
    }
    
	
}