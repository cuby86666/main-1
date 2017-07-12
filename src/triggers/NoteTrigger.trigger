/*******************************************************************
Name           :    Note_afterInsertDelete
Created By     :    Jewelslyn Shama
Date           :    13 July 2015
Description    :    This Trigger is to count the number of Notes related to an Opportunity
******************************************************************************************/
trigger NoteTrigger on Note (after insert, after Update, after Delete, after unDelete) 
{
    Set<Id> opptyIds = new Set<Id>();
    List<Opportunity> listOpp = new List<Opportunity>();
    map<id,List<Note>> mapOppAttList=new map<id,List<Note>>();
    map<id,List<Note>> mapOppAttDelList=new map<id,List<Note>>();
    
    if(trigger.isDelete)
    {
        for(Note nt:trigger.old)
        {
            if(string.isNotBlank(nt.parentId))
            {
                string pId= nt.parentId;
                if(pId.startsWith('006'))
                {
                    if(!mapOppAttDelList.containskey(pId))
                    {
                        mapOppAttDelList.put(pId,new list<Note>());
                    }                                
                    mapOppAttDelList.get(pId).add(nt);
                    opptyIds.add(nt.parentId); 
                }
            }        
        }
   }
   else
    {
        for(Note nt:trigger.new)
        {
            if(string.isNotBlank(nt.parentId))
            {
                string pId=nt.parentId;
                if(pId.startsWith('006'))
                {
                    if(!mapOppAttList.containskey(pId))
                    {
                        mapOppAttList.put(pId,new list<Note>());
                    }                               
                    mapOppAttList.get(pId).add(nt);   
                    opptyIds.add(pId); 
                }
            }
        }
  }  
    
    if(opptyIds.size()>0)
    {
       listOpp=[Select id,numAtts__c from opportunity where Id IN:opptyIds];        
        for(Opportunity opp:listOpp)
        {
            if(mapOppAttList.containskey(opp.Id))
            {                
                opp.numAtts__c=opp.numAtts__c+mapOppAttList.get(opp.Id).size();
            }
             
            if(mapOppAttDelList.containskey(opp.Id))
            {                
                opp.numAtts__c=opp.numAtts__c-mapOppAttDelList.get(opp.Id).size();
            }            
        }        
        update listOpp;
    }
}