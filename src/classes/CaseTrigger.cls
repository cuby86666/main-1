/***************************************************************************************************
@Created By :      Prakahr Gupta
@Created Date:     20 Dec 2014
@Description:      Class for all the methods for triggers on Case
*******************************************************************************************************/

/***************************************************************************************************
@Modified By :      Amrutha R
@Modified Date:     27 Feb 2015
@Description:       Changed according to new case assignment process
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :      Amrutha R
@Modified Date:     23 Nov 2015
@Description:       Skip case assignment field in user object- dont assign case to user if value is true
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Amrutha R
@Modified Date:     27 Jan 2016
@Description:       Change default queue from '1st line support' to 'TS L1 inbox'
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date:     07 Apr 2016
@Description:       Cleanup of case assignment rules
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date:     22 july 2016
@Description:       Entitlement based routing
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      vinanthi ittigi
@Modified Date:     25 july 2016
@Description:       sir 1080
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Shridevi Badiger
@Modified Date:     11 Jan 2017
@Description:       sir 207-Finalise case service level and  case priority.
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Shridevi Badiger
@Modified Date:     28 Jun 2017
@Description:       SIR-518-Remove the usage of tech support record type to disable it
**********************************************************************************************************/
public class CaseTrigger 
{ 
    private static final string DOMAIN_SEPARATOR = '@';
    private static final string DEFAULT_QUEUE = 'TS L1 Inbox';
    
    //Method to populate the Product Values based on the Product Type Number to Case 
    public static void populateProductValuesToCase(List<Case> lstCases)
    {
        
        Map<Case,String> mapCaseIdProducTypeNumber = new Map<Case,String>();
        Map<String,Product2> mapProductTypeProduct = new Map<String,Product2>();        
        Set <String> productTypeNumberSet= new Set<String>();
        
        //loop over all case records and process one by one
        for(Case objCase : lstCases)        
        {
            if (objCase.Product_Type_Number__c!= null && objCase.Product_Type_Number__c!='')
            {
                mapCaseIdProducTypeNumber.put(objCase,objCase.Product_Type_Number__c);
                productTypeNumberSet.add(objCase.Product_Type_Number__c);
            }            
        }  
  
        if(!mapCaseIdProducTypeNumber.IsEmpty())
        {            
            List<Product2> lstProduct=[Select Id, Basic_Type__c,BL_Description__c,
                                         Basic_Type_Description__c,BL__c,BU__c,BU_Description__c,MAG__c,
                                         MAG_Description__c,Product_Type__c From Product2 
                                         Where Product_Type__c In : productTypeNumberSet];
            
            for(String strProductTypeNo:productTypeNumberSet )
            {
                for (Product2 objProduct: lstProduct)
                {
                    if ( mapProductTypeProduct.get(strProductTypeNo)==null)
                    {
                        if (strProductTypeNo == objProduct.Product_type__c)
                        { 
                            mapProductTypeProduct.put(strProductTypeNo,objProduct);
                        }
                    }
                }
            }
        }
        
        if(!mapProductTypeProduct.isEmpty())
        {            
            for (Case objCase: lstCases)
            {
                if(mapCaseIdProducTypeNumber.containsKey(objCase))
                {
                    if(mapProductTypeProduct.containsKey(mapCaseIdProducTypeNumber.get(objCase)))
                    {                    
                        Product2 objProduct= mapProductTypeProduct.get(mapCaseIdProducTypeNumber.get(objCase));
                        objCase.BL__c=objProduct.BL__c;
                        objCase.BL_Description__c=objProduct.BL_Description__c;
                        objCase.BU__c=objProduct.BU__c;
                        objCase.BU_Description__c=objProduct.BU_Description__c;
                        objCase.MAG__c=objProduct.MAG__c;
                        objCase.MAG_Description__c=objProduct.MAG_Description__c;
                        objCase.Basic_Type_Description__c=objProduct.Basic_Type_Description__c;
                        objCase.Basic_Type__c=objProduct.Basic_Type__c;
                    }
                }
            }
        } 
     
    }
    //method to assign account and owner to case- new assignment process
    public static void newProcessCasesToAssignOwnerAndAccount(List<Case> lstCases)
    {
        List<Group> lstGroups = [Select Id, Name From Group Where Name = :DEFAULT_QUEUE  limit 1] ;
        List<Contact> lstContacts = new List<Contact>();
        RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
        //commented the below line as part of SIR 518-to remove the usage of tech support record type a
        //RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
        system.debug(lstGroups);
        for(Case objCase:  lstCases)
        {
            lstContacts=[select id,accountId,Account.owner.id from contact where id=: objCase.ContactId LIMIT 1];
        }    
              
        if(lstContacts.size()!=0)
        {
            if(lstContacts[0].accountId!=null)
            {        
                for (Case objCase: lstCases) 
                {
                    if(objCase.Origin != null && objCase.EntitlementId == null && objCase.RecordTypeId==tsRecordType.Id )
                    {
                        objCase.AccountId = lstContacts[0].accountId;
                        objcase.ownerid = lstGroups[0].id;
                    }
                }
            }
        }
   }
   
