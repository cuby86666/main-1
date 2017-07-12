/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     13 September 2016
Description :      controller class for Case detail page
****************************************************************************************************/

Public without sharing class CommunityNXPCaseDetailController{
    
    public Case caseRecord   {set;get;}
    public List<emailMessage> lstEmailMsgs                                                         {set;get;}
    public List<Attachment>  lstAttachment                                                         {set;get;}
   
    public void assignCaseRecord(){
        
       
       Id caseId = ApexPages.currentPage().getParameters().get('caseId');
       System.debug('^^^'+caseId);
       caseRecord = [SELECT     status, subject, createdDate,EntitlementId, Entitlement.Name, ClosedDate,caseNumber, Product__c, Product_Category__c, Product_Sub__c,
                                  Product_application__c,Project_Stage__c,Expected_annual_unit_volume__c,Priority ,Sub_Topic__c,description,first_name__c, last_name__c,email__c,phone_number__c,
                                  community_Web_Country__c,Hours_spent_by_Support_person__c,State_Province__c,Web_Region__c,Nature_of_Question__c,
                                  company__c,jobtitle__c,Product_Type_Number__c,My_Question_is_Related__c from Case where id =:caseId];
       
       lstEmailMsgs = [Select id,parentid,TextBody,subject,htmlbody,fromaddress,toaddress,createdDate from emailmessage 
                        where parentid=:caseRecord.id order by createddate DESC];
                        
       lstAttachment = [select id,createddate,bodylength,name from Attachment where parentId=:caseRecord.id ];                  
       
    }
}