/*********************************************************************
Created by  : Shridevi Badiger
Created date: 20-Oct-2016
Description : SIR 1329-Populate value for Contact Service Level field.

**********************************************************************/

/*****************************************************************************************
@Modified By :   Ranganath C N
@Modified Date:  22 Mar 2018
@Description:    To Convert ISO-3 country values to full country names as part of SFDC-1387. 
*******************************************************************************************/


/*************************************************************************************************************
@Modified By :   Harish Gowda N.
@Modified Date:  22 May 2018 and on 14-06-2018 and on 20 aug 2018 and on 03 Oct 2018
@Description:  on 22 may  To Update User region of a contact based on the Community web country as part of SFDC-1611.
@Description:  on 16 june To Update CSL in Contact whenever csl sriterias are changed based on Contact service Level Criteria Batch as a part of SFDC-1757.  
@Description:  on 20 aug Logic To update community web country based on the mailing country (3 letter code) and to update User Region based on the community web country full country name .  
@Description:  on 03 Oct 2018 SFDC-1757-Job for CSL seems to be not executed properly.
**************************************************************************************************************/
trigger Contact_BeforeTrigger on Contact (before insert,before update) 
{
    if(Trigger.isInsert)
    {
        ContactClass.CSLIdentification(trigger.new);
        ContactClass.convertISONameToFullName(trigger.new );

    }
       
    else{
        List<Contact> updatedCase = new List<Contact>();
        for(Contact c : Trigger.new)
            {
                if(c.email != Trigger.oldMap.get(c.Id).Email  || c.AccountId != Trigger.oldMap.get(c.Id).AccountId 
                || c.contact_service_level__c == ''
                ){
                   updatedCase.add(c); 
            }
                         

            }
            
            
           
        ContactClass.CSLIdentification(updatedCase );
        System.debug ('CSL4 : ' + updatedCase );
        
        //convertISONameToFullName
        List<Contact> ISONameToFullName = new List<Contact>();
        for(Contact c : Trigger.new)
            {
                if(c.Mailingcountry!=null){
                    if(c.Mailingcountry!= Trigger.oldMap.get(c.Id).Mailingcountry && c.MailingCountry.Length()==3 ){
                        ISONameToFullName.add(c); 
                }
            }
            }
        if(!ISONameToFullName.isEmpty())
            {
                ContactClass.convertISONameToFullName(ISONameToFullName );
            } 
        } 
  //added as a part of SFDC-1611, Method to update region based on the country from Hub foundation      
     
   ContactClass.AssignRegionByCountryForContact(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);  
  // ContactClass.convertISONameToFullName(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
    
    System.debug('trigger.new:::'+trigger.new);
}