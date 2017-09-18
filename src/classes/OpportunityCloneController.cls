public with sharing class OpportunityCloneController {
    public static final String FUNC_CLONE = 'clone';
    public static final String FUNC_SPINOFF = 'spin off';
    public static final String FUNC_REOPEN = 'reopen';
    
    public class OpportunityWrapper {
        @AuraEnabled public Opportunity oppty {get; set;}
        @AuraEnabled public String newOpptyName {get; set;}
        @AuraEnabled public List<OpportunitySpinOffWrapper> lstWrappers {get; set;}
    }
    
    public class OpportunitySpinOffWrapper {
        @AuraEnabled public OpportunityLineItem opptyLineItem {get; set;}
        @AuraEnabled public Boolean isSelected {get; set;}
    }

    @AuraEnabled
    public static OpportunityCloneController.OpportunityWrapper getOpptyProdsByOpptyId(String opptyId, String func) {
        Opportunity oppty = [Select Id, Name, StageName, Design_Win_Approval_Process__c from Opportunity Where Id =: opptyId];
        List<OpportunityLineItem> lstOpptyProds = 
            [Select Id, Product2.Name, MAG__c, Product_Active_Flags__c, UnitPrice, Component_Multiplier__c, Claim_Value_USD__c, Product2.IsActive, Prod_Lost_Cancelled__c 
             from OpportunityLineItem Where OpportunityId =: opptyId];
        List<OpportunitySpinOffWrapper> lstWrappers = new List<OpportunitySpinOffWrapper>();
        
        for (OpportunityLineItem item : lstOpptyProds) {
            OpportunitySpinOffWrapper wrapper = new OpportunitySpinOffWrapper();
            wrapper.opptyLineItem = item;
            wrapper.isSelected = (func == OpportunityCloneController.FUNC_SPINOFF || !item.Product2.IsActive) ? false : true;
            lstWrappers.add(wrapper);
        }
        OpportunityWrapper opptyWrapper = new OpportunityWrapper();
        opptyWrapper.oppty = oppty;
        opptyWrapper.lstWrappers = lstWrappers;
        return opptyWrapper;
    }
    
    public static String doCloneAndSpinOff(OpportunityCloneController.OpportunityWrapper wrapper, String func, 
                                           OpportunityCloneController.OpportunityCloneWrapper myclone) {
        //spin off products
        List<OpportunityLineItem> spinoffProds = new List<OpportunityLineItem>();
        
        //keep savepoint
        Savepoint sp = Database.setSavepoint();
        String newOpptyId = null;
        
        try {
            //insert new opportunity
            Opportunity newOppty = myclone.resetOpptyFields();
            newOppty.Name = wrapper.newOpptyName;
            insert newOppty;
            newOpptyId = newOppty.Id;
            
            //insert opportunity schedule
            if (myclone.clonedSObjectOpptyScheds != null) {
                myclone.resetOpptySchedFields();
                insert myclone.clonedSObjectOpptyScheds;            
            }
    
            //create oppty prod map
            Map<String,Boolean> mapOpptyProds = new Map<String,Boolean>();
            for(OpportunitySpinOffWrapper w : wrapper.lstWrappers) {
                mapOpptyProds.put(w.opptyLineItem.Id,w.isSelected);
                if (w.isSelected) spinoffProds.add(w.opptyLineItem);
            }
            
            if (myclone.clonedSObjectOpptyProds != null) {
                for(Integer i = myclone.clonedSObjectOpptyProds.size() - 1; i >= 0; i--) {
                    sObject obj = myclone.clonedSObjectOpptyProds.get(i);
                    obj.put('Spin_Off__c', false);
                    String strId = String.valueOf(obj.get('Id'));
                    if(Boolean.valueOf(mapOpptyProds.get(strId)) == false) {
                        myclone.clonedSObjectOpptyProds.remove(i);
                    }
                }
                myclone.resetOpptyProdFields();
                insert myclone.clonedSObjectOpptyProds;            
            }
            
            if (func == OpportunityCloneController.FUNC_SPINOFF) {
                //remove spin off prods from original opportunity
                delete spinoffProds;
            }
        } catch (Exception err) {
            system.debug('@@@@@ ' + err.getMessage());
            Database.rollback(sp);
            throw err;
        }
        
        return newOpptyId;
    }
    
    @AuraEnabled
    public static String doCloneAndSpinOff(String opptyWrapper, String func) {
        OpportunityCloneController.OpportunityWrapper wrapper = 
            (OpportunityCloneController.OpportunityWrapper)System.JSON.deserialize(opptyWrapper, OpportunityCloneController.OpportunityWrapper.class);

        OpportunityCloneController.OpportunityCloneWrapper myclone = 
            new OpportunityCloneController.OpportunityCloneWrapper(wrapper.oppty.Id, (func == OpportunityCloneController.FUNC_CLONE ? false : true));
        
        return OpportunityCloneController.doCloneAndSpinOff(wrapper, func, myclone);
    }

    public class OpportunityCloneWrapper {
        public Opportunity originalOppty {get; set;}
        public List<sObject> clonedSObjectOppty {get; set;}
        public List<sObject> clonedSObjectOpptyProds {get; set;}
        public List<sObject> clonedSObjectOpptyScheds {get; set;}
        
        public OpportunityCloneWrapper(String opptyId, boolean keepSystemFields) {
            List<Opportunity> lstOppty = [Select Id, Name,Legacy_Id__c, Spin_Off_Opportunity__c, Design_Win_Approval_Process__c, RecordType.Name,
                                          (Select Id, Product2.Name, MAG__c, Product_Active_Flags__c, UnitPrice, Component_Multiplier__c, Claim_Value_USD__c, Spin_Off__c from OpportunityLineItems), 
                                          (Select Id, Opportunity__c, Oppty_Sched_Qty__c, Sched_Date__c, Frozen_Oppty_Sched_Qty__c from Opportunity_Schedules__r) 
                                          from opportunity where Id =: OpptyId];
            originalOppty = lstOppty.get(0);
            List<OpportunityLineItem> currentProds = getOpptyProds();
            List<OpportunitySchedule__c> currentScheds = originalOppty.getSObjects('Opportunity_Schedules__r');
            List<sObject> currentOppty = new List<sObject>{(sObject)originalOppty};
                
            //opportunity
            clonedSObjectOppty = cloneObjects(currentOppty, currentOppty.get(0).getsObjectType(), keepSystemFields);
            
            //opportunity schedule
            if (currentScheds != null && currentScheds.size() > 0) {
                clonedSObjectOpptyScheds = cloneObjects(currentScheds, currentScheds.get(0).getsObjectType(), keepSystemFields);
            }
            
            //opportunity products
            if (currentProds != null && currentProds.size() > 0) {
                clonedSObjectOpptyProds = cloneObjects(currentProds, currentProds.get(0).getsObjectType(), keepSystemFields);
            }
        }
        
        public List<OpportunityLineItem> getOpptyProds() {
            if (originalOppty == null) return null;
            return originalOppty.getSObjects('OpportunityLineItems');
        }
        
        public Opportunity resetOpptyFields() {
            Opportunity clonedOppty = (Opportunity)clonedSObjectOppty.get(0);
            //reset fields
            clonedOppty.Id = null;
            clonedOppty.Legacy_Id__c = null;
            clonedOppty.StageName = 'Initial Engagement';
            clonedOppty.Amount = 0;
            
            clonedOppty.Design_Win_Approval_Process__c = 'Open';
            clonedOppty.X90_Day_Maturity_Exception__c = false;
            clonedOppty.Design_Win_Approval_Date__c = null;
            clonedOppty.Design_Win_Submission_Date__c = null;
            
            clonedOppty.Lost_Date__c = null;
            clonedOppty.Lost_Description__c = null;
            clonedOppty.Lost_Reason__c = null;
            
            clonedOppty.Reason_Won__c = null;
            clonedOppty.ReasonWon_Description__c = null;
            
            clonedOppty.Compliance_Assessment_Evidence__c = false;
            clonedOppty.Compliance_Risk__c = null;
            
            clonedOppty.Contract_Letter_of_intent__c = false;
            clonedOppty.Purchase_Order_Pre_Production_Order__c = false;
            clonedOppty.Written_Confirmation_from_Customer__c = false;
            
            //update opportunity name
            clonedOppty.Name = clonedOppty.Name + '(cloned)';
            
            //check close date & production date
            Date today = Date.today();
            Date closeDate = clonedOppty.CloseDate;
            if (today > closeDate) {
                clonedOppty.CloseDate = today.addDays(1);
            }
   
            Date productionDate = clonedOppty.Production_Date__c;
            if (today > productionDate) {
                clonedOppty.Production_Date__c = today.addDays(1);
                
                if (clonedSObjectOpptyScheds != null) {
                    //reset opportunity schedule
                    OpportunitySchedule__c opptySched = new OpportunitySchedule__c();
                    opptySched.Oppty_Sched_Qty__c = 1000;
                    opptySched.Frozen_Oppty_Sched_Qty__c = 1000;
                    opptySched.Sched_Date__c = clonedOppty.Production_Date__c;
                    clonedSObjectOpptyScheds = new List<sObject>{(sObject)opptySched};                    
                }
            }
            return clonedOppty;
        }
        
        public void resetOpptySchedFields() {
            Opportunity clonedOppty = (Opportunity)clonedSObjectOppty.get(0);
            //insert && update opportunity id (Opportunity__c)
            if (clonedSObjectOpptyScheds != null) {
                for(sObject obj : clonedSObjectOpptyScheds) {
                    obj.put('Id', null);
                    obj.put('Opportunity__c', clonedOppty.Id);
                }
            }
        }
        
        public void resetOpptyProdFields() {
            Opportunity clonedOppty = (Opportunity)clonedSObjectOppty.get(0);
            //update OpportunityId
            if (clonedSObjectOpptyProds != null) {
                for(sObject obj : clonedSObjectOpptyProds) {
                    obj.put('Id', null);
                    obj.put('OpportunityId', clonedOppty.Id);
                    obj.put('Legacy_Id__c', null);
                    obj.put('Prod_Lost__c', false);
                    obj.put('Prod_Lost_Cancelled__c', null);
                    obj.put('Prod_Lost_Cancelled_Date__c', null);
                    obj.put('Prod_Lost_Reason__c', null);
                    obj.put('Prod_Lost_Cancelled_Reason__c', null);
                }                
            }
        }
        /*
        public String insertCloneOppty() {
            //keep savepoint
            Savepoint sp = Database.setSavepoint();
            try {
                //reset oppty fields
                Opportunity clonedOppty = resetOpptyFields();                
                insert clonedOppty;
                
                //update opportunity__c
                resetOpptySchedFields();
                if (clonedSObjectOpptyScheds != null) {
                    insert clonedSObjectOpptyScheds;
                }

                //reset oppty prod fields
                resetOpptyProdFields();
                if (clonedSObjectOpptyProds != null) {
                    insert clonedSObjectOpptyProds;
                }
                
                return clonedOppty.Id;
            } catch (Exception err) {
                system.debug('@@@@@ ' + err.getMessage());
                Database.rollback(sp);
                throw err;
            }
        }*/
    }
        
  // Clone a list of objects to a particular object type
  // Parameters 
  // - List<sObject> sObjects - the list of objects to be cloned 
  // - Schema.SobjectType objectType - the type of object to be cloned.
  // The sObjects you pass in must include the ID field, 
  // and the object must exist already in the database, 
  // otherwise the method will not work.
  public static List<sObject> cloneObjects(List<sObject> sObjects,
                                        Schema.SObjectType objectType, boolean keepSystemFields) {
    
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

        //try{
        // Execute the query. For every result returned, 
        // use the clone method on the generic sObject 
        // and add to the collection of cloned objects
        for (SObject sObjectFromDatabase:
             Database.query(allSObjectFieldsQuery)){
          //clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber)
          // 2015-08-28 by Rex: set preserveReadonlyTimestamps flag to true to clone CreatedDate from parent oppty
          clonedSObjects.add(sObjectFromDatabase.clone(true,true,keepSystemFields,false));
        }
    
      //} catch (exception err){
        // Write exception capture method 
        // relevant to your organisation. 
        // Debug message, Apex page message or 
        // generated email are all recommended options.
        //system.debug(err.getMessage());
      //}
    }    
    // return the cloned sObject collection.
    return clonedSObjects;
  }
}