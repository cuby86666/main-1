/*****************************************************************************************************
 * Modified By : Jewelslyn
 * Modified Date : 18 Jan, 2015
 * Description: Modified for Optimization related to Opportunity triggers
 ******************************************************************************************************
 * Modified By : Balaji
 * Modified Date : 26 FEB 2016
 * Description: Added method beforeInsert_Update for SIR405
 ******************************************************************************************************
 * Modified By : Balaji
 * Modified Date : 10 MAR 2016
 * Description: Fixed beforeInsert_Update method for Hotfix SIR790
 ******************************************************************************************************
 * Modified By : Baji
 * Modified Date : 05 MAY 2016
 * Description: Added populateApprovers method to add code related to DW approval process for SIR 870
 ******************************************************************************************************
 * Modified By : Shridevi Badiger
 * Modified Date : 26 Sep 2016
 * Description: Modified as part of SIR 1207- To clear the Lost/Cancelled Description when the opportnity stage changes from lost/Cancelled to any other stages.                        
 ******************************************************************************************************
 * Modified By : Baji
 * Modified Date : 30 NOV 2016
 * Description: SIR 1049 (2016.12) (SFDC - 22)  -  MN Opportunity approver's email address will be populated in legacy opportunity owner field via Tibco interface.
   Added logic to Populate standard owner field based on email address of the legacy opportunity owner. And owner will be allowed to change the owner. 
 ******************************************************************************************************/
  

