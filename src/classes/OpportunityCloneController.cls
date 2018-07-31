public with sharing class OpportunityCloneController {
    public static final String FUNC_CLONE = 'clone';
    public static final String FUNC_SPINOFF = 'spin off';
    public static final String FUNC_REOPEN = 'reopen';
    
    public class OpportunityWrapper {
        @AuraEnabled public Opportunity oppty {get; set;}
        @AuraEnabled public String newOpptyName {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public List<OpportunitySpinOffWrapper> lstWrappers {get; set;}
        @AuraEnabled public List<OpportunitySchedule__c> lstOpptyScheds {get; set;}
    }
    
    public class OpportunitySpinOffWrapper {
        @AuraEnabled public OpportunityLineItem opptyLineItem {get; set;}
        @AuraEnabled public Boolean isSelected {get; set;}
        @AuraEnabled public Double qtyPerSys {get; set;}
        @AuraEnabled public Boolean qtyPerSysChanged {get; set;}
    }

    @AuraEnabled
    public static OpportunityCloneController.OpportunityWrapper getOpptyProdsByOpptyId(String opptyId, String func) {
        Opportunity oppty = [Select Id, Name, StageName, Design_Win_Approval_Process__c, OwnerId, CloseDate, Production_Date__c from Opportunity Where Id =: opptyId];
        
        List<OpportunityLineItem> lstOpptyProds = 
            [Select Id, Product2.Name, MAG__c, Product_Active_Flags__c, UnitPrice, Component_Multiplier__c, Claim_Value_USD__c, Product2.IsActive, Prod_Lost_Cancelled__c 
             from OpportunityLineItem Where OpportunityId =: opptyId];
        
        List<OpportunitySpinOffWrapper> lstWrappers = new List<OpportunitySpinOffWrapper>();
        
        List<OpportunitySchedule__c> lstOpptyScheds = 
            [Select Id, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
             from OpportunitySchedule__c Where Opportunity__c =: opptyId];
        
        String message = null;
        Integer activeProdCount = 0;
        
        for (OpportunityLineItem item : lstOpptyProds) {
        	if (item.Product2.IsActive) activeProdCount++;
        	
            OpportunitySpinOffWrapper wrapper = new OpportunitySpinOffWrapper();
            //check Qty Per Sys
            Double qtyPerSys = item.Component_Multiplier__c * 100;
            
            if (Math.mod(qtyPerSys.intValue(), 100) > 0) {
                wrapper.qtyPerSys = 1;
                wrapper.qtyPerSysChanged = true;
                message = 'Qty per Sys is not integer in ' + func + ' OpportunityLineItem, Qty per Sys will be set to 1 and Prod Claim Value will be recalculated afterwards. \nPlease review Qty per Sys once Opportunity been created.';
            } else {
                wrapper.qtyPerSys = item.Component_Multiplier__c;
                wrapper.qtyPerSysChanged = false;
            }
            
            wrapper.opptyLineItem = item;
            wrapper.isSelected = (func == OpportunityCloneController.FUNC_SPINOFF || !item.Product2.IsActive) ? false : true;
            lstWrappers.add(wrapper);
        }
        
        OpportunityWrapper opptyWrapper = new OpportunityWrapper();
        opptyWrapper.oppty = oppty;
        opptyWrapper.message = message;
        opptyWrapper.lstWrappers = lstWrappers;
        opptyWrapper.lstOpptyScheds = lstOpptyScheds;
        
        //check current user is oppty owner or not
        if (func == OpportunityCloneController.FUNC_SPINOFF) {
        	String errMsg = '';
        	
        	if (lstOpptyProds.size() < 2 || activeProdCount < 1) {
        		errMsg = 'Opportunities require at least two products of which one is active to be spun off.\n'; 
        	}
        	
            if (oppty.Design_Win_Approval_Process__c != 'Open') {
                errMsg += 'Only open opportunity can be spun off.\n'; 
            }
            
            if (!CommonUtils.isAdmin() && oppty.OwnerId != UserInfo.getUserId()) {
                errMsg += 'Only opportunity owner can do spin off.\n'; 
            }
            
            if (errMsg != '') {
            	throw new AuraHandledException(errMsg);	
            }            
        } else if (func == OpportunityCloneController.FUNC_REOPEN) {
            if (oppty.StageName != 'Lost' && oppty.StageName != 'Cancelled') {
                throw new AuraHandledException('Only Cancelled or Lost opportunity can do reopen.');
            }
        }
        
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

    public static String doReOpen(OpportunityCloneController.OpportunityWrapper wrapper, String func, 
                                           OpportunityCloneController.OpportunityCloneWrapper myclone) {
        //keep savepoint
        Savepoint sp = Database.setSavepoint();
        Opportunity myOppty = (Opportunity)myclone.clonedSObjectOppty.get(0);

        try {
            myclone.checkOpptyCloseDateAndSched();
            //update close date/production date
            wrapper.oppty.StageName = 'Initial Engagement';
            wrapper.oppty.CloseDate = myOppty.CloseDate;
            wrapper.oppty.Production_Date__c = myOppty.Production_Date__c;
            wrapper.oppty.Bypass_Validation_Sched_Start_Date__c = true;                
            update wrapper.oppty;
            
            if (myclone.isOpptySchedReset) {
                //delete existed oppty sched
                if (wrapper.lstOpptyScheds != null && wrapper.lstOpptyScheds.size() > 0)
                    delete wrapper.lstOpptyScheds;
                //insert new oppty sched
                myclone.clonedSObjectOpptyScheds.get(0).put('Opportunity__c', wrapper.oppty.Id);
                insert myclone.clonedSObjectOpptyScheds;
            }
            
            //process reopen lineitems
            List<OpportunityLineItem> reopenProds = new List<OpportunityLineItem>();
            
            for (OpportunitySpinOffWrapper w : wrapper.lstWrappers) {
                if (w.isSelected) {
                    w.opptyLineItem.Prod_Lost_Cancelled__c = null;
                    reopenProds.add(w.opptyLineItem);
                }
            }
            
            update reopenProds;
            
            Opportunity oppty = new OpportunitiesSelector().selectById(new Set<Id>{wrapper.oppty.Id}).get(0); 
            oppty.Bypass_Validation_Sched_Start_Date__c = false;                
            update oppty;
        } catch (Exception err) {
            system.debug('@@@@@ ' + err.getMessage());
            Database.rollback(sp);
            throw err;
        }
        
        return wrapper.oppty.Id;
    }
    
    @AuraEnabled
    public static String doCloneAndSpinOff(String opptyWrapper, String func) {
        OpportunityCloneController.OpportunityWrapper wrapper = 
            (OpportunityCloneController.OpportunityWrapper)System.JSON.deserialize(opptyWrapper, OpportunityCloneController.OpportunityWrapper.class);

        OpportunityCloneController.OpportunityCloneWrapper myclone = 
            new OpportunityCloneController.OpportunityCloneWrapper(wrapper.oppty.Id, (func == OpportunityCloneController.FUNC_CLONE ? false : true));
        
        if (func == OpportunityCloneController.FUNC_REOPEN)
            return OpportunityCloneController.doReOpen(wrapper, func, myclone);
        else
            return OpportunityCloneController.doCloneAndSpinOff(wrapper, func, myclone);
    }

    public class OpportunityCloneWrapper {
        public Opportunity originalOppty {get; set;}
        public List<sObject> clonedSObjectOppty {get; set;}
        public List<sObject> clonedSObjectOpptyProds {get; set;}
        public List<sObject> clonedSObjectOpptyScheds {get; set;}
        public Boolean isOpptySchedReset {get; set;}
        
        public OpportunityCloneWrapper(String opptyId, boolean keepSystemFields) {
            isOpptySchedReset = false;
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
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Opportunity.fields.getMap();
            sObject myOppty = clonedSObjectOppty.get(0);
            Opportunity_Clone_Reset_Field__mdt[] resetFields = [
                Select Field_Name__c, Value__c from Opportunity_Clone_Reset_Field__mdt Where Object_Type__c = 'Opportunity'];
            for (Opportunity_Clone_Reset_Field__mdt resetField : resetFields) {
                Schema.SObjectField field = fieldMap.get(resetField.Field_Name__c);
                Schema.DisplayType displayType = field.getDescribe().getType();
                Object resetValue = convertValue(resetField, displayType);
                myOppty.put(resetField.Field_Name__c, resetValue);
            }
            //reset owner
            myOppty.put('OwnerId', UserInfo.getUserId());
            //update opportunity name
            myOppty.put('Name', (String)myOppty.get('Name') + '(cloned)');
               
            checkOpptyCloseDateAndSched();

            /*
            Date productionDate = (Date)myOppty.get('Production_Date__c');
            if (today > productionDate) {
                myOppty.put('Production_Date__c', today.addDays(1));
                //process oppty sched data
                if (clonedSObjectOpptyScheds != null) {
                    //reset opportunity schedule
                    OpportunitySchedule__c opptySched = new OpportunitySchedule__c();
                    opptySched.Oppty_Sched_Qty__c = 1000;
                    opptySched.Frozen_Oppty_Sched_Qty__c = 1000;
                    opptySched.Sched_Date__c = (Date)myOppty.get('Production_Date__c');
                    clonedSObjectOpptyScheds = new List<sObject>{(sObject)opptySched};                    
                }
            }*/
            return (Opportunity)myOppty;
        }

        public Opportunity checkOpptyCloseDateAndSched() {
            sObject myOppty = clonedSObjectOppty.get(0);

            //check close date & production date
            Date today = Date.today();
            Date closeDate = (Date)myOppty.get('CloseDate');
            if (today > closeDate) {
                myOppty.put('CloseDate', today.addDays(1));
            }

            Date productionDate = (Date)myOppty.get('Production_Date__c');
            Date newCloseDate = (Date)myOppty.get('CloseDate'); //
            if (today > productionDate || newCloseDate > productionDate) { //
                myOppty.put('Production_Date__c', today.addDays(1));
                //process oppty sched data
                if (clonedSObjectOpptyScheds != null) {
                    //reset opportunity schedule
                    OpportunitySchedule__c opptySched = new OpportunitySchedule__c();
                    opptySched.Oppty_Sched_Qty__c = 1000;
                    opptySched.Frozen_Oppty_Sched_Qty__c = 1000;
                    opptySched.Sched_Date__c = (Date)myOppty.get('Production_Date__c');
                    clonedSObjectOpptyScheds = new List<sObject>{(sObject)opptySched};
                    isOpptySchedReset = true;
                }
            }
            return (Opportunity)myOppty;
        }
        
        public void resetOpptyProdFields() {
            Opportunity clonedOppty = (Opportunity)clonedSObjectOppty.get(0);
            if (clonedSObjectOpptyProds != null) {
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.OpportunityLineItem.fields.getMap();
                Opportunity_Clone_Reset_Field__mdt[] resetFields = [
                    Select Field_Name__c, Value__c from Opportunity_Clone_Reset_Field__mdt Where Object_Type__c = 'OpportunityLineItem'];
                for(sObject obj : clonedSObjectOpptyProds) {
                    for (Opportunity_Clone_Reset_Field__mdt resetField : resetFields) {
                        Schema.SObjectField field = fieldMap.get(resetField.Field_Name__c);
                        Schema.DisplayType displayType = field.getDescribe().getType();
                        Object resetValue = convertValue(resetField, displayType);
                        obj.put(resetField.Field_Name__c, resetValue);
                    }
                    //update OpportunityId
                    obj.put('OpportunityId', clonedOppty.Id);
                    
                    //reset component multiplier
                    Double qtyPerSys = (Double)obj.get('Component_Multiplier__c') * 100;
                    if (Math.mod(qtyPerSys.intValue(), 100) > 0) {
                        obj.put('Component_Multiplier__c', 1);
                    }                   
                }                
            }
        }
        
        private Object convertValue(Opportunity_Clone_Reset_Field__mdt obj, Schema.DisplayType displayType) {
            Object resetValue;
            if (obj.Value__c == null) {
                //System.debug('@@@@@ 1type=' + displayType + ', ' + obj.Field_Name__c + ' = null');
                resetValue = null;
            } else if (displayType == Schema.DisplayType.DOUBLE || displayType == Schema.DisplayType.CURRENCY) {
                //System.debug('@@@@@ 2type=' + displayType + ', ' + obj.Field_Name__c);
                resetValue = Decimal.valueOf(obj.Value__c);
            } else if (displayType == Schema.DisplayType.BOOLEAN) {
                //System.debug('@@@@@ 3type=' + displayType + ', ' + obj.Field_Name__c);
                resetValue = Boolean.valueOf(obj.Value__c);
            } else if (displayType == Schema.DisplayType.Date) {
                resetValue = Date.valueOf(obj.Value__c);
            } else {
                //System.debug('@@@@@ 4type=' + displayType + ', ' + obj.Field_Name__c);
                resetValue = obj.Value__c;
            }
            return resetValue;
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