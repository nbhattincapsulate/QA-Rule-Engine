public class CreateCaseEvents{

public static void CreateCaseEvent(Id CaseId,String Subject,DateTime ExpResDate)
{
    System.Debug('Inside CreateCaseEvent---->'+ CaseId + Subject + ExpResDate);
    List<Event> eventList = new List<Event>(); 
    set<Id> grpid = new set<Id>();  
    Map<Id, String> grpmemid = new Map<Id, String>();
    
    //Get Owner Id from Case
    String ownerId=[Select Id,ownerId from case where Id=: CaseId].ownerId;
    //create group Id list
    for(GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:ownerId]) {
        grpid.add(gm.UserOrGroupId);
        System.Debug('group Id List---->' + grpid);
        } 
        
    //Get User Id List
    if(grpid.size() >0){
    for(GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId in :grpid]){   
        grpmemid.put(m.Id, m.UserOrGroupId);
        System.Debug('Group or User Id---->'+ grpmemid);
        }   
    }
    
    //Create Event for each user Id
    for (ID mId: grpmemid.keySet()) { 
    System.debug('Value of GroupId----> ' + grpmemid);
    
    
    Event e     = new Event();
    e.Subject   = Subject;
    e.StartDateTime = system.now();               
    DateTime sDate = ExpResDate;         
    if(sDate <= system.now()+14) {
        e.EndDateTime   = sDate; 
        e.WhatId        = CaseId;
        e.ownerId       = grpmemid.get(mId);
        eventList.add(e);
        system.debug('If condition Date--->' + sDate+ + 'UserList----> '+ grpmemid.get(mId));   
    }
    else {
        e.EndDateTime   = system.now()+14; 
        e.WhatId        = CaseId;   
        e.ownerId       = grpmemid.get(mId);       
        system.debug('else Date--->' + sDate + 'e.whatId'+ e.WhatId + 'UserList----> '+ grpmemid.get(mId));            
        eventList.add(e);           
        }   
    }       
 if (!eventList.isEmpty()) {
    Database.insert(eventList);   
    system.debug('Insert List--->' + eventList);     
     }
  }  
}