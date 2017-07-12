/********************************************************************************************
@Modified By :     Jewelslyn Shama
@Modified Date :   23 Nov 2016
@Description :     Modified As part of SFDC 119 to handle 'Apex Heap size limit Exception'
***********************************************************************************************************
@Modified By :     Baji
@Modified Date :   16 Mar 2017
@Description :     Modified as part of SFDC 363(Update SAP CMD - funloc under multiple Sales Orgs - to update General Data at once)
***********************************************************************************************/

public class SAP_CMD_Request_Trigger {

    public static List<SAP_CMD_Request__c> lstSapCmdRequest; 
    public static List<SAP_CMD_Request__c> lstNewSapCmdRequest;
    public static List<CMD_Request__c> lstCmdRequest;
    public static Set<String> setSapCmdIds = new Set<string>();
    public static Set<String> setCmdRequestIds = new set<string>();
    public static Map<Id, CMD_Request__c> mapCmdRequest;
    public static Boolean isFirstTime = true;
    
    //Method to Fetch CMD request Records and SAP CMD Request Records
    public static Void fetchSapCmdRequestRecords(list<SAP_CMD__c> lstSapCmd)                                                   
    {
        for(SAP_CMD__c sapcmd:lstSapCmd)
        {
            setSapCmdIds.add(sapcmd.id);
            setCmdRequestIds.add(sapcmd.CMD_Request_Id__c);
        }
        
        lstSapCmdRequest = [SELECT  Id, CMD_Request__c, SAP_CMD__c, Approval_Status__c, Pending_Approver__c,
                              Pending_Approval_Since__c FROM SAP_CMD_Request__c where SAP_CMD__c=:setSapCmdIds
                               And CMD_Request__c=:setCmdRequestIds];
                        
        mapCmdRequest=new Map<Id, CMD_Request__c>([SELECT Id,Funloc_SAP_CMD__c, CreatedById, 
                                                Status__c FROM CMD_Request__c where id=:setCmdRequestIds]);                                                                                                                                              
    }
           
    // Method to insert SAP CMD request Records if record don't exist
    public static void upsertSAP_CMD_Request(list<SAP_CMD__c> lstSapCmd)
    {
        fetchSapCmdRequestRecords(lstSapCmd);
        lstNewSapCmdRequest=new List<SAP_CMD_Request__c>();
        if(lstSapCmdRequest.size() == 0)
        {
           for(SAP_CMD__c sapcmd:lstSapCmd)
           {
               Id requesterId;
               if(mapCmdRequest.containsKey(sapcmd.CMD_Request_Id__c))
               {
                  requesterId=mapCmdRequest.get(sapcmd.CMD_Request_Id__c).CreatedById;
               }
               SAP_CMD_Request__c newSAPCMDR = new SAP_CMD_Request__c(CMD_Request__c = sapcmd.CMD_Request_Id__c,
                                               SAP_CMD__c = sapcmd.Id, Requester__c = requesterId);                                                          
               lstNewSapCmdRequest.add(newSAPCMDR); 
           }
           insert lstNewSapCmdRequest;            
        }
    }
    