   //case owner assignment through entitlement
   public static void CasesOwnerAssignment(List<Case> lstCases1)
   {
        
       List<Group> lstGroups = [Select Id, Name From Group Where Name = :DEFAULT_QUEUE  limit 1] ;
       List<Entitlement> lstEntitlement = new List<Entitlement>();
       List<User> lstUser = new List<User>();
       List<group> lstgroup = new List<group>();
       List<User> lstUser1 = new List<User>();
     
        Set<id> Entitlementids = new Set<id>();
        
        for (case objcase :lstCases1)
        {
           Entitlementids.add(objcase.EntitlementId); 
        }
        
        lstEntitlement =[select id,Used_number_of_Hours__c,status,Route_To_Case_Owner__c,Route_to_Assigned_to__c,Total_Number_of_Hours__c,Remaining_Hours__c from entitlement where id in :Entitlementids ];
        system.debug('++++++++'+ lstEntitlement);
        
      for (Case objCase: lstCases1)
      {        
                if(lstEntitlement.size() > 0 )
                {
                    for(Entitlement objEntitlement : lstEntitlement )
                    {
                    if(objEntitlement.id == Objcase.EntitlementId)
                    {
                    
                    if(objEntitlement.status == 'ACTIVE')
                    {
                    if(objEntitlement.Route_To_Case_Owner__c != NULL)
                    {
                     lstUser = [Select id from user where name =: objEntitlement.Route_To_Case_Owner__c limit 1];
                     lstgroup = [select Id from Group where Name = : objEntitlement.Route_To_Case_Owner__c and Type = 'Queue' limit 1];
                     
                     
                    }
                    
                     if(objEntitlement.Route_to_Assigned_to__c != NULL)
                    {
                         lstUser1 = [Select id from user where id =: objEntitlement.Route_to_Assigned_to__c limit 1];
                       //  lstgroup1 = [select Id from Group where Name = : objEntitlement.Route_to_Assigned_to__c and Type = 'Queue' limit 1];
                         
                    }
                    
                    if(objEntitlement.Route_To_Case_Owner__c != NULL && objEntitlement.Route_to_Assigned_to__c != NULL)
                    {
                        if(lstUser.size() > 0)
                        {
                            objCase.OwnerID = lstUser[0].id;
                        }
                        if(lstUser.size() == 0 &&  lstgroup.size() > 0 )
                        {
                           
                            objCase.OwnerID = lstgroup[0].id;
                        }
                        if(lstUser.size() == 0 &&  lstgroup.size() == 0 )
                        {
                           
                            objCase.OwnerID = lstgroups[0].id;
                        }
                        
                        if( lstUser1.size() > 0)
                        {
                        
                            objCase.Assigned_to__c = lstUser1[0].id;
                         }
                         if( lstUser1.size() == 0)
                        {
                        
                            objCase.Assigned_to__c = null;
                         }
                    }
                    
                    if(objEntitlement.Route_To_Case_Owner__c != NULL && objEntitlement.Route_to_Assigned_to__c == NULL)
                    {
                        if(lstUser.size() > 0)
                        {
                            objCase.OwnerID = lstUser[0].id;
                        }
                        if(lstUser.size() == 0 &&  lstgroup.size() > 0 )
                        {
                           
                            objCase.OwnerID = lstgroup[0].id;
                        }
                        
                        if(lstUser.size() == 0 &&  lstgroup.size() == 0 )
                        {
                           
                            objCase.OwnerID = lstgroups[0].id;
                        }
                        
                        
                        
                            objCase.Assigned_to__c = Null;
                       
                    }
                    
                    if(objEntitlement.Route_To_Case_Owner__c == NULL && objEntitlement.Route_to_Assigned_to__c != NULL)
                    {
                        
                            objCase.OwnerID = lstGroups[0].id;
                        
                       
                        if( lstUser1.size() > 0)
                        {
                        
                            objCase.Assigned_to__c = lstUser1[0].id;
                         }
                         if( lstUser1.size() == 0)
                        {
                        
                            objCase.Assigned_to__c = null;
                         }
                    }
                    
                     if(objEntitlement.Route_To_Case_Owner__c == NULL && objEntitlement.Route_to_Assigned_to__c == NULL)
                    {
                        
                            objCase.OwnerID = lstGroups[0].id;
                            objCase.Assigned_to__c = Null;
                         
                    }
                         
                    }
                    }
                    }       
                             
                }
       
        }
                
              
                
     
   }
   
   
   
  /*  private static void fetchDefaultQueueId()
    {
    
        List<Group> lstGroups = [Select Id, Name 
                                 From Group Where Name = :DEFAULT_QUEUE  limit 1] ;
        if(lstGroups.size() > 0)
        {
            defaultQueueId = lstGroups[0].Id ;  
        }  
    } */
    
