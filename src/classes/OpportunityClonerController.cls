// 2015-08-28 by Rex: remove 90 day flag update, keep spun off opportunity CreatedDate value 
// 
public class OpportunityClonerController {
    public boolean cloneStatus {get; set;}
    public String errorMessage {get; set;}
    public String newOpptyName {get; set;}
    public String MSG_USER_NOTIFY {get; set;}
    public String MSG_USER_CONFIRM {get; set;}
    
    public String OpptyId { get; set; }
    public Opportunity parentOppty {get; set;}
    public List<OpportunityLineItem> spinOffOLIs {get; set;}
    //public Opportunity parentOppty {get; set;}
    public List<OpportunityLineItem> parentOLIs {get; set;}

    Map<String, Oppty_Spin_Off_Msg__c> OpptySpinOffMsg;
    
    public void init() {
        //get messages from custom settings
        OpptySpinOffMsg = Oppty_Spin_Off_Msg__c.getAll();
        MSG_USER_NOTIFY = OpptySpinOffMsg.get('MSG_USER_NOTIFY').Value__c;
        MSG_USER_CONFIRM = OpptySpinOffMsg.get('MSG_USER_CONFIRM').Value__c;
        cloneStatus = true;
        OpptyId = ApexPages.currentPage().getParameters().get('id');
        if (OpptyId == null) {
            cloneStatus = false;
            //errorMessage = 'Please press spin off button from opportunity page.';//MSG_NO_OPPTY_ID
            errorMessage = OpptySpinOffMsg.get('MSG_NO_OPPTY_ID').Value__c;
            return;
        }
        
        try {
            parentOppty = 
                [Select Id, Name,Legacy_Id__c, Spin_Off_Opportunity__c, Design_Win_Approval_Process__c, RecordType.Name,
                 (Select Id, Product2.Name, MAG__c, Product_Active_Flags__c, UnitPrice, Component_Multiplier__c, Claim_Value_USD__c, Spin_Off__c
                  from OpportunityLineItems) from opportunity where Id =: OpptyId];
            List<OpportunityLineItem> currentOLIs = parentOppty.getSObjects('OpportunityLineItems');
            spinOffOLIs = new List<OpportunityLineItem>();
            parentOLIs = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : currentOLIs) {
                if (oli.Spin_Off__c)
                    spinOffOLIs.add(oli); //spin off products
                else
                    parentOLIs.add(oli); //existed products
            }
        } catch(Exception ex) {
            cloneStatus = false;
            //errorMessage = 'Please press spin off button from opportunity page.';//MSG_NO_VALID_OPPTY
            errorMessage = OpptySpinOffMsg.get('MSG_NO_VALID_OPPTY').Value__c;
            return;
        }
        
        newOpptyName = parentOppty.Name;
        //originalOLIs = spinOffOppty.getSObjects('OpportunityLineItems');
        if (spinOffOLIs == null || spinOffOLIs.size() == 0) {
            cloneStatus = false;
            //errorMessage = 'No selected products. Please select spin off products from opportunity page.';//MSG_NO_SELEDTED_PRODUCT
            errorMessage = OpptySpinOffMsg.get('MSG_NO_SELEDTED_PRODUCT').Value__c;
            return;
        }
        
        //parentOLIs = parentOppty.getSObjects('OpportunityLineItems');        
        if (parentOLIs == null || parentOLIs.size() == 0) {
            cloneStatus = false;
            //errorMessage = 'No existed products. Please select spin off products from opportunity page.';//MSG_NO_EXISTED_PRODUCT
            errorMessage = OpptySpinOffMsg.get('MSG_NO_EXISTED_PRODUCT').Value__c;
            return;
        }
        