public with sharing class OpportunityTrigger
{
  /*
    
    Private Static Final string TYPE_SFDC_OPPTY='SFDC_OPPTY';
    Private Static Final String TYPE_MN_OPPTY='Model_N_Oppty';
    Private Static Final String TYPE_CHILD_ACCOUNT='Child Account';
    
    Private Static final String INTEG_USER='Integration user';
    Private Static Final String SYSTEM_ADMIN_PROFILE='System Administrator';
    Private Static Final String DATA_ADMIN_USER='Data Admin';
    Private Static Final String STAR_ACCOUNT='STAR';
        
    Public Static Id integUser_Id;
    Public Static Id adminUserProfile_Id;
    Public Static Id dataAdminUser_Id;
    Public Static Id starAccount_Id;
    
    Public Static Set<String> blSet=new Set<string>();
    Public Static Set<String> magSet=new Set<string>();
    
    Public Static List<Approvers_Matrix__c> lstApprMatrix;
    public Static List<account> lstAcct;
    Public Static Set<String> setAcctIds = new Set<string>();
    Public Static map<id,map<string,decimal>> mapOppToMagClaimValue;
    Public Static map<id,map<string,decimal>> mapOppToBlClaimValue;
    Public Static map<string,map<string,Approvers_Matrix__c>> mapTypetoApprMatrx=new map<string,map<string,Approvers_Matrix__c>>();
    Public Static map<string,Approvers_Matrix__c> mapRegionalVPApprover = new map<string,Approvers_Matrix__c>();
    Public Static map<id,list<string>> mapOppToMagApprover;                
    Public Static map<id,list<string>> mapOpptoBlApprover;
    
    //J To be removed after referencing classes are deleted
    Public Static Id sfdcrecordtype_Id;
    Public Static Id mnRecordType_Id;
    
    public static void fetchOppRecordTypes()
    {
      if(sfdcrecordtype_Id ==null && mnRecordType_Id ==null)
      {        
        for(recordType rt:[Select Id, DeveloperName From RecordType Where IsActive=true AND (SobjectType = 'Opportunity' and (DeveloperName =:TYPE_SFDC_OPPTY OR DeveloperName =:TYPE_MN_OPPTY))])
        {         
            if(rt.DeveloperName ==TYPE_SFDC_OPPTY) 
            {
               sfdcrecordtype_Id=rt.id;  
            }
            else if(rt.DeveloperName ==TYPE_MN_OPPTY)
            {
               mnRecordType_Id=rt.id;  
            }
           
          }
        }
    }
    //-J
     
   public static void fetchUserNameProfiles()
   {
     If(integUser_Id ==null && adminUserProfile_Id ==null)
     {   
      for (user u:[Select id, name,profile.name, profileId from user where (Name=:INTEG_USER OR Profile.Name=:SYSTEM_ADMIN_PROFILE OR Profile.Name=:DATA_ADMIN_USER ) AND IsActive=True ])
      {               
          If(U.name == INTEG_USER )
          {
              integUser_Id=u.Id;
          }
          If(U.Profile.Name == SYSTEM_ADMIN_PROFILE)
          {
              adminUserProfile_Id=u.ProfileId; 
          }
          If(U.name == DATA_ADMIN_USER )
          {
              dataAdminUser_Id=u.Id;
          }
        }
      }
   }*/
   

     
/******BEFORE TRIGGER(INSERT AND UPDATE) METHOD****************************************************************
       
 The features Implemented are :   
    Method Name: OnBeforeInsert
       1.Insert Last Updated By And last Modified By : Inserts last updated By and Last Modified By On Insert Of Opportunity

    Method Name: OnBeforeUpdate
       1.Calculating Design win claim Values
       2.Refresh Message Flag: Set Up Refresh message Flag
       3.Update Last Modified and Last Update :  Update Last Modified By and Last Modified Date.                   
                  
   *********************************************************************************************************************/ 
   /*
    Public Static Void onBeforeInsert(List<Opportunity> newOppList)
    {
      
        fetchOppRecordTypes();
        fetchUserNameProfiles();
    
                   
     
     //Feature to update standard owner field based on Legacy Oppty owner field (which is MN approver's email address)     
  
       set<string> setMNOppLegacyOwnerEmailIds = new set<string>();
       Map<string, user> mapMNOppLegacyOwnerDetails = new Map<string, user>(); 
       list<user> lstUserDetails = new list<user>();
      
        for(opportunity opp:newOppList)
        {
          if(opp.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId() && opp.Legacy_Opportunity_Owner__c != null)
           {
             setMNOppLegacyOwnerEmailIds.add(opp.Legacy_Opportunity_Owner__c);
          }
        }
      
       if(!setMNOppLegacyOwnerEmailIds.isempty()){
           lstUserDetails = ([SELECT Id, Name, Email,IsActive,profile.name FROM user where Email in: setMNOppLegacyOwnerEmailIds AND 
                               (Profile.UserLicense.Name = 'Salesforce' OR Profile.UserLicense.Name = 'Salesforce Platform')]);
       }
       
      
      
        if(lstUserDetails!= null && lstUserDetails.size()>0)
         {
           for(user objUser:lstUserDetails)
             {
                mapMNOppLegacyOwnerDetails.put(objUser.Email, objUser);
              }
         }
       for(Opportunity newOpp : newOppList)
        {
            if(newOpp.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId() && newOpp.Legacy_Opportunity_Owner__c != null)
             {
              
                if((mapMNOppLegacyOwnerDetails.containsKey(newOpp.Legacy_Opportunity_Owner__c)))
                 {   
                    newOpp.ownerid=(mapMNOppLegacyOwnerDetails.get(newOpp.Legacy_Opportunity_Owner__c).id);
                    system.debug('*****[Scarlett] Owner Id: ' + mapMNOppLegacyOwnerDetails.get(newOpp.Legacy_Opportunity_Owner__c).id);
                 }
                 else {
                  newOpp.ownerid= dataAdminUser_Id;
                    system.debug('*****[Scarlett] Data Admin Id: ' + dataAdminUser_Id);
                 }
             }
       }   
     //End of Feature to update standard owner field based on Legacy Oppty owner field (which is MN approver's email address)                 
    }    
      
    public Static void onBeforeUpdate(list<Opportunity>newOppList, map<id,opportunity> oldOppMap) 
    {                  
    //fetchOppRecordTypes();
    fetchUserNameProfiles();    
    
         
                                                                      
    //SFDC 22: Feature to update standard owner field based on Legacy Oppty owner field (which is MN approver's email address)  
      
       set<string> setMNOppLegacyOwnerEmailIds = new set<string>();
       set<string> setMNOppSFDCOwner = new set<string>();
       Map<string, user> mapMNOppLegacyOwnerDetails = new Map<string, user>(); 
       list<user> lstUserDetails = new list<user>();
       list<user> lstSFDCOwnerDetails = new list<user>();
      
        for(opportunity opp:newOppList)
        {
          Opportunity oldOpp= oldOppMap.get(Opp.Id);
          if(opp.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId() && opp.Legacy_Opportunity_Owner__c !=null )
           {
            setMNOppLegacyOwnerEmailIds.add(opp.Legacy_Opportunity_Owner__c);
           }
   }    
     
       if(!setMNOppLegacyOwnerEmailIds.isempty()){
           lstUserDetails = ([SELECT Id, Name, Email,IsActive,profile.name FROM user where Email in: setMNOppLegacyOwnerEmailIds AND 
                               (Profile.UserLicense.Name = 'Salesforce' OR Profile.UserLicense.Name = 'Salesforce Platform')]);
       }
  
        for(opportunity opp:newOppList)
        {
          
          if(opp.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId() && opp.Legacy_Opportunity_Owner__c !=null )
           {
            Opportunity oldOpp= oldOppMap.get(Opp.Id);
            setMNOppSFDCOwner.add(oldOpp.ownerid);
           }
        }
       
       if(lstUserDetails!= null && lstUserDetails.size()>0)
         {
           for(user objUser:lstUserDetails)
             {
                mapMNOppLegacyOwnerDetails.put(objUser.Email, objUser);
             }
         }
        
       if(!setMNOppSFDCOwner.isEmpty()){
         lstSFDCOwnerDetails = ([SELECT Id, Name, Email,IsActive,profile.id,profile.name FROM user where id in: setMNOppSFDCOwner]);
       }
         
   if(lstSFDCOwnerDetails.size()>0){
   
     for(user u : lstSFDCOwnerDetails)
     {
       for(Opportunity newOpp : newOppList)
        {
            if(oldOppMap != null && newOpp.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId() && newOpp.Legacy_Opportunity_Owner__c !=null)
             {
             Opportunity oldOpp= oldOppMap.get(newOpp.Id);
            
             if((u.profile.id == adminUserProfile_Id || oldOpp.ownerid == integUser_Id) && oldOpp.ownerid == newOpp.ownerid && oldOpp.Legacy_Opportunity_Owner__c != newOpp.Legacy_Opportunity_Owner__c )
              {   
                if((mapMNOppLegacyOwnerDetails.containsKey(newOpp.Legacy_Opportunity_Owner__c)))
                 {   
                     newOpp.ownerid=(mapMNOppLegacyOwnerDetails.get(newOpp.Legacy_Opportunity_Owner__c).id);
                    
                 }
                 else
                  newOpp.ownerid= dataAdminUser_Id;
              }
           }
        }
      }
    }         
   //SFDC 22: End of Feature to update standard owner field based on Legacy Oppty owner field (which is MN approver's email address)                                                                     
   }    */
 }