    //method to assign account and owner to case- new assignment process
  /*  public static void newProcessCasesToAssignOwnerAndAccount(List<Case> lstCases)
    {
    
        Id caseOwnerId;
        List<User> lstUser=new List<User>();
        List<Case_Owner_Assignment__c> lstCaseAssignmentRules = [Select Case_Owner_Id__c, 
                                                                 MAG__c, Region__c, Country__c 
                                                                 From Case_Owner_Assignment__c];
         Map<String,Case> mapCaseOwnerToCase = new Map<String,Case>();
         Map <Id,Account> mapIdToAccount = new Map<Id,Account> ( [Select Id, Name, Account_Manager_AMEC__c,                                                                    Account_Manager_EMEA__c, Account_Manager_GC__c,
                                                                    Account_Manager_Japan__c, Account_Manager_Korea__c,
                                                                    Account_Manager_Korea_2__c, Account_Manager_SAP__c,
                                                                    Account_Manager_SAP_2__c, Account_Manager_SAP_3__c,
                                                                    Service_Manager_AMEC__c,   Service_Manager_EMEA__c,
                                                                    Service_Manager_GC__c, Service_Manager_Japan__c,
                                                                    Service_Manager_Korea__c, Service_Manager_SAP__c, NXP_GID__c
                                                                    From Account ]);  
        List<Contact> lstContacts = new List<Contact>();

        for (case objCase : lstCases)
        {
            if(objCase.Case_Owner_Name__c != null && objCase.Case_Owner_Name__c.trim() != '')
            {              
                mapCaseOwnerToCase.put(objCase.Case_Owner_Name__c, objCase);            
            }  
        }
        
        fetchDefaultQueueId();                
        Account objAccTechnicalServices;
        Account objAccNXPCommunity;
        List<Account> lstAccTechnicalServices = [Select Id,Name From Account 
                                                Where Name='Technical Services' limit 1 ];
        if(lstAccTechnicalServices.size()>0)
        {
           objAccTechnicalServices =lstAccTechnicalServices.get(0); 
        }
        else
        {
          objAccTechnicalServices=null;  
        }
        List<Account> lstAccNXPCommunity = [Select Id,Name From Account 
                                            Where Name=: NXP_COMMUNITY limit 1 ];
        if(lstAccNXPCommunity.size()>0)
        {
           objAccNXPCommunity =lstAccNXPCommunity.get(0); 
        }
        else
        {
          objAccNXPCommunity=null;  
        }

        for(Case objCase: lstCases)
        {
            lstContacts=[select id,accountId,Account.owner.id from contact where id=: objCase.ContactId LIMIT 1];
            if(lstContacts.size()>0)
            {
                Contact objContact=lstContacts[0]; 
                if(objContact.AccountId!= objAccTechnicalServices.Id && objContact.AccountId!= objAccNXPCommunity.Id)
            {
                lstUser= [Select Id,Name from User where Id=: objContact.Account.owner.id and IsActive=true 
                          and Skip_Case_Assignment__c!=true LIMIT 1];
                if(lstUser.size()>0)
                {
                    caseOwnerId = defaultQueueId;
                    assignOwnerAndAccount(objCase, caseOwnerId,objContact.AccountId,mapIdToAccount);
                }
                else
                {
                    caseOwnerId = defaultQueueId;
                    assignOwnerAndAccount(objCase, caseOwnerId,objContact.AccountId,mapIdToAccount);
                } 
                
            }
            
            else if(objContact.AccountId== objAccTechnicalServices.Id || objContact.AccountId== objAccNXPCommunity.Id)
            { */
                /***************************************************************************************
                NOTE : NOT SURE ABOUT THE REQUIREMENT SO JUST KEPT THE CODE AS IT IS
                AND MIGHT NEED TO REWRITE THE CODE IN CLEANUP 
                ***************************************************************************************
                if ((objCase.MAG__c !=null|| objCase.MAG__c!='' )&&(objCase.Web_Region__c!=null || objCase.Web_Region__c!='')
                                &&(objCase.Web_Country__c!=null || objCase.Web_Country__c!='')) //case 4 : assignment rule
                {
                    for( Case_Owner_Assignment__c  objRule : lstCaseAssignmentRules) 
                    {                
                        if(objCase.MAG__c == objRule.MAG__c && objCase.Web_Region__c==objRule.Region__c)
                        {
                            if(objRule.Country__c!=null && objRule.Country__c!='')
                            {
                                if(objCase.Web_Country__c==objRule.Country__c)
                                {
                                    objCase.OwnerId=objRule.Case_Owner_Id__c;
                                    caseOwnerId = objCase.OwnerId;
                                } 
                            }
                            else
                            {
                                objCase.OwnerId=objRule.Case_Owner_Id__c;
                                caseOwnerId = objCase.OwnerId;
                            }
                        }
                    }
                }
                
                if(objContact.AccountId== objAccTechnicalServices.Id)
                {
                    objCase.AccountId= objAccTechnicalServices.Id;
                }
                
                else if(objContact.AccountId== objAccNXPCommunity.Id)
                {
                    objCase.AccountId= objAccNXPCommunity.Id;
                    
                }
                if(caseOwnerId==null)
                {
                    system.debug('+++casenot '+caseOwnerId);
                    objCase.OwnerId= defaultQueueId;
                }
                
            }
            }
            
                        
        } */
  
