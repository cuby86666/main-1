/**********************************************************************************************
@Modified By :  Scarlett Kang
@Modified Date: 05 Feb 2015
@Description:   Change approval flow for purchasing agreement 
                1. Red flags ON & Value = 0, approval goes to CPO and Head of Sourcing approver
                2. Value >= 1M, approval goes to CPO
                3. Value >= 250K, approval goes to Head of Sourcing
                4. Red flags ON & Value > 1M, goes to MT approver
***********************************************************************************************/
/**********************************************************************************************
@Modified By :  Balaji Gunasekaran
@Modified Date: 10 Nov 2015
@Description:   Change approval flow for "Assembly & Testing Agreement" and "Foundry Services Agreement" based on new matrix proposal by Puay Lin for Day1
                Added check for Head of Sourcing and Chief Purchasing Officer and included this Agreement types in MT Approver check for 1M$+
***********************************************************************************************/
/**********************************************************************************************
@Modified By :  Scarlett Kang
@Modified Date: 27 April 2016
@Description:   1605 Release SIR 798 - Apttus - OEM budgetary quote (new agreement type)
                By pass Corporate Control Approver for OEM Budgetary Quote agreement type
-----------------------------------------------------------------------------------------------
@Modified By :  Scarlett Kang
@Modified Date: 30 June 2016
@Description:   1608 Release SIR 907 - Apttus Changes - Procurement Purchasing Policy
-----------------------------------------------------------------------------------------------
@Modified By :  Scarlett Kang
@Modified Date: 18 Aug 2016
@Description:   1608 Hot-fix SIR 1187 - MT Approver is not correctly populated
-----------------------------------------------------------------------------------------------
@Modified By :  Scarlett Kang
@Modified Date: 19 Aug 2016
@Description:   Roll back the code for SIR 1187
***********************************************************************************************/
trigger AptsAgreementTrigger on Apttus__APTS_Agreement__c (before insert, before update) {
    String APPROVAL_SHARING_REASON= 'Approval Sharing';
     
    List<Apttus__APTS_Agreement__c> agmts = trigger.new;
    List<Id> agmtIds = new List<Id>();
    Map<Id, Apttus__APTS_Agreement__c> oldAgmtMap = Trigger.oldMap;
    List<Apttus__APTS_Agreement__Share> agmtShares  = new List<Apttus__APTS_Agreement__Share>();
    try{
    for(Apttus__APTS_Agreement__c agmt :agmts){
        //System.debug('status '+oldAgmtMap.get(agmt.id).Apttus__Status__c);
        
        AgreementApproverRules approverRules = AgreementApproverRuleFactory.createAgreementApproverRoles(agmt);
        
        if(approverRules!=null)
        {
        approverRules.populateApprovers(agmt);
        
        }
        
        if(agmt.nxp_Responsible__c == null)
            agmt.nxp_Responsible__c = agmt.OwnerId;
        if(agmt.Apttus__Status__c == 'Request Approval' && 
            (oldAgmtMap.get(agmt.id) == null || oldAgmtMap.get(agmt.id).Apttus__Status__c != agmt.Apttus__Status__c))
            addCustomSharing(agmt);
        else if(oldAgmtMap !=null && oldAgmtMap.get(agmt.id) != null && (agmt.Apttus__Status__c == 'Activated' || agmt.Apttus__Status__c == 'Request'))
            removeCustomSharing(agmt);
        if(agmt.Apttus__Status_Category__c == 'Request'){       
            //Apply approver for purchasing approvers
            if((agmt.nxp_Agreement_Type__c == 'Global/Local General Purchase Agreement (GPA)' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Inventory/Logistics Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Price Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Quality Agreement' ||
               agmt.nxp_Agreement_Type__c == 'IP/Technology License Agreement' ||
               agmt.nxp_Agreement_Type__c == 'MoU/LoI' ||
               agmt.nxp_Agreement_Type__c == 'Foundry Services Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Assembly & Testing Agreement')
              ){
                  checkHeadofSourcingApprover(agmt);
                  checkChiefPurchasingOfficerApprover(agmt);
                  checkSBMTApprover(agmt);//1607 Release SIR 907 - Added by Scarlett
            }
            /***1605 Release SIR 798 - Modified by Scarlett - START***/
            //By pass Corporate Control Approver for OEM Budgetary Quote agreement, Global/Local Price Agreement and Global/Local Quality Agreement
            if(agmt.nxp_Agreement_Type__c != 'OEM Budgetary Quote' && agmt.nxp_Agreement_Type__c != 'Global/Local Price Agreement' &&
              agmt.nxp_Agreement_Type__c != 'Global/Local Quality Agreement')
              
           
           
            {
                //Code added by Sumanth for new implementation of Apttus contract types
                if(agmt.nxp_Agreement_Type__c != 'Cooperation Agreement' && agmt.nxp_Agreement_Type__c != 'Customer Payment Security' && agmt.nxp_Agreement_Type__c != 'Design In / Development Agreement' && 
                    agmt.nxp_Agreement_Type__c != 'Distributor P4P / Rebate / T&C Allowance Agreement' && agmt.nxp_Agreement_Type__c != 'IDH/PDH/VAR' && agmt.nxp_Agreement_Type__c != 'Customer Logistics / Inventory Agreement' &&
                    agmt.nxp_Agreement_Type__c != 'OEM /EMS P4P / Rebate / T&C Allowance Agreement' && agmt.nxp_Agreement_Type__c != 'Master Sales Agreement' && agmt.nxp_Agreement_Type__c != 'Other (SALES)' && 
                    agmt.nxp_Agreement_Type__c != 'Product Longevity Agreement' && agmt.nxp_Agreement_Type__c != 'Pre-Production Agreement' && agmt.nxp_Agreement_Type__c != 'Pricing Agreement (actual price load is done via Model N)' &&
                    agmt.nxp_Agreement_Type__c != 'Customer Quality Agreement' && agmt.nxp_Agreement_Type__c != 'Settlement Agreement over $250,000' && agmt.nxp_Agreement_Type__c != 'Sales Representative Contract' &&
                    agmt.nxp_Agreement_Type__c != 'Sustainability Agreement' && agmt.nxp_Agreement_Type__c != 'Tender Agent / Consultant Agreement' && agmt.nxp_Agreement_Type__c != 'Software of Technology License Out' )
                {
                        system.debug('***Remove Corporate Control Approver...***');
                        checkCorporateControlApprover(agmt);
                }
            }
            /***1608 Release SIR 907 - Modified by Scarlett - END***/
            /***1605 Release SIR 798 - Modified by Scarlett - END***/
            checkMTApprover(agmt);
        }
            System.debug('approver roles '+ agmt.Approver_1_role__c+agmt.Approver_2_role__c+agmt.Approver_3_role__c+agmt.Approver_4_role__c);
        
        if((agmt.Approver8__c != null && string.valueof(agmt.Approver8__c) != '') ||
           (agmt.Approver_9__c != null &&  string.valueof(agmt.Approver_9__c) != '') ||
           (agmt.MT_Approver__c != null &&  string.valueof(agmt.MT_Approver__c) != '') ||
           (agmt.nxp_Additional_Approver__c != null && string.valueof(agmt.nxp_Additional_Approver__c) != '') ){
               catchApproversEmail(agmt);
        }

        if(Trigger.isUpdate && oldAgmtMap.get(agmt.id) != null && oldAgmtMap.get(agmt.id).RecordTypeId != agmt.RecordTypeId)
            catchApproverRoleForChangeRecordType(agmt);     
        
        if(Trigger.isInsert && agmt.Apttus__Version_Number__c > 0.0){
            AptsAgreementBeforeTrigger.catchApproverRoleForChangeRecordType(agmt);
        }   
        
        if(agmt.Apttus__Status_Category__c == 'Request' && 
          (agmt.nxp_Agreement_Type__c == 'Framework Distributor Agreement'||
           agmt.nxp_Agreement_Type__c == 'Framework OEM/ODM' ||
           agmt.nxp_Agreement_Type__c == 'Ship Products pre-RFP Agreement')){
                System.debug('*******Account Customer Category: ' + agmt.Account_Customer_Category__c + '******');
                //if(agmt.Account_Customer_Category__c != 'Global'){
                 System.debug('*******Apttus remove GU BM Approver*******');
                 removeBUGMApprover(agmt);
                //} 
        }
    }
    // Insert all of the newly created Share records and capture save result
    System.debug('Add share for ' + agmtShares); 
    if(agmtShares.size()>0){
        Database.SaveResult[] agmtShareInsertResult = Database.insert(agmtShares,false);
        System.debug('Agreement share insert results'+agmtShareInsertResult);
    }
    //delete the shares not needed anymore
    if(agmtIds.size()>0){
        System.debug('Deleted Ids'+ agmtIds);
        AptsAgreementActionAsync.removeSharing(agmtIds);
        /* move into an Async class so as to avoid insufficient privilege error when approver finishes approving/rejecting
        List <Apttus__APTS_Agreement__Share> delAgmtShares = [select id from  Apttus__APTS_Agreement__Share where parentId in :agmtIds and RowCause='Approval_Sharing__c'];
        System.debug('Deleted shares'+ delAgmtShares);
        if(delAgmtShares != null && delAgmtShares.size()>0){
            Database.DeleteResult[] agmtShareDelResult = Database.delete(delAgmtShares);
            System.debug('Agreement share delete results'+agmtShareDelResult);
        }
        */
            
    }
    
    }catch(Exception e){
        agmts[0].addError('Error in trigger'+e);
        System.debug('Error in agreement trigger:'+e);
    }
    
    //add sharing for the approvers
    void addCustomSharing(Apttus__APTS_Agreement__c agmt){
        if(agmt != null){
            /* 080411 change requested by nxp to allow all approvers to be added for access , not dependent on role
            if(agmt.Approver_1_role__c != null && agmt.approver1__c != null)
                addSharing(agmt.approver1__c, agmt.Id); 
            if(agmt.Approver_2_role__c != null && agmt.approver2__c != null)
                addSharing(agmt.approver2__c, agmt.Id); 
            if(agmt.Approver_3_role__c != null && agmt.approver3__c != null)
                addSharing(agmt.approver3__c, agmt.Id); 
            if(agmt.Approver_4_role__c != null && agmt.approver4__c != null)
                addSharing(agmt.approver4__c, agmt.Id); 
            if(agmt.Approver_5_role__c != null && agmt.approver5__c != null)
                addSharing(agmt.approver5__c, agmt.Id); 
            if(agmt.Approver_6_role__c != null && agmt.approver6__c != null)
                addSharing(agmt.approver6__c, agmt.Id); 
            if(agmt.Approver_7_role__c != null && agmt.approver_7__c != null)
                addSharing(agmt.approver_7__c, agmt.Id);*/
            if( agmt.approver1__c != null)
                addSharing(agmt.approver1__c, agmt.Id); 
            if(agmt.approver2__c != null)
                addSharing(agmt.approver2__c, agmt.Id); 
            if( agmt.approver3__c != null)
                addSharing(agmt.approver3__c, agmt.Id); 
            if( agmt.approver4__c != null)
                addSharing(agmt.approver4__c, agmt.Id); 
            if( agmt.approver5__c != null)
                addSharing(agmt.approver5__c, agmt.Id); 
            if( agmt.approver6__c != null)
                addSharing(agmt.approver6__c, agmt.Id); 
            if( agmt.approver_7__c != null)
                addSharing(agmt.approver_7__c, agmt.Id);
            if( agmt.Approver8__c != null)
                addSharing(agmt.Approver8__c, agmt.Id);
            if( agmt.approver_9__c != null)
                addSharing(agmt.approver_9__c, agmt.Id);
            if(agmt.nxp_Additional_Approver__c!=null)
                addSharing(agmt.nxp_Additional_Approver__c, agmt.Id);
            if(agmt.MT_Approver__c != null)
                addSharing(agmt.MT_Approver__c, agmt.Id);
            if(agmt.nxp_Responsible__c <> agmt.ownerId)
                addSharing(agmt.nxp_Responsible__c, agmt.Id);   
            /***1608 Release SIR 1084 - Modified by Scarlett - START***/
            if(agmt.Legal__c != null)
                addSharing(agmt.Legal__c, agmt.Id); 
            /***1608 Release SIR 1084 - Modified by Scarlett - END***/
        }
    }
    
    
    //remove the sharing added for approvers
    void removeCustomSharing(Apttus__APTS_Agreement__c agmt){
        agmtIds.add(agmt.Id);
    }
    
    void addSharing(Id userId, Id agmtId){
        if(userId != null){
            Apttus__APTS_Agreement__Share agmtShare = new Apttus__APTS_Agreement__Share();
            agmtShare.parentId = agmtId;
            agmtShare.UserOrGroupId = userId; 
            agmtShare.AccessLevel = 'Edit';
            agmtShare.RowCause = Schema.Apttus__APTS_Agreement__Share.RowCause.Approval_Sharing__c;
            agmtShares.add(agmtShare);
        }   
        System.debug('Add sharing for ' + userId);
    }       
    
    void checkCorporateControlApprover(Apttus__APTS_Agreement__c agmt){
        //reset the requirement for Corporate Control Approver if value less than 5M
        if(agmt.Total_Agreement_Value_in_millions__c != null && agmt.Total_Agreement_Value_in_millions__c >= 5){
            System.debug('***Value:****' + agmt.Total_Agreement_Value_in_millions__c + '*******');
            System.debug('approver roles '+ agmt.Approver_1_role__c+agmt.Approver_2_role__c+agmt.Approver_3_role__c+agmt.Approver_4_role__c);
            if(agmt.Approver_1_role__c == 'Corporate Control' || agmt.Approver_2_role__c == 'Corporate Control' ||
                agmt.Approver_3_role__c == 'Corporate Control' || agmt.Approver_4_role__c == 'Corporate Control' ||
                agmt.Approver_5_role__c == 'Corporate Control' || agmt.Approver_6_role__c == 'Corporate Control' || 
                agmt.Approver_7_role__c == 'Corporate Control' || agmt.Approver_8_role__c == 'Corporate Control' ||
                agmt.Approver_9_role__c == 'Corporate Control')
                return;
            
            if(agmt.Approver_1_role__c == null || agmt.Approver_1_role__c== ''){
                agmt.Approver_1_role__c= 'Corporate Control';
                System.debug('approver1');
                return;
            }else 
            if(agmt.Approver_2_role__c == null || agmt.Approver_2_role__c== ''){
                agmt.Approver_2_role__c= 'Corporate Control';
                System.debug('approver2');
                return;
            }else 
            if(agmt.Approver_3_role__c == null || agmt.Approver_3_role__c== ''){
                agmt.Approver_3_role__c= 'Corporate Control';
                System.debug('approver3');
                return;
            }else 
            if(agmt.Approver_4_role__c == null || agmt.Approver_4_role__c== ''){
                agmt.Approver_4_role__c= 'Corporate Control';
                System.debug('approver4');
                return;
            }else 
            if(agmt.Approver_5_role__c == null || agmt.Approver_5_role__c== ''){
                agmt.Approver_5_role__c= 'Corporate Control';
                System.debug('approver1');
                return;
            }else 
            if(agmt.Approver_6_role__c == null || agmt.Approver_6_role__c== ''){
                agmt.Approver_6_role__c= 'Corporate Control';
                return;
            }else 
            if(agmt.Approver_7_role__c == null || agmt.Approver_7_role__c== ''){
                agmt.Approver_7_role__c= 'Corporate Control';
                return;
            }else 
            if(agmt.Approver_8_role__c == null || agmt.Approver_8_role__c== ''){
                agmt.Approver_8_role__c= 'Corporate Control';
                return;
            }else 
            if(agmt.Approver_9_role__c == null || agmt.Approver_9_role__c== ''){
                agmt.Approver_9_role__c= 'Corporate Control';
                return;
            }   
        }else{
            System.debug('approver roles '+ agmt.Approver_1_role__c+agmt.Approver_2_role__c+agmt.Approver_3_role__c+agmt.Approver_4_role__c);
            if(agmt.Approver_1_role__c == 'Corporate Control'){
                agmt.Approver_1_role__c= null;
                return;
            }else 
            if(agmt.Approver_2_role__c == 'Corporate Control'){
                agmt.Approver_2_role__c= null;
                return;
            }else 
            if(agmt.Approver_3_role__c == 'Corporate Control'){
                agmt.Approver_3_role__c= null;
                return;
            }else 
            if(agmt.Approver_4_role__c == 'Corporate Control'){
                agmt.Approver_4_role__c= null;
                return;
            }else 
            if(agmt.Approver_5_role__c == 'Corporate Control'){
                agmt.Approver_5_role__c= null;
                return;
            }else 
            if(agmt.Approver_6_role__c == 'Corporate Control'){
                agmt.Approver_6_role__c= null;
                return;
            }else 
            if(agmt.Approver_7_role__c == 'Corporate Control'){
                agmt.Approver_7_role__c= null;
                return;
            }else
            if(agmt.Approver_8_role__c == 'Corporate Control'){
                agmt.Approver_8_role__c= null;
                return;
            } 
            else
            if(agmt.Approver_9_role__c == 'Corporate Control'){
                agmt.Approver_9_role__c= null;
                return;
            } 
        }

    }

/***1607 Release SIR 907 - Modified by Scarlett***/    
    //reset the requirement for MT Approver if UNFLAG Manangement Team
    void checkMTApprover(Apttus__APTS_Agreement__c agmt){
        if(agmt.Management_Team__c == False){
            System.debug('approver roles '+ agmt.MT_Approver_Role__c);
            agmt.MT_Approver_Role__c= null;
            agmt.MT_Approver__c = null;
            return;
        }
        else{
            //chekc for purchasing agreements
            if((agmt.nxp_Agreement_Type__c == 'Global/Local General Purchase Agreement (GPA)' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Inventory/Logistics Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Price Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Quality Agreement' ||
               agmt.nxp_Agreement_Type__c == 'IP/Technology License Agreement' ||
               agmt.nxp_Agreement_Type__c == 'MoU/LoI' ||
               agmt.nxp_Agreement_Type__c == 'Foundry Services Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Assembly & Testing Agreement'))
            {
                if(agmt.Total_Agreement_Value_in_millions__c != null && agmt.Total_Agreement_Value_in_millions__c > 5) //Change 1M to 5M
                    agmt.MT_Approver_Role__c= 'Management Team';
                else{
                    agmt.MT_Approver_Role__c= null;
                    agmt.MT_Approver__c = null;
                }
                return;
            }
            else{
                agmt.MT_Approver_Role__c= 'Management Team';
                return;
            }
        }     

/***1608 Hot-fix SIR 1187, modified by Scarlett***/        
/*
        if((agmt.nxp_Agreement_Type__c == 'Global/Local General Purchase Agreement (GPA)' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Inventory/Logistics Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Price Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Global/Local Quality Agreement' ||
               agmt.nxp_Agreement_Type__c == 'IP/Technology License Agreement' ||
               agmt.nxp_Agreement_Type__c == 'MoU/LoI' ||
               agmt.nxp_Agreement_Type__c == 'Foundry Services Agreement' ||
               agmt.nxp_Agreement_Type__c == 'Assembly & Testing Agreement')){//// Valite for Purchasing Agreement
            if(agmt.Management_Team__c = TRUE ||
               (agmt.Total_Agreement_Value_in_millions__c != null && agmt.Total_Agreement_Value_in_millions__c > 5)){
                   agmt.MT_Approver_Role__c= 'Management Team';
                   return;
            }   
            else{
                agmt.MT_Approver_Role__c= null;
                agmt.MT_Approver__c = null;
                return;
            }
        }
        else{// Valite for non-Purchasing Agreement
            if(agmt.Management_Team__c == False){
                agmt.MT_Approver_Role__c= 'Management Team';
                return;                
            }
            else{
                agmt.MT_Approver_Role__c= null;
                agmt.MT_Approver__c = null;
                return;                
            }
        }
*/
/***1608 Hot-fix SIR 1187, modified by Scarlett***/    
    }
    
    void catchApproversEmail(Apttus__APTS_Agreement__c agmt){
        /*
        List<User> allUser = [SELECT Id, Email FROM User WHERE IsActive = True];
        Map<Id, String> mapUserEmail = new Map<Id, String>();
        for(User users : allUser)
            mapUserEmail.put(users.Id, users.Email);
        */
        
        if(agmt.Approver8__c != null && string.valueof(agmt.Approver8__c) != ''){
            User Approver_8 = [SELECT Id, Email FROM User WHERE Id =: agmt.Approver8__c LIMIT 1];
            agmt.Approver_8_Email__c = string.valueof(Approver_8.Email);
           //agmt.Approver_8_Email__c = string.valueof(mapUserEmail.get(agmt.Approver8__c));
        }
   
        if(agmt.Approver_9__c != null && string.valueof(agmt.Approver_9__c) != ''){
            User Approver_9 = [SELECT Id, Email FROM User WHERE Id =: agmt.Approver_9__c LIMIT 1];
            agmt.Approver_9_Email__c = string.valueof(Approver_9.Email);
           //agmt.Approver_9_Email__c = string.valueof(mapUserEmail.get(agmt.Approver_9__c));
        }
       
        if(agmt.MT_Approver__c != null &&  string.valueof(agmt.MT_Approver__c) != ''){
            User MTApprover = [SELECT Id, Email FROM User WHERE Id =: agmt.MT_Approver__c LIMIT 1];
            agmt.MT_Approver_Email__c = string.valueof(MTApprover.Email);
           //agmt.MT_Approver_Email__c = string.valueof(mapUserEmail.get(agmt.MT_Approver__c));
        }
        
        if(agmt.nxp_Additional_Approver__c != null && string.valueof(agmt.nxp_Additional_Approver__c) != ''){
            User AdditionalApprover = [SELECT Id, Email FROM User WHERE Id =: agmt.nxp_Additional_Approver__c LIMIT 1];
            agmt.Additional_Approver_Email__c = string.valueof(AdditionalApprover.Email);
            //agmt.Additional_Approver_Email__c = mapUserEmail.get(agmt.nxp_Additional_Approver__c);
        }
    }
    
    //for Amend function, 
    //If one agreement has been changed to another record type, need to apply new approver role based on record type
    void catchApproverRoleForChangeRecordType(Apttus__APTS_Agreement__c agmt){        
        Map<Id, String> mapRecordType = new Map<Id, String>();
        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Apttus__APTS_Agreement__c'])
            mapRecordType.put(rt.Id, rt.Name);

        // Find all the record types in the custom setting
        Map<String, Apttus_Approver_Role__c> agreementRecordType = Apttus_Approver_Role__c.getAll();
        for(Apttus_Approver_Role__c rt : agreementRecordType.values()) {
            if(rt.Agreement_Type_Name__c == mapRecordType.get(agmt.RecordTypeId)){
                agmt.Approver_1_Role__c = rt.Approver_1_Role__c;
                agmt.Approver_2_Role__c = rt.Approver_2_Role__c;
                agmt.Approver_3_Role__c = rt.Approver_3_Role__c;
                agmt.Approver_4_Role__c = rt.Approver_4_Role__c;
                agmt.Approver_5_Role__c = rt.Approver_5_Role__c;
                agmt.Approver_6_Role__c = rt.Approver_6_Role__c;
                agmt.Approver_7_Role__c = rt.Approver_7_Role__c;
                agmt.Approver_8_Role__c = rt.Approver_8_Role__c;
                agmt.Approver_9_Role__c = rt.Approver_9_Role__c;
                agmt.Approver1__c = null;
                agmt.Approver2__c = null;
                agmt.Approver3__c = null;
                agmt.Approver4__c = null;
                agmt.Approver5__c = null;
                agmt.Approver6__c = null;
                agmt.Approver_7__c = nULL;
                agmt.Approver8__c = null;
            }
        }

    }
   
    //Remove BU GM Approver for Sales Agreements
    void removeBUGMApprover(Apttus__APTS_Agreement__c agmt){
        if(agmt.Account_Customer_Category__c != NULL && agmt.Account_Customer_Category__c == 'Global'){
            if(agmt.Approver_1_role__c == 'BU GM' || agmt.Approver_2_role__c == 'BU GM' ||
                agmt.Approver_3_role__c == 'BU GM' || agmt.Approver_4_role__c == 'BU GM' ||
                agmt.Approver_5_role__c == 'BU GM' || agmt.Approver_6_role__c == 'BU GM' || 
                agmt.Approver_7_role__c == 'BU GM' || agmt.Approver_8_role__c == 'BU GM' ||
                agmt.Approver_9_role__c == 'BU GM')             
                return;
            
            if(agmt.nxp_Agreement_Type__c == 'Framework Distributor Agreement'){
                if(agmt.Approver_9_Role__c == NULL || agmt.Approver_9_Role__c == ''){
                    agmt.Approver_9_Role__c = 'BU GM';
                    return;
                }
            }
            if(agmt.nxp_Agreement_Type__c == 'Framework OEM/ODM'){
                if(agmt.Approver_9_Role__c == NULL || agmt.Approver_9_Role__c == ''){
                    agmt.Approver_9_Role__c = 'BU GM';                
                    return;
                }
            }
            if(agmt.nxp_Agreement_Type__c == 'Ship Products pre-RFP Agreement'){
                if(agmt.Approver_7_role__c == null || agmt.Approver_7_role__c== ''){
                    agmt.Approver_7_role__c= 'BU GM';
                    System.debug('******TEST*****');
                    return;
                }else 
                if(agmt.Approver_8_role__c == null || agmt.Approver_8_role__c== ''){
                    agmt.Approver_8_role__c= 'BU GM';
                    return;
                }else 
                if(agmt.Approver_9_role__c == null || agmt.Approver_9_role__c== ''){
                    agmt.Approver_9_role__c= 'BU GM';
                    return;
                } 
            }
        }else{
                if(agmt.Approver_1_Role__c == 'BU GM'){
                    agmt.Approver_1_Role__c = NULL;
                    //agmt.Approver1__c = NULL;
                    return;
                }
                if(agmt.Approver_2_Role__c == 'BU GM'){
                    agmt.Approver_2_Role__c = NULL;
                    //agmt.Approver2__c = NULL;
                    return;
                } 
                if(agmt.Approver_3_Role__c == 'BU GM'){
                    agmt.Approver_3_Role__c = NULL;
                    //agmt.Approver3__c = NULL;
                    return;
                }    
                if(agmt.Approver_4_Role__c == 'BU GM'){
                    agmt.Approver_4_Role__c = NULL;
                    //agmt.Approver4__c = NULL;
                    return;
                }    
                if(agmt.Approver_5_Role__c == 'BU GM'){
                    agmt.Approver_5_Role__c = NULL;
                    //agmt.Approver5__c = NULL;
                    return;
                }    
                if(agmt.Approver_6_Role__c == 'BU GM'){
                    agmt.Approver_6_Role__c = NULL;
                    //AGMT.Approver6__c = NULL;
                    return;
                }    
                if(agmt.Approver_7_Role__c == 'BU GM'){
                    agmt.Approver_7_Role__c = NULL;
                    //agmt.Approver_7__c = NULL;
                    return;
                }    
                if(agmt.Approver_8_Role__c == 'BU GM'){
                    agmt.Approver_8_Role__c = NULL;
                    //agmt.Approver8__c = NULL;
                    return;
                }    
                if(agmt.Approver_9_Role__c == 'BU GM'){
                    agmt.Approver_9_Role__c = NULL;
                    //agmt.Approver_9__c = NULL;
                    return;
                }    
        }//else
        
    }
    
    void checkHeadofSourcingApprover(Apttus__APTS_Agreement__c agmt){
        //if(agmt.Total_Agreement_Value_in_millions__c != null && agmt.Total_Agreement_Value_in_millions__c >= 0.25){
        /***1608 Release SIR 907 - Modified by Scarlett - START***/
        //if(agmt.Management_Team__c == True || (agmt.Total_Agreement_Value_in_millions__c != null && agmt.Total_Agreement_Value_in_millions__c >= 0.25)){
        if((agmt.Total_Agreement_Value_in_millions__c != null && agmt.Total_Agreement_Value_in_millions__c >= 0.25)){
        /***1608 Release SIR 907 - Modified by Scarlett - END***/    
            if(agmt.Approver_1_role__c == 'Head of Sourcing' || agmt.Approver_2_role__c == 'Head of Sourcing' ||
                agmt.Approver_3_role__c == 'Head of Sourcing' || agmt.Approver_4_role__c == 'Head of Sourcing' ||
                agmt.Approver_5_role__c == 'Head of Sourcing' || agmt.Approver_6_role__c == 'Head of Sourcing' || 
                agmt.Approver_7_role__c == 'Head of Sourcing' || agmt.Approver_8_role__c == 'Head of Sourcing' ||
                agmt.Approver_9_role__c == 'Head of Sourcing')
                return;
            
            if(agmt.Approver_1_Role__c == NULL || agmt.Approver_1_Role__c == ''){
                agmt.Approver_1_Role__c = 'Head of Sourcing';
                return;
            }
            
            if(agmt.Approver_2_Role__c == NULL || agmt.Approver_2_Role__c == ''){
                agmt.Approver_2_Role__c = 'Head of Sourcing';
                return;
            }
            
            if(agmt.Approver_3_Role__c == NULL || agmt.Approver_3_Role__c == ''){
                agmt.Approver_3_Role__c = 'Head of Sourcing';
                return;
            }
            
            if(agmt.Approver_4_Role__c == NULL || agmt.Approver_4_Role__c == ''){
                agmt.Approver_4_Role__c = 'Head of Sourcing';
                return;
            }
            
            if(agmt.Approver_5_Role__c == NULL || agmt.Approver_5_Role__c == ''){
                agmt.Approver_5_Role__c = 'Head of Sourcing';
                return;
            }
            
            if(agmt.Approver_6_Role__c == NULL || agmt.Approver_6_Role__c == ''){
                agmt.Approver_6_Role__c = 'Head of Sourcing';
                return;
            }
            
            if(agmt.Approver_7_Role__c == NULL || agmt.Approver_7_Role__c == ''){
                agmt.Approver_7_Role__c = 'Head of Sourcing';
                return;
            }
            
            if(agmt.Approver_8_Role__c == NULL || agmt.Approver_8_Role__c == ''){
                agmt.Approver_8_Role__c = 'Head of Sourcing';
                return;
            }
            
            if(agmt.Approver_9_Role__c == NULL || agmt.Approver_9_Role__c == ''){
                agmt.Approver_9_Role__c = 'Head of Sourcing';
                return;
            }
        }else{
            if(agmt.Approver_1_Role__c == 'Head of Sourcing'){
                agmt.Approver_1_Role__c = NULL;
                agmt.Approver1__c = NULL;
                return;
            }else 
            if(agmt.Approver_2_Role__c == 'Head of Sourcing'){
                agmt.Approver_2_Role__c = NULL;
                agmt.Approver2__c = NULL;
                return;
            }else 
            if(agmt.Approver_3_Role__c == 'Head of Sourcing'){
                agmt.Approver_3_Role__c = NULL;
                agmt.Approver3__c = NULL;
                return;
            }else 
            if(agmt.Approver_4_role__c == 'Head of Sourcing'){
                agmt.Approver_4_role__c= null;
                agmt.Approver4__c = NULL;
                return;
            }else 
            if(agmt.Approver_5_role__c == 'Head of Sourcing'){
                agmt.Approver_5_role__c= null;
                agmt.Approver5__c = NULL;
                return;
            }else 
            if(agmt.Approver_6_role__c == 'Head of Sourcing'){
                agmt.Approver_6_role__c= null;
                agmt.Approver6__c = NULL;
                return;
            }else 
            if(agmt.Approver_7_role__c == 'Head of Sourcing'){
                agmt.Approver_7_role__c= null;
                agmt.Approver_7__c = null;
                return;
            }else
            if(agmt.Approver_8_role__c == 'Head of Sourcing'){
                agmt.Approver_8_role__c= null;
                agmt.Approver8__c = null;
                return;
            }else
            if(agmt.Approver_9_Role__c == 'Head of Sourcing'){
                agmt.Approver_9_Role__c = null;
                agmt.Approver_9__c = null;
            }
        }
/*
        if(agmt.Total_Agreement_Value_in_millions__c < 0.25 || agmt.Total_Agreement_Value_in_millions__c == NULL){
            agmt.Approver_3_Role__c = null;
            agmt.Approver3__c = null;
        }else{
            agmt.Approver_3_Role__c = 'Head of Sourcing';
        }
        if(agmt.Total_Agreement_Value_in_millions__c < 5 || agmt.Total_Agreement_Value_in_millions__c  == NULL){
            agmt.Approver6__c = null;
            agmt.Approver_6_Role__c = null;
        }else{
            agmt.Approver_6_Role__c = 'Corporate Control';
        }
        if(agmt.Total_Agreement_Value_in_millions__c < 1 || agmt.Total_Agreement_Value_in_millions__c  == NULL){
            agmt.Approver_7__c = null;
            agmt.Approver_7_Role__c = null;
        }else{
            agmt.Approver_7_Role__c = 'Chief Purchasing Officer';
        }
*/      
    }
    
    void checkChiefPurchasingOfficerApprover(Apttus__APTS_Agreement__c agmt){
        if(agmt.Management_Team__c == True || (agmt.Total_Agreement_Value_in_millions__c != null && agmt.Total_Agreement_Value_in_millions__c >= 1)){
            system.debug('*******Checking CPO... Agreement value********' + agmt.Total_Agreement_Value_in_millions__c);
           system.debug('********test********');
           if(agmt.Approver_1_role__c == 'Chief Purchasing Officer' || agmt.Approver_2_role__c == 'Chief Purchasing Officer' ||
                agmt.Approver_3_role__c == 'Chief Purchasing Officer' || agmt.Approver_4_role__c == 'Chief Purchasing Officer' ||
                agmt.Approver_5_role__c == 'Chief Purchasing Officer' || agmt.Approver_6_role__c == 'Chief Purchasing Officer' || 
                agmt.Approver_7_role__c == 'Chief Purchasing Officer' || agmt.Approver_8_role__c == 'Chief Purchasing Officer' ||
                agmt.Approver_9_role__c == 'Chief Purchasing Officer'){
                system.debug('********CPO already in approval********');
                return;
           }
           else{
               if(agmt.Approver_1_role__c == null || agmt.Approver_1_role__c== ''){
                    agmt.Approver_1_role__c= 'Chief Purchasing Officer';
                    return;
                }else 
                if(agmt.Approver_2_role__c == null || agmt.Approver_2_role__c== ''){
                    agmt.Approver_2_role__c= 'Chief Purchasing Officer';
                    system.debug('********Assign CPO with Approver 2********');
                    return;
                }else 
                if(agmt.Approver_3_role__c == null || agmt.Approver_3_role__c== ''){
                    agmt.Approver_3_role__c= 'Chief Purchasing Officer';
                    system.debug('********Assign CPO with Approver 3********');
                    return;
                }else 
                if(agmt.Approver_4_role__c == null || agmt.Approver_4_role__c== ''){
                    agmt.Approver_4_role__c= 'Chief Purchasing Officer';
                    system.debug('********Assign CPO with Approver 4********');
                    return;
                }else 
                if(agmt.Approver_5_role__c == null || agmt.Approver_5_role__c== ''){
                    agmt.Approver_5_role__c= 'Chief Purchasing Officer';
                    system.debug('********Assign CPO with Approver 5********');
                    return;
                }else 
                if(agmt.Approver_6_role__c == null || agmt.Approver_6_role__c== ''){
                    agmt.Approver_6_role__c= 'Chief Purchasing Officer';
                    system.debug('********Assign CPO with Approver 6********');
                    return;
                }else 
                if(agmt.Approver_7_role__c == null || agmt.Approver_7_role__c== ''){
                    agmt.Approver_7_role__c= 'Chief Purchasing Officer';
                    return;
                }else 
                if(agmt.Approver_8_role__c == null || agmt.Approver_8_role__c== ''){
                    agmt.Approver_8_role__c= 'Chief Purchasing Officer';
                    return;
                }else 
                if(agmt.Approver_8_role__c == null || agmt.Approver_8_role__c== ''){
                    agmt.Approver_8_role__c= 'Chief Purchasing Officer';
                    return;
                }else 
                if(agmt.Approver_9_role__c == null || agmt.Approver_9_role__c== ''){
                    agmt.Approver_9_role__c= 'Chief Purchasing Officer';
                    return;
                }
           }  
            
        }else{
            if(agmt.Approver_1_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_1_role__c= null;
                system.debug('********Remove CPO with Approver 1********');
                return;
            }else 
            if(agmt.Approver_2_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_2_role__c= null;
                system.debug('********Remove CPO with Approver 2********');
                return;
            }else 
            if(agmt.Approver_3_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_3_role__c= null;
                system.debug('********Remove CPO with Approver 3********');
                return;
            }else 
            if(agmt.Approver_4_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_4_role__c= null;
                system.debug('********Remove CPO with Approver 4********');
                return;
            }else 
            if(agmt.Approver_5_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_5_role__c= null;
                system.debug('********Remove CPO with Approver 5********');
                return;
            }else 
            if(agmt.Approver_6_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_6_role__c= null;
                system.debug('********Remove CPO with Approver 6********');
                return;
            }else 
            if(agmt.Approver_7_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_7_role__c= null;
                system.debug('********Remove CPO with Approver 7********');
                return;
            }else
            if(agmt.Approver_8_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_8_role__c= null;
                system.debug('********Remove CPO with Approver 8********');
                return;
            }else
            if(agmt.Approver_9_role__c == 'Chief Purchasing Officer'){
                agmt.Approver_9_role__c= null;
                system.debug('********Remove CPO with Approver 9********');
                return;
            }  
        }
    }

/***1606 Release SIR 907 - Added by Scarlett***/    
    void checkSBMTApprover(Apttus__APTS_Agreement__c agmt){
        if(agmt.Total_Agreement_Value_in_millions__c != null && agmt.Total_Agreement_Value_in_millions__c < 0.25){
            System.debug('approver roles '+ agmt.Approver_1_role__c+agmt.Approver_2_role__c+agmt.Approver_3_role__c+agmt.Approver_4_role__c);
            if(agmt.Approver_1_role__c == 'SBMT' || agmt.Approver_2_role__c == 'SBMT' ||
                agmt.Approver_3_role__c == 'SBMT' || agmt.Approver_4_role__c == 'SBMT' ||
                agmt.Approver_5_role__c == 'SBMT' || agmt.Approver_6_role__c == 'SBMT' || 
                agmt.Approver_7_role__c == 'SBMT' || agmt.Approver_8_role__c == 'SBMT' ||
                agmt.Approver_9_role__c == 'SBMT')
                return;
            
            if(agmt.Approver_1_role__c == null || agmt.Approver_1_role__c== ''){
                agmt.Approver_1_role__c= 'SBMT';
                System.debug('approver1');
                return;
            }else 
            if(agmt.Approver_2_role__c == null || agmt.Approver_2_role__c== ''){
                agmt.Approver_2_role__c= 'SBMT';
                System.debug('approver2');
                return;
            }else 
            if(agmt.Approver_3_role__c == null || agmt.Approver_3_role__c== ''){
                agmt.Approver_3_role__c= 'SBMT';
                System.debug('approver3');
                return;
            }else 
            if(agmt.Approver_4_role__c == null || agmt.Approver_4_role__c== ''){
                agmt.Approver_4_role__c= 'SBMT';
                System.debug('approver4');
                return;
            }else 
            if(agmt.Approver_5_role__c == null || agmt.Approver_5_role__c== ''){
                agmt.Approver_5_role__c= 'SBMT';
                System.debug('approver1');
                return;
            }else 
            if(agmt.Approver_6_role__c == null || agmt.Approver_6_role__c== ''){
                agmt.Approver_6_role__c= 'SBMT';
                return;
            }else 
            if(agmt.Approver_7_role__c == null || agmt.Approver_7_role__c== ''){
                agmt.Approver_7_role__c= 'SBMT';
                return;
            }else 
            if(agmt.Approver_8_role__c == null || agmt.Approver_8_role__c== ''){
                agmt.Approver_8_role__c= 'SBMT';
                return;
            }else 
            if(agmt.Approver_9_role__c == null || agmt.Approver_9_role__c== ''){
                agmt.Approver_9_role__c= 'SBMT';
                return;
            }   
        }else{
            System.debug('approver roles '+ agmt.Approver_1_role__c+agmt.Approver_2_role__c+agmt.Approver_3_role__c+agmt.Approver_4_role__c);
            if(agmt.Approver_1_role__c == 'SBMT'){
                agmt.Approver_1_role__c= null;
                return;
            }else 
            if(agmt.Approver_2_role__c == 'SBMT'){
                agmt.Approver_2_role__c= null;
                return;
            }else 
            if(agmt.Approver_3_role__c == 'SBMT'){
                agmt.Approver_3_role__c= null;
                return;
            }else 
            if(agmt.Approver_4_role__c == 'SBMT'){
                agmt.Approver_4_role__c= null;
                return;
            }else 
            if(agmt.Approver_5_role__c == 'SBMT'){
                agmt.Approver_5_role__c= null;
                return;
            }else 
            if(agmt.Approver_6_role__c == 'SBMT'){
                agmt.Approver_6_role__c= null;
                return;
            }else 
            if(agmt.Approver_7_role__c == 'SBMT'){
                agmt.Approver_7_role__c= null;
                return;
            }else
            if(agmt.Approver_8_role__c == 'SBMT'){
                agmt.Approver_8_role__c= null;
                return;
            }else
            if(agmt.Approver_9_role__c == 'SBMT'){
                agmt.Approver_9_role__c= null;
                return;
            }  
        }
    }
}