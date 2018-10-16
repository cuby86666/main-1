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
/*****************************************************************************
@Modified By :  Gunjan Singh
@Modified Date: 25 July 2018
Description :   Showing attachment section along with Delete option as part SFDC-1765/SFDC-2077
******************************************************************************/

Public without sharing class CommunityNXPCaseDetailController{
    
    public Case caseRecord   {set;get;}
    public List<emailMessage> lstEmailMsgs{set;get;}
    public List<Attachment>  lstAttachment{set;get;}
    public List<Attachment> caseAttachments{get;set;}   // to capture attachment on the case detail page added as part of SFDC-1765
   // public string caseCommnetBody{get;set;}
    public String emailIdOFLoggedInUser{get;set;}
    public List<Entitlement_Contact__c> lstEntitlContact{get;set;} // to capture entitlement contact added as part of SFDC-1765
    public List<String> lstEntitlContEmail{get;set;} // to capture entitlement contact email added as part of SFDC-1765
    public Boolean caseVisibleToUser{get;set;}
    public String allFlags{get;set;}
    public String deleteAttachId{get;set;} // to delete attachment on the case detail page added as part of SFDC-1765
    public String createdBy{get;set;} // to get the email of user who has created the case added as part of SFDC-1765
    public Boolean displayPopup {get;set;} //  to display the popup on click of Delete Link added as part of SFDC-1765
    public String folderCreatedBy{get;set;} // to get the email of user who has created the folder added as part of SFDC-1765
    private boolean isError = false;
   
   
    public CommunityNXPCaseDetailController(){
        //Added as part of SFDC-1765
        
        caseAttachments = new List<Attachment>();
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
        
        system.debug('Value of deleteAttachId is:   '+ deleteAttachId);
        lstEntitlContEmail = new List<String>();
        assignCaseRecord();
        
    
    }
    
    //Added as part of SFDC-1765
    public void deleteAttachment(){
        system.debug('Value of deleteAttachId is:   '+ deleteAttachId);
        Attachment att = new Attachment(id=deleteAttachId);
        delete att;
        displayPopup = false;
        assignCaseRecord();     
    }
    
    //Added as part of SFDC-1765
    public pageReference uploadAttachment(){
        system.debug('Inside upload Attachments');
        List<Attachment> attachments = new List<Attachment>();
        for(Attachment caseAttachment : caseAttachments){
            if(caseAttachment.body != null){
                if(!Test.isRunningTest()){
                    caseAttachment.parentId = caseRecord.id;
                }
                attachments.add(caseAttachment);
                caseRecord.status = 'Received Reply';
            
            }
        }
        
        if(!attachments.isEmpty()){
               
            try{
               Database.insert(attachments); 
               if(caseRecord.Assigned_to__c != Null){
                   Database.update(caseRecord);
               } 
              
            }
            catch(Exception e){
              system.debug('Exception is '+ e);
            
            }
            finally {
              caseAttachments = new List<Attachment>();
              caseAttachments.add(new Attachment());
              caseAttachments.add(new Attachment());
              caseAttachments.add(new Attachment());
              caseAttachments.add(new Attachment());
              caseAttachments.add(new Attachment());
            }
            
            system.debug('Vaue of isError '+ isError);
        }
        
        assignCaseRecord();
        return ApexPages.currentPage().setRedirect(true);
    
    }
    
    //Added as part of SFDC-1765
    public void showPopup()
    {   
        system.debug('displayPopup value is' +displayPopup );
        displayPopup = true;
        assignCaseRecord();
    }
    
    //Added as part of SFDC-1765
    public void closePopup()
    {
         displayPopup = false;
         assignCaseRecord();
    }
    
  
    public void assignCaseRecord(){
       isError = false;
       lstEntitlContEmail = new List<String>();
       Id caseId = ApexPages.currentPage().getParameters().get('caseId');
       System.debug('^^^'+caseId);
       if(caseId!=null){
       caseRecord = [SELECT contactId, status, Assigned_to__r.Email, Email_Contact__c,subject, createdDate,EntitlementId,Entitlement.CreatedBy.Email, Entitlement.Name, ClosedDate,caseNumber, Product__c, Product_Category__c, Product_Sub__c,
                                  Product_application__c,Project_Stage__c,Expected_annual_unit_volume__c,Priority ,Sub_Topic__c,description,first_name__c, last_name__c,email__c,phone_number__c,
                                  community_Web_Country__c,Hours_spent_by_Support_person__c,State_Province__c,Web_Region__c,Nature_of_Question__c,
                                  company__c,jobtitle__c,Product_Type_Number__c,My_Question_is_Related__c,CreatedBy.Email,
                                  (Select commentbody From CaseComments where (IsPublished = true and (commentbody!=null and commentbody!='')) ORDER By LastModifiedDate DESC LIMIT 1) from Case where id =:caseId];
       }                           
      
       //Modified as part of SFDC-1765
       if(caseRecord !=null){  
           createdBy = caseRecord.Email_Contact__c;
           folderCreatedBy = caseRecord.Entitlement.CreatedBy.Email;
           system.debug('Value of createdBy '+ createdBy );
           system.debug('Value of createdBy '+ folderCreatedBy );
           lstEmailMsgs = [Select id,parentid,TextBody,subject,htmlbody,fromaddress,toaddress,createdDate from emailmessage 
                            where parentid=:caseRecord.id order by createddate DESC];
         
           //Modified as part of SFDC-1765  
                      
           lstAttachment = [select id,createddate,bodylength,name,createdBy.Email,createdBy.FirstName from Attachment where parentId=:caseRecord.id ];
           
           //Added as part of SFDC-1765
           
           lstEntitlContact =[Select id,Contact__r.Email,Entitlement__r.Id,Status__c,Type__c from Entitlement_Contact__c where Entitlement__r.Id = :caseRecord.EntitlementId AND (Type__c='Observer' OR Type__c='Participant')];
           
           for(Entitlement_Contact__c  objEntCont: lstEntitlContact )
           {
               lstEntitlContEmail.add(objEntCont.Contact__r.Email);
           }
        
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
}