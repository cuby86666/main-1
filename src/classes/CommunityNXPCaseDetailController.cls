/****************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     13 September 2016
Description :      controller class for Case detail page
******************************************************************************/
/*****************************************************************************
@Modified By :  Anil Somani
@Modified Date: 25 May 2018
Description :   Showing case details only to case owner as part SFDC-1652
******************************************************************************/

Public without sharing class CommunityNXPCaseDetailController{
    
    public Case caseRecord   {set;get;}
    public List<emailMessage> lstEmailMsgs{set;get;}
    public List<Attachment>  lstAttachment{set;get;}
   // public string caseCommnetBody{get;set;}
    public String emailIdOFLoggedInUser{get;set;}
    
      public Boolean caseVisibleToUser{get;set;}
      public String allFlags{get;set;}
      
    public void assignCaseRecord(){
       Id caseId = ApexPages.currentPage().getParameters().get('caseId');
       System.debug('^^^'+caseId);
       caseRecord = [SELECT    contactId, status, subject, createdDate,EntitlementId, Entitlement.Name, ClosedDate,caseNumber, Product__c, Product_Category__c, Product_Sub__c,
                                  Product_application__c,Project_Stage__c,Expected_annual_unit_volume__c,Priority ,Sub_Topic__c,description,first_name__c, last_name__c,email__c,phone_number__c,
                                  community_Web_Country__c,Hours_spent_by_Support_person__c,State_Province__c,Web_Region__c,Nature_of_Question__c,
                                  company__c,jobtitle__c,Product_Type_Number__c,My_Question_is_Related__c,
                                  (Select commentbody From CaseComments where (IsPublished = true and (commentbody!=null and commentbody!='')) ORDER By LastModifiedDate DESC LIMIT 1) from Case where id =:caseId];
       
       lstEmailMsgs = [Select id,parentid,TextBody,subject,htmlbody,fromaddress,toaddress,createdDate from emailmessage 
                        where parentid=:caseRecord.id order by createddate DESC];
                        
       lstAttachment = [select id,createddate,bodylength,name from Attachment where parentId=:caseRecord.id ];     
    
    
    
      //------------------------Showing case details only to case owner----------------------------------
       
       // - check logged in user's contact record 
       emailIdOFLoggedInUser = UserInfo.getUserEmail();
       Contact tContact = [Select Id,email,account.name from Contact where email =:emailIdOFLoggedInUser ];
       
       allFlags = (tContact.account.name!='NXP Community')+' -- '+(caseRecord.contactid==tcontact.id);
       if(tContact.account.name!='NXP Community')
       {
          caseVisibleToUser=true;
       }
       else if(caseRecord.contactid==tcontact.id)
       {
          caseVisibleToUser=true;
       }
       else if(caserecord.EntitlementId!=null)
       {
          List<Entitlement_Contact__c> ec=[SELECT Id,Name,Entitlement__c from Entitlement_Contact__c WHERE Entitlement__c =:caseRecord.entitlementid and Status__c != 'Rejected' AND contact__r.email =:emailIdOFLoggedInUser];       
          if(ec.size()>0)
          {
             caseVisibleToUser=true;    
          } 
          allFlags = (tContact.account.name!='NXP Community')+' -- '+(caseRecord.contactid==tcontact.id)+' -size-'+ec.size(); 
       }
       

    } 
}