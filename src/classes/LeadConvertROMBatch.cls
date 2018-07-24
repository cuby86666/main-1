/*************************************************************************
@Created By:     Jewelslyn
@Description:    class for Lead Conversion using Feedback loop Logic
**************************************************************************/

/*************************************************************************
@Modified By:     Jewelslyn
@Modified Date:   24 Sep 2017
@Description:    Modified class to include TMMA Leads
**************************************************************************/
/*************************************************************************
@Modified By:    Harish Gowda
@Modified Date:   16 JUN 2017
@Description:    Modified class to allow conversion of Leads for Currency ISO diferrence(SFDC-1620)
**************************************************************************/
global class LeadConvertROMBatch implements Database.Batchable<Lead>  {
    global Iterable<Lead> start(Database.BatchableContext bc) {
        List<Lead> listLds = new List<Lead>([select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,FirstName,
                                         Distributor_Tracking_Number__c,RecordTypeId,Account_Id__c,Description,street,city,
                                         country,state,company,PostalCode,LastName,Manual_Update_Check__c,CreatedDate,CurrencyIsoCode 
                                         from lead where (recordtype.name ='ROM Leads' Or recordtype.name = 'TMMA Leads' or recordtype.name = 'Assigned Account Leads')
                                                          and (status='Accepted by Disti' or status='Contacted') ]);
                                                                                    
        return listLds;
    }
    global void execute(Database.BatchableContext BC, list<Lead> scope){
        list<Lead> listRomLeads= (list<Lead>)scope;   
        LeadConvertROMHandler leadConvert=new LeadConvertROMHandler();
        LeadConvertROMHandler.convertLead(listRomLeads);
    }
    global void finish(Database.BatchableContext BC){
        
    }

}