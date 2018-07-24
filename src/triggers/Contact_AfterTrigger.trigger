/*********************************************************************************************
@Created By :       Prakhar Gupta
@Created Date:      26 Nov 2014
@Description:       Trigger to set assign Contact to those case whose supplied email is null                   
********************************************************************************************/
/*
Modified By: Vinanthi
Created Date :8 Nov 2016
Description: Modifeid as per SIR 1318 which updates case fields as per contact record.
*/
/*
Modified By: Shridevi
Created Date :30 May 2017
Description: Modified as per SIR 439 to avoid updating the case fields if there is no change in contact fields 
*/
/*
Modified By: Shridevi
Created Date :25 Aug 2017
Description: As per SIR 828- Removed the functionality on AfterInsert event since it is not required.
*/
/***************************************************************************************************
@Modified By :      Harish Gowda N.
@Modified Date:     06 Jul 2018
@Description:       SFDC-1761 mapping between "Title"(Contact field) to "Contact Title "(Case Field).
**********************************************************************************************************/
trigger Contact_AfterTrigger on Contact (after insert,after update) 
{
    Private Final String CASE_TSCOMMUNITY = 'TS_Community';
    Private Final String Case_Origin = 'Self Service Portal';
    

 if(trigger.isUpdate){
 Map<id,Contact> mapContact = new map<id,Contact>();
 
 for(Contact objContact : trigger.new)
 {
 
 if((trigger.oldmap.get(objContact.id).Community_web_country__c!=objContact.Community_web_country__c)
 ||(trigger.oldmap.get(objContact.id).Company__c!=objContact.Company__c)
 ||(trigger.oldmap.get(objContact.id).Email!=objContact.Email)
 ||(trigger.oldmap.get(objContact.id).FirstName!=objContact.FirstName)
 ||(trigger.oldmap.get(objContact.id).LastName!=objContact.LastName)
 ||(trigger.oldmap.get(objContact.id).Phone!=objContact.Phone)
 ||(trigger.oldmap.get(objContact.id).Job_Title__c!=objContact.Job_Title__c)
 ||(trigger.oldmap.get(objContact.id).Linkedin__c!=objContact.Linkedin__c)
 ||(trigger.oldmap.get(objContact.id).Twitter__c!=objContact.Twitter__c)
 ||(trigger.oldmap.get(objContact.id).State_Province__c!=objContact.State_Province__c)
 ||(trigger.oldmap.get(objContact.id).Web_Region__c!=objContact.Web_Region__c)
 ||(trigger.oldmap.get(objContact.id).Title!=objContact.Title)
 )
 {
    mapContact.put(objContact.id,objContact);
 }
 }
 System.debug(mapContact);
if(!(mapContact.isEmpty() || mapContact == null))
{
     List<Case> lstCases=[select id,contactID,Community_Web_Country__c,company__c,First_Name__c,Email__c,Web_Region__c,Last_Name__c,State_Province__c,Phone_Number__c,Linkedin__c,Twitter__c,Contact_Title__c FROM case where contact.id in: trigger.new ];
     for(Case objCase : lstCases)
     {
          if(mapContact.containskey(objCase.contactId))
          {
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
              objCase.Contact_Title__c=mapContact.get(objCase.contactID).Title;
         
          }
     }
     try
     {
         Update lstCases;
     }
     catch(DMLException e)
              {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during update'));     
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        // Process exception here
                        System.debug(e.getDmlMessage(i));
                        if(Trigger.newMap.get(e.getDmlId(i)) !=null)
                            Trigger.newMap.get(e.getDmlId(i)).addError(e.getDmlMessage(i));
                    }                    
                 
                }
  }
}
 
}