        /**************************************************************************************************************************************       
            NOTE - THE MERGED CODE FROM BEFORINSERT_CASE Trigger FROM LINE NO : 392 TO 447
         **************************************************************************************************************************************
            
            //Step 1 - First Search for User
           if(mapCaseOwnerToCase.size() > 0)
            {
                Map<String,Id> mapOwnerNameToId = new Map<String,Id>();
                
                for(User objUser : [Select Id , Name From User Where Name 
                                    in : mapCaseOwnerToCase.keySet() and IsActive =true ])
                {
                    mapOwnerNameToId.put(objUser.Name, objUser.Id);
                }
                
                Map<String,Case> mapQueueNameToCase = new Map<String,Case>();
                Set<String> queueNameSet = new Set<String>();
                
                for(String ownerName : mapCaseOwnerToCase.keySet())
                {
                    if(mapOwnerNameToId.containsKey(ownerName))
                    {
                        mapCaseOwnerToCase.get(ownerName).OwnerId = mapOwnerNameToId.get(ownerName);                       
                    }
                    else
                    {
                        mapQueueNameToCase.put(ownerName, mapCaseOwnerToCase.get(ownerName));
                        queueNameSet.add(ownerName);
                    }
                }
                
                //Step 2 - Search for Queue
                if(queueNameSet.size() > 0)
                {
                    queueNameSet.add(DEFAULT_QUEUE);
                    
                    Map<String,Id> mapQueueNameToId = new Map<String,Id>();
                    for(Group objGroup : [Select Id, Name From Group Where Type='Queue' and Name In :queueNameSet])
                    {
                        mapQueueNameToId.put(objGroup.Name,objGroup.Id);                        
                    }
                    
                    for(String ownerName : mapQueueNameToCase.keySet())
                    {                        
                        if(mapQueueNameToId.containsKey(ownerName))
                        {
                            mapQueueNameToCase.get(ownerName).OwnerId = mapQueueNameToId.get(ownerName);
                        }
                        else
                        {
                            mapQueueNameToCase.get(ownerName).OwnerId = mapQueueNameToId.get(DEFAULT_QUEUE);
                        }
                    }
                }
        } // end of for loop 
        

    }
   
    //Description : Method to assign Case OwerId, AccountId and NXP GID to cases  
    private static void assignOwnerAndAccount(Case objCase, Id ownerId,  Id accountId , 
                                              map <Id , Account> mapIdToAccount)
   {
   
       objCase.AccountId = accountId;
       if(mapIdToAccount.containsKey(accountId))
       {
            if(mapIdToAccount.get(accountId).NXP_GID__c != null)
            {
                objCase.Account_GID__c = mapIdToAccount.get(accountId).NXP_GID__c;  
            }           
       }
       if(ownerId !=null)
       {           
           objCase.OwnerId = ownerId;     
       }
       else
       {
           objCase.OwnerId= defaultQueueId;
       } 
   } */ 
public static void emailToCaseContactCheck(List<Case> lstCases)
    {
    Map<string,case> mapCaseEmail= new Map<string,case>();
    List<String> caseEmails=new List<String>();
    String[] strSendTo =new String[]{};
    Set<String> contactEmails=new Set<String>();
     string email=lstCases[0].SuppliedEmail;
    for(Case objCase : lstCases)        
        { 
             mapCaseEmail.put(objCase.SuppliedEmail,objCase);
             caseEmails.add(objCase.SuppliedEmail);       
        }  
    
    
     List<Contact> lstContact = [SELECT Id, Name, Email  FROM Contact WHERE Email = :mapCaseEmail.KeySet()];
     
     if(lstContact.size()>0)
     {
     for(Contact objContact : lstContact)
     contactEmails.add(objContact.email);
     }
     for(String objString :caseEmails)
     {
         if(!contactEmails.contains(objString))
         strSendTo.add(objString);
     }
     if(strSendTo.size()!=0)
     {
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      EmailTemplate objEmailTemplate=[Select Id, Name,DeveloperName From EmailTemplate 
                          Where DeveloperName ='Community_email_to_case_creation_Contact_not_found' limit 1];
      mail.setTemplateId(objEmailTemplate.id);
      mail.setToAddresses(strSendTo);
      OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where displayname='nxp technical support'];
      if( owea.size() > 0 ) 
        {
           mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
      mail.setTargetObjectId(UserInfo.getUserId());
      mail.setSaveAsActivity(false);
      mail.setTreatTargetObjectAsRecipient(False);
      mails.add(mail);
      Messaging.sendEmail(mails);
      for(String strCaseEmail : strSendTo)
      {
      mapCaseEmail.get(strCaseEmail).origin='UnknownContact';
      
      }
      
      
     }
     
    } 
@future
public static void DeleteCases()
     {
     try{
        delete [select id from case where origin='UnknownContact'];
        // delete listCase;
        }
         catch(DMLException e)
              {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during deletion'));     
                 
                }
     
     }
public static void fetchContactInfo(List<Case> lstCases)
{
set<id> setContactID = new set<id>();
for(Case objCase : lstCases)
{
setContactID.add(objCase.ContactID);
}

Map<id,Contact> mapContact = new map<id,Contact>([SELECT Id, Name, Email,Company__c,Community_web_country__c,Linkedin__c,Twitter__c,
                        FirstName,State_Province__c,Web_Region__c,LastName,Phone,Job_Title__c,Facebook__c FROM Contact WHERE Id in: setContactID]);
for(Case objCase : lstCases)        
        { 
        
        System.debug('Contact Id****************insude if*********'+ objcase.contactID);
             objCase.Community_Web_Country__c=mapContact.get(objCase.contactID).Community_web_country__c;
                    
          objCase.Company__c=mapContact.get(objCase.contactID).Company__c;
          
          objCase.Email__c= mapContact.get(objCase.contactID).Email;
          objCase.First_Name__c= mapContact.get(objCase.contactID).FirstName;
          objCase.Last_Name__c= mapContact.get(objCase.contactID).LastName;
          objCase.Phone_Number__c=mapContact.get(objCase.contactID).Phone;
          objCase.JobTitle__c= mapContact.get(objCase.contactID).Job_Title__c;
          objCase.Facebook__c=mapContact.get(objCase.contactID).Facebook__c;
          objCase.Linkedin__c=mapContact.get(objCase.contactID).Linkedin__c;
          objCase.Twitter__c=mapContact.get(objCase.contactID).Twitter__c;
          objCase.State_Province__c=mapContact.get(objCase.contactID).State_Province__c;
          objCase.Web_Region__c=mapContact.get(objCase.contactID).Web_Region__c;
        
}
}  

 public static void PSLIdentification(List<Case> listCases)
     {   
         String tempPSL;
         List<String> listProductLvl1=new List<String>();
         for(Case caseRec:listCases)
         listProductLvl1.add(caseRec.Product__c);
         set<product_service_level_criteria__c> listPSL=new set<product_service_level_criteria__c>
                                                             (
                                                             [select Product__c,Product_Category__c,Product_Sub__c,Product_Service_Level__c from product_service_level_criteria__c where Product__c in:listProductLvl1]
                                                             );
         for(case caseRec:listCases)    
         {
             tempPSL='';
             caseRec.Product_Service_Level__c='';
             if(listPSL!=null)
             {
             for(product_service_level_criteria__c PSLRec:listPSL)
               {
                 System.debug(' PSLRec:'+ PSLRec);
                 System.debug(' PSLRec.Product_Category__c:'+ PSLRec.Product_Category__c+':PSLRec.Product_Sub__c:'+PSLRec.Product_Sub__c);
                 if(PSLRec.Product__c==caseRec.Product__c)
                 {
                   if(PSLRec.Product_Category__c==caseRec.Product_Category__c && PSLRec.Product_Sub__c==caseRec.Product_Sub__c)
                   {
                         caseRec.Product_Service_Level__c=PSLRec.Product_Service_Level__c;
                         break;
                   }
                   if(PSLRec.Product_Category__c==caseRec.Product_Category__c && (PSLRec.Product_Sub__c==null || PSLRec.Product_Sub__c==''))
                     {
                          tempPSL=PSLRec.Product_Service_Level__c;
                          System.debug('Entered if-2:tempPSL::'+tempPSL);

                     }
                     if((PSLRec.Product_Category__c==null || PSLRec.Product_Category__c=='') && (tempPSL==null || tempPSL==''))
                     {
                         tempPSL=PSLRec.Product_Service_Level__c;
                   
                          System.debug('Entered if-3:tempPSL::'+tempPSL);
                     }
                 
                 }
               }//end of inner for
             if((caseRec.Product_Service_Level__c==null || caseRec.Product_Service_Level__c=='') && tempPSL!=null && tempPSL!='' )
               {
                
                     caseRec.Product_Service_Level__c=tempPSL;
                     System.debug('Entered if-4:tempPSL::'+tempPSL);
               
               }//end of if
            }//end of if
         }//end of outer for
     }//end of method
    