    //Method to Populate SAP CMD approval Fields
    public static void syncSAP_CMD_Approval_Fields(list<SAP_CMD__c> lstSapCmd)
    {
        fetchSapCmdRequestRecords(lstSapCmd);
        List<SAP_CMD_Request__c> SAPCMDRequestToBeUpdated = new List<SAP_CMD_Request__c>();
        if(lstSapCmdRequest.size() != 0)
        {
            for(SAP_CMD__c sapcmd:lstSapCmd)
            {
                for( SAP_CMD_Request__c scr : lstSapCmdRequest ) 
                {
                    if(sapcmd.Id==scr.SAP_CMD__c)
                    {
                        scr.Approval_Status__c=sapcmd.Status__c;
                        scr.Pending_Approver__c=String.valueOf(sapcmd.Pending_Approver__c);
                        scr.Pending_Approval_Since__c=sapcmd.Pending_Approval_Since__c;
                        SAPCMDRequestToBeUpdated.add(scr);
                    }                   
                }
            }
            Update SAPCMDRequestToBeUpdated;          
        }                        
    } 
   // Update SAP CMD - funloc under multiple Sales Orgs - to update General Data at once
   public static void Update_SAPCMD_GeneralData(list<SAP_CMD__c> lstSapCmd)
    { 
       List<SAP_CMD__c> allSapCmdToBeUpdated = new List<SAP_CMD__c>();
       set<string> setSapCmdFunloc = new set<string>();
       
       for(SAP_CMD__c sc : lstSapCmd){
         setSapCmdFunloc.add(sc.FunLoc__c);
       }
      
       List<SAP_CMD__c> lstAllSapCmds = [SELECT id,FunLoc__c,HUB_Customer__c,Name_2__c,Name_4__c,Legal_Name__c,Name_3__c,Name_1_Service_Provider__c,
                                         Street_2__c,Street_1__c,State_Province__c,Country__c,City__c,Zip__c,PO_Box__c,PO_Box_City__c,PO_Box_Postal_Code__c, Telephone__c,Email__c,Fax__c,
                                         Transportation_Zone__c,Language__c,Chinese_Name1__c,Chinese_Name2__c,Chinese_Street__c, Chinese_City__c,Trading_Partner__c,Tax_Number_1__c,
                                         VAT_Registration_Number__c,Country_Additional_VAT_Number_1__c,Country_Additional_VAT_Number_2__c,Country_Additional_VAT_Number_3__c,Country_Additional_VAT_Number_4__c,  
                                         Country_Additional_VAT_Number_5__c,Country_Additional_VAT_Number_6__c,Country_Additional_VAT_Number_7__c,Country_Additional_VAT_Number_8__c,Additional_VAT_Number_1_Plants_Abroad__c,
                                         Additional_VAT_Number_2_Plants_Abroad__c,Additional_VAT_Number_3_Plants_Abroad__c,Additional_VAT_Number_4_Plants_Abroad__c,Additional_VAT_Number_5_Plants_Abroad__c,
                                         Additional_VAT_Number_6_Plants_Abroad__c,Additional_VAT_Number_7_Plants_Abroad__c,Additional_VAT_Number_8_Plants_Abroad__c,Global_Account__c,
                                         Customer_Factory_Calendar__c,Unloading_Point__c,Military_Usage__c,Controlled_Party__c,SDI_Screened__c,Consolidated_Account_Code__c,
                                         Fix_Price_Ind_SP__c,Delivery_Group_Ind_SH__c,Rounding_Rule_SH__c,Pull_Up_OK_SH__c
                                         FROM SAP_CMD__c
                                         WHERE FunLoc__c =:setSapCmdFunloc and id not in:lstSapCmd ];
       
       for(SAP_CMD__c sc : lstSapCmd){
        for(SAP_CMD__c scAll : lstAllSapCmds){
        if(sc.Funloc__c == scAll.funloc__c){
         
            if(sc.HUB_Customer__c != scAll.HUB_Customer__c) scAll.HUB_Customer__c = sc.HUB_Customer__c;
            if(sc.Name_2__c != scAll.Name_2__c) scAll.Name_2__c = sc.Name_2__c;
            if(sc.Name_4__c != scAll.Name_4__c) scAll.Name_4__c = sc.Name_4__c;
            if(sc.Legal_Name__c != scAll.Legal_Name__c) scAll.Legal_Name__c = sc.Legal_Name__c;
            if(sc.Name_3__c != scAll.Name_3__c) scAll.Name_3__c = sc.Name_3__c;
            if(sc.Name_1_Service_Provider__c != scAll.Name_1_Service_Provider__c) scAll.Name_1_Service_Provider__c = sc.Name_1_Service_Provider__c;
            if(sc.Street_2__c != scAll.Street_2__c) scAll.Street_2__c = sc.Street_2__c;
            if(sc.Street_1__c != scAll.Street_1__c) scAll.Street_1__c = sc.Street_1__c;
            if(sc.State_Province__c != scAll.State_Province__c) scAll.State_Province__c = sc.State_Province__c;
            if(sc.Country__c != scAll.Country__c) scAll.Country__c = sc.Country__c;
            if(sc.City__c != scAll.City__c) scAll.City__c = sc.City__c;
            if(sc.Zip__c != scAll.Zip__c) scAll.Zip__c = sc.Zip__c;
            if(sc.PO_Box__c != scAll.PO_Box__c) scAll.PO_Box__c = sc.PO_Box__c;
            if(sc.PO_Box_City__c != scAll.PO_Box_City__c) scAll.PO_Box_City__c = sc.PO_Box_City__c;
            if(sc.PO_Box_Postal_Code__c != scAll.PO_Box_Postal_Code__c) scAll.PO_Box_Postal_Code__c = sc.PO_Box_Postal_Code__c;
            if(sc.Telephone__c != scAll.Telephone__c) scAll.Telephone__c = sc.Telephone__c;
            if(sc.Email__c != scAll.Email__c) scAll.Email__c = sc.Email__c;
            if(sc.Fax__c != scAll.Fax__c) scAll.Fax__c = sc.Fax__c;
            if(sc.Transportation_Zone__c != scAll.Transportation_Zone__c) scAll.Transportation_Zone__c = sc.Transportation_Zone__c;
            if(sc.Language__c != scAll.Language__c) scAll.Language__c = sc.Language__c;
            if(sc.Chinese_Name1__c != scAll.Chinese_Name1__c) scAll.Chinese_Name1__c = sc.Chinese_Name1__c;
            if(sc.Chinese_Name2__c != scAll.Chinese_Name2__c) scAll.Chinese_Name2__c = sc.Chinese_Name2__c;
            if(sc.Chinese_Street__c != scAll.Chinese_Street__c) scAll.Chinese_Street__c = sc.Chinese_Street__c;
            if(sc.Chinese_City__c != scAll.Chinese_City__c) scAll.Chinese_City__c = sc.Chinese_City__c;
            if(sc.Trading_Partner__c != scAll.Trading_Partner__c) scAll.Trading_Partner__c = sc.Trading_Partner__c;
            if(sc.Tax_Number_1__c != scAll.Tax_Number_1__c) scAll.Tax_Number_1__c = sc.Tax_Number_1__c;
            if(sc.VAT_Registration_Number__c != scAll.VAT_Registration_Number__c) scAll.VAT_Registration_Number__c = sc.VAT_Registration_Number__c;
            if(sc.Country_Additional_VAT_Number_1__c != scAll.Country_Additional_VAT_Number_1__c) scAll.Country_Additional_VAT_Number_1__c = sc.Country_Additional_VAT_Number_1__c;
            if(sc.Country_Additional_VAT_Number_2__c != scAll.Country_Additional_VAT_Number_2__c) scAll.Country_Additional_VAT_Number_2__c = sc.Country_Additional_VAT_Number_2__c;
            if(sc.Country_Additional_VAT_Number_3__c != scAll.Country_Additional_VAT_Number_3__c) scAll.Country_Additional_VAT_Number_3__c = sc.Country_Additional_VAT_Number_3__c;
            if(sc.Country_Additional_VAT_Number_4__c != scAll.Country_Additional_VAT_Number_4__c) scAll.Country_Additional_VAT_Number_4__c = sc.Country_Additional_VAT_Number_4__c;
            if(sc.Country_Additional_VAT_Number_5__c != scAll.Country_Additional_VAT_Number_5__c) scAll.Country_Additional_VAT_Number_5__c = sc.Country_Additional_VAT_Number_5__c;
            if(sc.Country_Additional_VAT_Number_6__c != scAll.Country_Additional_VAT_Number_6__c) scAll.Country_Additional_VAT_Number_6__c = sc.Country_Additional_VAT_Number_6__c;
            if(sc.Country_Additional_VAT_Number_7__c != scAll.Country_Additional_VAT_Number_7__c) scAll.Country_Additional_VAT_Number_7__c = sc.Country_Additional_VAT_Number_7__c;
            if(sc.Country_Additional_VAT_Number_8__c != scAll.Country_Additional_VAT_Number_8__c) scAll.Country_Additional_VAT_Number_8__c = sc.Country_Additional_VAT_Number_8__c;
            if(sc.Additional_VAT_Number_1_Plants_Abroad__c != scAll.Additional_VAT_Number_1_Plants_Abroad__c) scAll.Additional_VAT_Number_1_Plants_Abroad__c = sc.Additional_VAT_Number_1_Plants_Abroad__c;
            if(sc.Additional_VAT_Number_2_Plants_Abroad__c != scAll.Additional_VAT_Number_2_Plants_Abroad__c) scAll.Additional_VAT_Number_2_Plants_Abroad__c = sc.Additional_VAT_Number_2_Plants_Abroad__c;
            if(sc.Additional_VAT_Number_3_Plants_Abroad__c != scAll.Additional_VAT_Number_3_Plants_Abroad__c) scAll.Additional_VAT_Number_3_Plants_Abroad__c = sc.Additional_VAT_Number_3_Plants_Abroad__c;
            if(sc.Additional_VAT_Number_4_Plants_Abroad__c != scAll.Additional_VAT_Number_4_Plants_Abroad__c) scAll.Additional_VAT_Number_4_Plants_Abroad__c = sc.Additional_VAT_Number_4_Plants_Abroad__c;
            if(sc.Additional_VAT_Number_5_Plants_Abroad__c != scAll.Additional_VAT_Number_5_Plants_Abroad__c) scAll.Additional_VAT_Number_5_Plants_Abroad__c = sc.Additional_VAT_Number_5_Plants_Abroad__c;
            if(sc.Additional_VAT_Number_6_Plants_Abroad__c != scAll.Additional_VAT_Number_6_Plants_Abroad__c) scAll.Additional_VAT_Number_6_Plants_Abroad__c = sc.Additional_VAT_Number_6_Plants_Abroad__c;
            if(sc.Additional_VAT_Number_7_Plants_Abroad__c != scAll.Additional_VAT_Number_7_Plants_Abroad__c) scAll.Additional_VAT_Number_7_Plants_Abroad__c = sc.Additional_VAT_Number_7_Plants_Abroad__c;
            if(sc.Additional_VAT_Number_8_Plants_Abroad__c != scAll.Additional_VAT_Number_8_Plants_Abroad__c) scAll.Additional_VAT_Number_8_Plants_Abroad__c = sc.Additional_VAT_Number_8_Plants_Abroad__c;
            if(sc.Global_Account__c != scAll.Global_Account__c) scAll.Global_Account__c = sc.Global_Account__c;
            if(sc.Customer_Factory_Calendar__c != scAll.Customer_Factory_Calendar__c) scAll.Customer_Factory_Calendar__c = sc.Customer_Factory_Calendar__c;
            if(sc.Unloading_Point__c != scAll.Unloading_Point__c) scAll.Unloading_Point__c = sc.Unloading_Point__c;
            if(sc.Military_Usage__c != scAll.Military_Usage__c) scAll.Military_Usage__c = sc.Military_Usage__c;
            if(sc.Controlled_Party__c != scAll.Controlled_Party__c) scAll.Controlled_Party__c = sc.Controlled_Party__c;
            if(sc.SDI_Screened__c != scAll.SDI_Screened__c) scAll.SDI_Screened__c = sc.SDI_Screened__c;
            if(sc.Consolidated_Account_Code__c != scAll.Consolidated_Account_Code__c) scAll.Consolidated_Account_Code__c = sc.Consolidated_Account_Code__c;
            if(sc.Fix_Price_Ind_SP__c != scAll.Fix_Price_Ind_SP__c) scAll.Fix_Price_Ind_SP__c = sc.Fix_Price_Ind_SP__c;
            if(sc.Delivery_Group_Ind_SH__c != scAll.Delivery_Group_Ind_SH__c) scAll.Delivery_Group_Ind_SH__c = sc.Delivery_Group_Ind_SH__c;
            if(sc.Rounding_Rule_SH__c != scAll.Rounding_Rule_SH__c) scAll.Rounding_Rule_SH__c = sc.Rounding_Rule_SH__c;
            if(sc.Pull_Up_OK_SH__c != scAll.Pull_Up_OK_SH__c) scAll.Pull_Up_OK_SH__c = sc.Pull_Up_OK_SH__c;

            allSapCmdToBeUpdated.add(scAll);
       }
   }
  }   
    
     update allSapCmdToBeUpdated;
    }           
}