        if (parentOppty.Design_Win_Approval_Process__c != 'Open') {
            cloneStatus = false;
            //errorMessage = 'Only open opportunity can be spun off.';//MSG_NON_OPEN_OPPTY
            errorMessage = OpptySpinOffMsg.get('MSG_NON_OPEN_OPPTY').Value__c;
            return;            
        }
    }
    
    public PageReference doSpinOff() {
        try {
            List<sObject> parentSObjects = new List<sObject>{(sObject)parentOppty};
            //clone opportunity
            List<sObject> clonedOpptySObjects = cloneObjects(parentSObjects, parentOppty.getsObjectType());
            List<Opportunity> updatedOpptys = new List<Opportunity>();
            //set is_spin_off checkbox
            parentOppty.Is_Spin_Off__c = true;
            update parentOppty;
            //cast SObject to Opportunity
            Opportunity clonedOppty = (Opportunity)clonedOpptySObjects.get(0);
            //update spin off oppty
            clonedOppty.Name = newOpptyName;
            clonedOppty.Is_Spin_Off__c = true;
            
            //Modified as Part of SIR 1178
            if(parentOppty.Legacy_Id__c !=null)
            {                 
                clonedOppty.Legacy_Id__c=null;                
            }
            
            //if parent oppty is a spun off oppty, set spin off oppty with the same Spin_Off_Opportunity__c
            if (parentOppty.Spin_Off_Opportunity__c == null) {
                clonedOppty.Spin_Off_Opportunity__c = parentOppty.Id;
            } else {
                clonedOppty.Spin_Off_Opportunity__c = parentOppty.Spin_Off_Opportunity__c;
            }
            
            //upsert updatedOpptys;
            insert clonedOppty;
                       
            //clone opportunity line items
            List<sObject> spinOffSObjectOLIs = new List<sObject>();
            for(OpportunityLineItem obj : spinOffOLIs) {
                spinOffSObjectOLIs.add((sObject)obj);
            }
            List<sObject> clonedSObjectOLIs = cloneObjects(spinOffSObjectOLIs, spinOffOLIs.get(0).getsObjectType());
            //reset spin off flag
            for(sObject obj : clonedSObjectOLIs) {
                obj.put('OpportunityId', clonedOppty.Id);
                //system.debug('legacyId2::'+ obj.Legacy_Id__c);
                OpportunityLineItem tmpObj = (OpportunityLineItem)obj;
                tmpObj.Spin_Off__c = false;
                
                 //Modified as Part of SIR 1178
                  tmpObj.Legacy_Id__c=null;
            }
            system.debug('clonedOppty::'+ clonedOppty.Legacy_Id__c);
            insert clonedSObjectOLIs;
            delete spinOffOLIs;
            return new PageReference('/' + clonedOppty.Id);
        } catch(Exception e) {
            cloneStatus = false;
            errorMessage = e.getMessage();
        }
        return null;
    }
    
  // Clone a list of objects to a particular object type
  // Parameters 
  // - List<sObject> sObjects - the list of objects to be cloned 
  // - Schema.SobjectType objectType - the type of object to be cloned.
  // The sObjects you pass in must include the ID field, 
  // and the object must exist already in the database, 
  // otherwise the method will not work.
  public List<sObject> cloneObjects(List<sObject> sObjects,
                                        Schema.SObjectType objectType){
    
    // A list of IDs representing the objects to clone
    List<Id> sObjectIds = new List<Id>{};
    // A list of fields for the sObject being cloned
    List<String> sObjectFields = new List<String>{};
    // A list of new cloned sObjects
    List<sObject> clonedSObjects = new List<sObject>{};
    
    // Get all the fields from the selected object type using 
    // the get describe method on the object type.
    if(objectType != null){
      sObjectFields.addAll(
        objectType.getDescribe().fields.getMap().keySet());
    }
    
    // If there are no objects sent into the method, 
    // then return an empty list
    if (sObjects != null && 
        !sObjects.isEmpty() && 
        !sObjectFields.isEmpty()){
    
      // Strip down the objects to just a list of Ids.
      for (sObject objectInstance: sObjects){
        sObjectIds.add(objectInstance.Id);
      }

      /* Using the list of sObject IDs and the object type, 
         we can construct a string based SOQL query 
         to retrieve the field values of all the objects.*/
    
      String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0); 
    
      for (Integer i=1 ; i < sObjectFields.size() ; i++){
        String tmpFieldName = sObjectFields.get(i);
        if (tmpFieldName.equalsIgnoreCase('totalprice')) continue;
        allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
      }
    
      allSObjectFieldsQuery += ' FROM ' + 
                               objectType.getDescribe().getName() + 
                               ' WHERE ID IN (\'' + sObjectIds.get(0) + 
                               '\'';

      for (Integer i=1 ; i < sObjectIds.size() ; i++){
        allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
      }
    
      allSObjectFieldsQuery += ')';
    
//      try{
      
        // Execute the query. For every result returned, 
        // use the clone method on the generic sObject 
        // and add to the collection of cloned objects
        for (SObject sObjectFromDatabase:
             Database.query(allSObjectFieldsQuery)){
          //clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber)
          // 2015-08-28 by Rex: set preserveReadonlyTimestamps flag to true to clone CreatedDate from parent oppty
          clonedSObjects.add(sObjectFromDatabase.clone(false,true,true,false));
        }
    
//      } catch (exception e){
        // Write exception capture method 
        // relevant to your organisation. 
        // Debug message, Apex page message or 
        // generated email are all recommended options.
//      }
    }    
    
    // return the cloned sObject collection.
    return clonedSObjects;
  }

}