 public static void projectServiceLevelIdentification(List<Case> listCases)
  {   
      list<String> listId=new list<String>();
      set<String> setType=new set<String>();
      string PSLTemp;
      string PSLTemp1;
      
      
      map<id,Entitlement> mapEntitlement;//=new list<Entitlement>();
      list<Project_Service_Level_Criteria__c> listProjectSLC=new list<Project_Service_Level_Criteria__c>();
      
      for(case caseRec:listCases)
          listId.add(caseRec.EntitlementId);
      
      if(listId.size()!=0 && listId!=null)
          mapEntitlement=new map<id,Entitlement>([select id,Type,Entitlement_Sub_Type__c,Priority__c from Entitlement where id in:listId]);
      
    //  listString=new list<String>();
      for(case caseRec:listCases)
      {
          if(caseRec.EntitlementId!=null)
          setType.add(mapEntitlement.get(caseRec.EntitlementId).Type);
      }
      if(setType.size()!=0 && setType!=null)
          listProjectSLC=[select Type__c,Sub_Type__c,Priority__c,Project_Service_Level__c from Project_Service_Level_Criteria__c where Type__c in:setType];
      
      for(case caseRec:listCases)
      {
          PSLTemp='';
          caseRec.Project_Service_Level__c='';
          if(caseRec.EntitlementId!=null)
            {
                if((mapEntitlement.get(caseRec.EntitlementId).Type==null || mapEntitlement.get(caseRec.EntitlementId).Type=='')
                    && (mapEntitlement.get(caseRec.EntitlementId).Priority__c!=null && mapEntitlement.get(caseRec.EntitlementId).Priority__c!='')
                  )
                    {
                        caseRec.Project_Service_Level__c=mapEntitlement.get(caseRec.EntitlementId).Priority__c;
                    }
            
               else if(listProjectSLC.size()!=0 && listProjectSLC!=null && (mapEntitlement.get(caseRec.EntitlementId).Type!=null && mapEntitlement.get(caseRec.EntitlementId).Type!=''))
               {
                  for(Project_Service_Level_Criteria__c  PSLRec:listProjectSLC)
                   {
                      System.debug('Entitlement PSLRec:'+PSLRec);
                      
                          if(mapEntitlement.get(caseRec.EntitlementId).Type==PSLRec.type__c)
                          {    
                             if(mapEntitlement.get(caseRec.EntitlementId).Entitlement_Sub_Type__c==PSLRec.sub_type__c && mapEntitlement.get(caseRec.EntitlementId).Priority__c==PSLRec.Priority__c)
                             {
                                  caseRec.Project_Service_Level__c=PSLRec.Project_Service_Level__c;
                                  break;
                             }
                             System.debug('Entitlement_Sub_Type__c::'+mapEntitlement.get(caseRec.EntitlementId).Entitlement_Sub_Type__c);
                             System.debug('PSLRec.Priority__c::'+PSLRec.Priority__c);
                             System.debug('PSLRec.sub_type__c::'+PSLRec.sub_type__c);
                             if(mapEntitlement.get(caseRec.EntitlementId).Entitlement_Sub_Type__c==PSLRec.sub_type__c && PSLRec.Priority__c==null)
                             {
                                  PSLTemp=PSLRec.Project_Service_Level__c;
                             }
                              System.debug('2.PSLRec.sub_type__c::'+PSLRec.sub_type__c);
                            
                         
                             if(PSLRec.sub_type__c==null && PSLRec.Priority__c==mapEntitlement.get(caseRec.EntitlementId).Priority__c && (PSLTemp==null || PSLTemp==''))
                             {
                                  PSLTemp=PSLRec.Project_Service_Level__c;
                             }
                           
                              if(PSLRec.sub_type__c==null && PSLRec.Priority__c==null && (PSLTemp==null || PSLTemp==''))
                             {
                                  PSLTemp1=PSLRec.Project_Service_Level__c;
                             }
                          }
                       
                   }//End of inner for loop
                   if((caseRec.Project_Service_Level__c==null || caseRec.Project_Service_Level__c=='') && PSLTemp!=null && PSLTemp!='')
                       caseRec.Project_Service_Level__c=PSLTemp;
                   else if((caseRec.Project_Service_Level__c==null || caseRec.Project_Service_Level__c=='') && PSLTemp1!=null && PSLTemp1!='')  
                     caseRec.Project_Service_Level__c=PSLTemp1;
          }
       }
      }//End of outer for loop
     } 
     public static void caseServiceLevelIdentification(List<case> listcases)
     {
     Set<String> setCSL=new Set<String>();
     Set<String> setPSL=new Set<String>();
     Set<String> setProjectSL=new Set<String>();
     String tempCSL;
     String tempCSL1;
     List<Case_Service_Level_Criteria__c> listCSLC=new List<Case_Service_Level_Criteria__c>();
     
     
     for(Case caseRec:listcases)
     {
     if(caseRec.Contact_Service_Level__c!=null)
         setCSL.add('%'+caseRec.Contact_Service_Level__c+'%');
         
     if(caseRec.Product_Service_Level__c!=null)
         setPSL.add('%'+caseRec.Product_Service_Level__c+'%');
         
     if(caseRec.Project_Service_Level__c!=null)
         setProjectSL.add('%'+caseRec.Project_Service_Level__c+'%');
     
     }
     
     listCSLC=[select Contact_Service_Level__c,Product_Service_Level__c,Project_Service_Level__c,Case_Service_Level__c from Case_Service_Level_Criteria__c where  Contact_Service_Level__c Like :setCSL or Product_Service_Level__c like :setPSL or Project_Service_Level__c like :setProjectSL];
     system.debug('listCSLC::'+listCSLC);
     
     
    For(case caseRec:listCases)
    {
        caseRec.case_service_level__c='';
       If(listCSLC.size()!=0 && listCSLC!=null)
       {
            For(Case_service_level_criteria__c cslc:listCSLC)
            {
                if(caseRec.contact_service_level__c!=null && caseRec.contact_service_level__c!='')
                {
                    If(cslc.contact_service_level__c!=null && cslc.contact_service_level__c==caseRec.contact_service_level__c )
                     {
                        //combination 1:complete match found
                        If( cslc.product_service_level__c==caseRec.product_service_level__c &&cslc.project_service_level__c==caseRec.project_service_level__c)
                        {
                            caseRec.case_service_level__c=cslc.case_service_level__c;
                            Break;
                        }
                        //combination 2
                        System.debug('cslc.product_service_level__c:'+cslc.product_service_level__c);
                        System.debug('caseRec.product_service_level__c:'+caseRec.product_service_level__c);
                        System.debug('cslc.project_service_level__c:'+cslc.project_service_level__c);
                        
                        
                        If(cslc.product_service_level__c==caseRec.product_service_level__c && (cslc.project_service_level__c==null ||cslc.project_service_level__c==''))
                        {
                            //tempCSL=cslc.case_service_level__c;
                            caseRec.case_service_level__c=cslc.case_service_level__c;
                        }
                        //combination 3
                        If((cslc.product_service_level__c==null ||cslc.product_service_level__c=='') && (caseRec.case_service_level__c==null ||caseRec.case_service_level__c=='') && cslc.project_service_level__c==caseRec.project_service_level__c)
                        {
                            //tempCSL=cslc.case_service_level__c;
                            caseRec.case_service_level__c=cslc.case_service_level__c;
                        }
                        //combination 4
                        if((cslc.product_service_level__c==null ||cslc.product_service_level__c=='')&&(cslc.project_service_level__c==null ||cslc.project_service_level__c==''))
                        {
                            tempCSL1=cslc.case_service_level__c;
                        }
                
                     }//end of if()
                }//end of if()
                else
                 {
                 if(cslc.contact_service_level__c==null ||  cslc.contact_service_level__c=='')
                 {
                    if(cslc.project_service_level__c==caseRec.project_service_level__c && cslc.product_service_level__c==caseRec.product_service_level__c)
                        caseRec.case_service_level__c=cslc.case_service_level__c;
                    if((caseRec.case_service_level__c==null || caseRec.case_service_level__c=='')&&(cslc.project_service_level__c==null || cslc.project_service_level__c=='') && cslc.product_service_level__c==caseRec.product_service_level__c)
                        caseRec.case_service_level__c=cslc.case_service_level__c;
                    if((caseRec.case_service_level__c==null || caseRec.case_service_level__c=='')&&(cslc.project_service_level__c==caseRec.project_service_level__c) && (cslc.product_service_level__c==null || cslc.product_service_level__c==''))
                        caseRec.case_service_level__c=cslc.case_service_level__c;
                  }              
                }
           
           
            }//end of inner for()
            if((caseRec.case_service_level__c==null || caseRec.case_service_level__c=='') && (tempCSL1!=null || tempCSL1!=''))
            {
                caseRec.case_service_level__c=tempCSL1;
            }
       }//end of if()

    }//end of outer for()

     
  } 
  
