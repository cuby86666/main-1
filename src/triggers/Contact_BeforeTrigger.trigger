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
trigger Contact_BeforeTrigger on Contact (before insert,before update) 
{
    if(Trigger.isInsert)
    {
        ContactClass.CSLIdentification(trigger.new);

    }
       
    else{
        List<Contact> updatedCase = new List<Contact>();
        for(Contact c : Trigger.new)
            {
                if(c.email != Trigger.oldMap.get(c.Id).Email || 
                    c.AccountId != Trigger.oldMap.get(c.Id).AccountId){
                   updatedCase.add(c); 
            }
            }
        ContactClass.CSLIdentification(updatedCase);
        
        
        //convertISONameToFullName
        List<Contact> ISONameToFullName = new List<Contact>();
        for(Contact c : Trigger.new)
            {
                if(c.Mailingcountry!=null){
                    if(c.Mailingcountry!= Trigger.oldMap.get(c.Id).Mailingcountry || c.MailingCountry.Length()==3 ){
                        ISONameToFullName.add(c); 
                }
            }
            }
        if(!ISONameToFullName.isEmpty())
            {
                ContactClass.convertISONameToFullName(ISONameToFullName );
            }
        }
    
    System.debug('trigger.new:::'+trigger.new);
}