  public static void casePriority(list<Case> listCases)
  {
      //CPC: Case_Priority_Criteria__c object 
      list<Case_Priority_Criteria__c> listCPC=[select Object__c,Field__c,Field_Value__c,Score__c from Case_Priority_Criteria__c];
      Map<String,list<Case_Priority_Criteria__c>> MapCPC=new Map<String,list<Case_Priority_Criteria__c>>();
    
      list<Id> listEntitlemtntIds=new list<Id>();
      
      for(Case caseRec:listCases)
       listEntitlemtntIds.add(caseRec.EntitlementId);
            
      map<Id,Entitlement> mapEntitlements=new map<Id,Entitlement>([select id,type,Entitlement_Sub_Type__c,priority__c from Entitlement where id in:listEntitlemtntIds]);
      list<Case_Priority_Criteria__c> listCasesCPC=new list<Case_Priority_Criteria__c>();
      list<Case_Priority_Criteria__c> listcontactsCPC=new list<Case_Priority_Criteria__c>();
      list<Case_Priority_Criteria__c> listEntitlementsCPC=new list<Case_Priority_Criteria__c>();
      double score=0;
      for(Case_Priority_Criteria__c CPCRec:listCPC)
      {
          if(CPCRec.Object__c=='Case')
          listCasesCPC.add(CPCRec);
          if(CPCRec.Object__c=='Entitlement')
          listEntitlementsCPC.add(CPCRec);
         // if(CPCRec.Object__c=='Contact')
          //listcontactsCPC.add(CPCRec);
      }
      
      
      for(Case caseRec:listCases)
       {
           system.debug('caseRec-1::::'+caseRec.createddate);
           caseRec.score__c=0;
           if((caseRec.Priority!=null && caseRec.Priority!='' && caseRec.Internal_Priority__c!=null && caseRec.Internal_Priority__c!='')||(caseRec.Product_Category__c!=null && CaseRec.Product_Category__c!='' ))
           {
               for(Case_Priority_Criteria__c CaseCPC:listCasesCPC)
               {
                   if(CaseCPC.field__c=='Origin' && caseRec.Origin!=null && CaseCPC.field_value__c==caseRec.Origin)
                        caseRec.score__c+=CaseCPC.Score__c;
                   System.debug('case origin:'+caseRec.Origin);
                   
                   //standard priority as a factor
                   if(CaseCPC.field__c=='Priority' && CaseCPC.field_value__c==caseRec.Priority)
                       caseRec.score__c+=CaseCPC.Score__c;
                   
                    //Internal priority as a factor for score calculation
                   if(CaseCPC.field__c=='Internal Priority' && CaseCPC.field_value__c==caseRec.Internal_Priority__c)
                       caseRec.score__c+=CaseCPC.Score__c;
                   
                   //product as a factor
                   if(caseRec.Product__c!=null && caseRec.Product__c!='')
                   {
                       if(CaseCPC.field__c=='Product Lvl 1' && CaseCPC.field_value__c==caseRec.Product__c)
                           caseRec.score__c+=CaseCPC.Score__c;
                   
                       if(CaseCPC.field__c=='Product Lvl 2' && caseRec.Product_Category__c!=null && CaseCPC.field_value__c==caseRec.Product_Category__c)
                           caseRec.score__c+=CaseCPC.Score__c;
                    
                       if(CaseCPC.field__c=='Product Lvl 3' && caseRec.Product_Sub__c!=null && CaseCPC.field_value__c==caseRec.Product_Sub__c)
                           caseRec.score__c+=CaseCPC.Score__c;
                   }
                   
                   //contact service level as factor
                   if(caseRec.Contact_Service_Level__c!=null && caseRec.Contact_Service_Level__c!='')
                   {
                   if(CaseCPC.field__c=='Contact Service Level' && CaseCPC.field_value__c==caseRec.Contact_Service_Level__c)
                   caseRec.score__c+=CaseCPC.Score__c;
                   }
                   
           
               }
           }
           
          //entitlement's type,subtype and priority fields are considered as score factors
            if(caseRec.EntitlementId!=null)
           {
               for(Case_Priority_Criteria__c CaseCPC:listEntitlementsCPC)
               {
                   if(mapEntitlements.get(caseRec.EntitlementId).type!=null && mapEntitlements.get(caseRec.EntitlementId).type!='')
                   {
                       if(CaseCPC.field__c=='Type' && CaseCPC.field_value__c==mapEntitlements.get(caseRec.EntitlementId).type)
                       caseRec.score__c+=CaseCPC.Score__c;
                       system.debug('caseRec.score__c::'+caseRec.score__c);
                   }
                   if(mapEntitlements.get(caseRec.EntitlementId).Entitlement_Sub_Type__c!=null && mapEntitlements.get(caseRec.EntitlementId).Entitlement_Sub_Type__c!='')
                   {
                       //system.debug('')
                       if(CaseCPC.field__c=='Sub Type' && CaseCPC.field_value__c==mapEntitlements.get(caseRec.EntitlementId).Entitlement_Sub_Type__c)
                       caseRec.score__c+=CaseCPC.Score__c;
                   }
                   if(mapEntitlements.get(caseRec.EntitlementId).Priority__c!=null && mapEntitlements.get(caseRec.EntitlementId).priority__c!='')
                   {
                       //system.debug('')
                       if(CaseCPC.field__c=='Ent-Priority' && CaseCPC.field_value__c==mapEntitlements.get(caseRec.EntitlementId).priority__c)
                       caseRec.score__c+=CaseCPC.Score__c;
                   }
               }
           }
          
     /*  if(caseRec.score__c>=1000)
       caseRec.Priority='Critical';
         if(caseRec.score__c>=800 && caseRec.score__c<1000 )
       caseRec.Priority='High';
         if(caseRec.score__c>=600 && caseRec.score__c<800)
       caseRec.Priority='Medium';
         if(caseRec.score__c<600)
       caseRec.Priority='Low';
      */ 
       System.debug('caseRec::'+caseRec);
       }
      
 // update listCases;
  
  }
    public static void CalculateDueDate(list<Case> listCasesNew,map<id,Case> MapCasesOld) 
  {    
     boolean matchfound=false;
     Integer tempPriority1=0;
     base_value_for_case_priority_calculation__c Objbase= base_value_for_case_priority_calculation__c.getValues('Base');
     base_value_for_case_priority_calculation__c ObjZeroScore=base_value_for_case_priority_calculation__c.getValues('Negative_Zero_Score_Hours');
     list<caseHistory> listcaseHistory=new list<caseHistory>();         
     map<id,case> mapCaseshistory=new map<id,case>([select id,status, (select field,OldValue, NewValue from Histories where field=:'status')from Case where id in:listCasesNew]);
    
     for(case caseRec:listCasesNew)
     { //system.debug('caseRec-1::::'+caseRec.createddate);
        matchfound=false;
        listcaseHistory=mapCaseshistory.get(caseRec.id).histories;
        system.debug('listcaseHistory::'+listcaseHistory);
         if( MapCasesOld.get(caseRec.id)!=null) 
         {
         //calculate due date when priority changes
             if(caseRec.priority!=null && caseRec.priority!='' )
             {
             system.debug('map old priority::'+MapCasesOld.get(caseRec.id).priority);
             system.debug('map old :'+MapCasesOld.get(caseRec.id));
             
             system.debug('caseRec.priority::'+caseRec.Internal_Priority__c);
                 if(caseRec.Internal_Priority__c!=MapCasesOld.get(caseRec.id).Internal_Priority__c)
                 {
                 
                     for(caseHistory caseHistoryRec:listcaseHistory)
                     {
                     
                     if(caseHistoryRec.oldvalue=='Pending Internal' ||caseHistoryRec.newvalue=='Pending Internal' ||
                         caseHistoryRec.oldvalue=='Pending Customer Reply' ||caseHistoryRec.newvalue=='Pending Customer Reply' ||
                         caseHistoryRec.oldvalue=='Received Reply' ||caseHistoryRec.newvalue=='Received Reply')
                         {
                         matchfound=true;
                         break;
                 
                         }
                         
               }
               system.debug('caseRec.score__c::'+caseRec.score__c);
               if(Objbase!=null)
               {
               if(matchfound==false && Objbase.base_value__c!=null)
               {
                if(caserec.score__c<=0 && ObjZeroScore!=null)
                 {
                     
                      caseRec.due_Date__c=System.now().addHours((Integer)ObjZeroScore.base_value__c);
                 }
                 else
                 {
                       caseRec.due_Date__c=caserec.createddate.addhours((Integer) Math.ceil(Objbase.base_value__c/caserec.score__c));
                       system.debug(caseRec.due_Date__c);
                 }
               }
               }
           }
         }
         //calculate due date when status changes
           if(caseRec.status!=MapCasesOld.get(caseRec.id).status && caseRec.status=='Pending Customer Reply')
             caseRec.due_Date__c=system.now().addhours(84);
           if(caseRec.status!=MapCasesOld.get(caseRec.id).status && caseRec.status=='Pending Internal')
             caseRec.due_Date__c=system.now().addhours(72);    
           if(Objbase!=null)
               {
                
                  if(caseRec.status!=MapCasesOld.get(caseRec.id).status && caseRec.status=='Received Reply' && Objbase.base_value__c!=null)
                  {
                      if(caserec.score__c<=0 && ObjZeroScore!=null)
                       {
                          if(ObjZeroScore.base_value__c!=null)
                          {
                          caseRec.due_Date__c=System.now().addhours((Integer) Math.ceil(ObjZeroScore.base_value__c/2));
                          }
                       }
                      else
                       {
                           caseRec.due_Date__c=system.now().addhours((Integer) Math.ceil((Objbase.base_value__c/caserec.score__c)/2));
                       }
          //   caseRec.due_Date__c=system.now()+(((Objbase.base_value__c/caserec.score__C)/2))/1440; 
                  }         
            }     
                        
         
       }
     }
  }
 public static void EntitlementIdentificationForCases(list<case> listCases)
 {
   //  str.substringAfter('-')
   //Pattern objPattern1;
  // Matcher objMatcher1;
   // Pattern objPattern2;
    string strUniqueIdentifier;
    //string strUniquePattern;
    //Matcher objMatcher2;
    list<Entitlement> listEntitlement=new list<Entitlement>();
     map<string,id> mapPattern=new map<string,id>();
     list<string> listPattern=new list<string>();
     map<id,string> mapCasePattern=new map<id,string>();
     for(case caseRec:listCases)
     {
        if(caseRec.Description!=null && caseRec.Description!='' )//&& caseRec.Description.contains(label.Community_unique_pattern_for_email_service+'[a-z|A-Z|0-9]{1,8}[0-9]{6}'))
        {
        //system.debug(substringAfter(label.Community_unique_pattern_for_email_service.indexof('context::',0)+9));
          //objPattern1= Pattern.compile(label.Community_unique_pattern_for_email_service+'[a-z|A-Z|0-9]{1,8}[0-9]{6}');
          
          Pattern objPattern1= Pattern.compile('[CONTEXT::|context::][a-z|A-Z|0-9]{1,8}[0-9]{6}');
          
           //objPattern1= Pattern.compile(label.Community_unique_pattern_for_email_service+'[a-z]{1,8}[0-9]{6}');
           
         Matcher objMatcher1= objPattern1.matcher(caseRec.Description);
           System.debug(objMatcher1);
          // Boolean result = MyMatcher.find();
          
           //system.debug(objMatcher1.find());
           if(objMatcher1.find())
           {
           // system.debug(objMatcher1.find());
            strUniqueIdentifier=objMatcher1.group(0);
           }
           Pattern objPattern2= Pattern.compile('[a-z|A-Z|0-9]{1,8}[0-9]{6}');
          
           //objPattern2= Pattern.compile('[a-z]{1,8}[0-9]{6}');
           System.debug(strUniqueIdentifier);
           Matcher objMatcher2;
           if(strUniqueIdentifier!=null)
           {
           objMatcher2= objPattern2.matcher(strUniqueIdentifier);
           }
           
           if(objMatcher2!=null && objMatcher2.find(1))
           {
           //strUniquePattern=objMatcher2.group(0);
           system.debug('strUniquePattern'+objMatcher2.group(0));
           //mapPattern.put(caseRec.id,strUniquePattern);
           mapCasePattern.put(caseRec.id,objMatcher2.group(0));
           system.debug(mapCasePattern);
           listPattern.add(objMatcher2.group(0));
           }
       
       // mapPattern.put(caseRec.id,substringAfter(indexof(label.Community_unique_pattern_for_email_service)+9)))
        
        }
     }//end of for
     system.debug(mapCasePattern);
     if(listPattern.size()!=0 && listPattern!=null)
     {
        // listEntitlements=[select id,Entitlement_Pattern__c from entitlement where Entitlement_Pattern__c in: listPattern];\
         for(Entitlement entRec:[select id,Entitlement_Pattern__c from entitlement where Entitlement_Pattern__c in:listPattern])// mapCasePattern.values()])
         {
             mapPattern.put(entRec.Entitlement_Pattern__c,entRec.id);
     
         }
     }
     for(case caseRec:listCases)
     {
         caseRec.EntitlementId=null;
         if(mapPattern!=null)
         {
     
             for(string pattern:listPattern)
               {
                   if(caseRec.description!=null && caseRec.description!='' && caseRec.description.contains(pattern))
                   {
                   caseRec.EntitlementId=mapPattern.get(pattern);
                   break;
                   }
               }
               /*if(mapCasePattern.get(caseRec.id)!=null && mapPattern.containsKey(mapCasePattern.get(caseRec.id)))
               {
                   caseRec.EntitlementId=mapPattern.get(mapCasePattern.get(caseRec.id));
               }
              */
         }
     }
 }
     
}