/********************************************************************************************
@Modified By :     Jewelslyn Shama
@Modified Date :   23 Nov 2016
@Description :     Modified As part of SFDC 119 to handle 'Apex Heap size limit Exception'
***********************************************************************************************************
@Modified By :     Baji
@Modified Date :   16 Mar 2017
@Description :     Modified as part of SFDC 363(Update SAP CMD - funloc under multiple Sales Orgs - to update General Data at once)
**********************************************************************************************************
@Modified By :     Baji
@Modified Date :   27 Jul 2017
@Description :     Modified as part of SFDC 729(to extend SFDC 363 functionlity for Version ID for International Addresses and Tax Number 5
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
                                         Transportation_Zone__c,Language__c,Chinese_Name1__c,Chinese_Name2__c,Chinese_Street__c, Chinese_City__c,Version_ID_for_International_Addresses__c,Trading_Partner__c,Tax_Number_1__c,
                                         Tax_Number_5__c,VAT_Registration_Number__c,Country_Additional_VAT_Number_1__c,Country_Additional_VAT_Number_2__c,Country_Additional_VAT_Number_3__c,Country_Additional_VAT_Number_4__c,  
                                         Country_Additional_VAT_Number_5__c,Country_Additional_VAT_Number_6__c,Country_Additional_VAT_Number_7__c,Country_Additional_VAT_Number_8__c,Additional_VAT_Number_1_Plants_Abroad__c,
                                         Additional_VAT_Number_2_Plants_Abroad__c,Additional_VAT_Number_3_Plants_Abroad__c,Additional_VAT_Number_4_Plants_Abroad__c,Additional_VAT_Number_5_Plants_Abroad__c,
                                         Additional_VAT_Number_6_Plants_Abroad__c,Additional_VAT_Number_7_Plants_Abroad__c,Additional_VAT_Number_8_Plants_Abroad__c,Global_Account__c,
                                         Customer_Factory_Calendar__c,Unloading_Point__c,Military_Usage__c,Controlled_Party__c,SDI_Screened__c,Consolidated_Account_Code__c,
                                         Fix_Price_Ind_SP__c,Delivery_Group_Ind_SH__c,Rounding_Rule_SH__c,Pull_Up_OK_SH__c,Central_order_block__c,Central_delivery_block__c,Central_billing_block_for_customer__c,Central_posting_block__c,Central_Deletion_Flag__c,Central_deletion_block__c
                                         FROM SAP_CMD__c
                                         WHERE FunLoc__c =:setSapCmdFunloc and id not in:lstSapCmd ];
       
       for(SAP_CMD__c objSAPCMD : lstSapCmd){
        for(SAP_CMD__c objSAPCMDAll : lstAllSapCmds){
        if(objSAPCMD.Funloc__c == objSAPCMDAll.funloc__c){
         
            if(objSAPCMD.HUB_Customer__c != objSAPCMDAll.HUB_Customer__c) objSAPCMDAll.HUB_Customer__c = objSAPCMD.HUB_Customer__c;
            if(objSAPCMD.Name_2__c != objSAPCMDAll.Name_2__c) objSAPCMDAll.Name_2__c = objSAPCMD.Name_2__c;
            if(objSAPCMD.Name_4__c != objSAPCMDAll.Name_4__c) objSAPCMDAll.Name_4__c = objSAPCMD.Name_4__c;
            if(objSAPCMD.Legal_Name__c != objSAPCMDAll.Legal_Name__c) objSAPCMDAll.Legal_Name__c = objSAPCMD.Legal_Name__c;
            if(objSAPCMD.Name_3__c != objSAPCMDAll.Name_3__c) objSAPCMDAll.Name_3__c = objSAPCMD.Name_3__c;
            if(objSAPCMD.Name_1_Service_Provider__c != objSAPCMDAll.Name_1_Service_Provider__c) objSAPCMDAll.Name_1_Service_Provider__c = objSAPCMD.Name_1_Service_Provider__c;
            if(objSAPCMD.Street_2__c != objSAPCMDAll.Street_2__c) objSAPCMDAll.Street_2__c = objSAPCMD.Street_2__c;
            if(objSAPCMD.Street_1__c != objSAPCMDAll.Street_1__c) objSAPCMDAll.Street_1__c = objSAPCMD.Street_1__c;
            if(objSAPCMD.State_Province__c != objSAPCMDAll.State_Province__c) objSAPCMDAll.State_Province__c = objSAPCMD.State_Province__c;
            if(objSAPCMD.Country__c != objSAPCMDAll.Country__c) objSAPCMDAll.Country__c = objSAPCMD.Country__c;
            if(objSAPCMD.City__c != objSAPCMDAll.City__c) objSAPCMDAll.City__c = objSAPCMD.City__c;
            if(objSAPCMD.Zip__c != objSAPCMDAll.Zip__c) objSAPCMDAll.Zip__c = objSAPCMD.Zip__c;
            if(objSAPCMD.PO_Box__c != objSAPCMDAll.PO_Box__c) objSAPCMDAll.PO_Box__c = objSAPCMD.PO_Box__c;
            if(objSAPCMD.PO_Box_City__c != objSAPCMDAll.PO_Box_City__c) objSAPCMDAll.PO_Box_City__c = objSAPCMD.PO_Box_City__c;
            if(objSAPCMD.PO_Box_Postal_Code__c != objSAPCMDAll.PO_Box_Postal_Code__c) objSAPCMDAll.PO_Box_Postal_Code__c = objSAPCMD.PO_Box_Postal_Code__c;
            if(objSAPCMD.Telephone__c != objSAPCMDAll.Telephone__c) objSAPCMDAll.Telephone__c = objSAPCMD.Telephone__c;
            if(objSAPCMD.Email__c != objSAPCMDAll.Email__c) objSAPCMDAll.Email__c = objSAPCMD.Email__c;
            if(objSAPCMD.Fax__c != objSAPCMDAll.Fax__c) objSAPCMDAll.Fax__c = objSAPCMD.Fax__c;
            if(objSAPCMD.Transportation_Zone__c != objSAPCMDAll.Transportation_Zone__c) objSAPCMDAll.Transportation_Zone__c = objSAPCMD.Transportation_Zone__c;
            if(objSAPCMD.Language__c != objSAPCMDAll.Language__c) objSAPCMDAll.Language__c = objSAPCMD.Language__c;
            if(objSAPCMD.Chinese_Name1__c != objSAPCMDAll.Chinese_Name1__c) objSAPCMDAll.Chinese_Name1__c = objSAPCMD.Chinese_Name1__c;
            if(objSAPCMD.Chinese_Name2__c != objSAPCMDAll.Chinese_Name2__c) objSAPCMDAll.Chinese_Name2__c = objSAPCMD.Chinese_Name2__c;
            if(objSAPCMD.Chinese_Street__c != objSAPCMDAll.Chinese_Street__c) objSAPCMDAll.Chinese_Street__c = objSAPCMD.Chinese_Street__c;
            if(objSAPCMD.Chinese_City__c != objSAPCMDAll.Chinese_City__c) objSAPCMDAll.Chinese_City__c = objSAPCMD.Chinese_City__c;
            if(objSAPCMD.Version_ID_for_International_Addresses__c != objSAPCMDAll.Version_ID_for_International_Addresses__c) objSAPCMDAll.Version_ID_for_International_Addresses__c = objSAPCMD.Version_ID_for_International_Addresses__c;
            if(objSAPCMD.Trading_Partner__c != objSAPCMDAll.Trading_Partner__c) objSAPCMDAll.Trading_Partner__c = objSAPCMD.Trading_Partner__c;
            if(objSAPCMD.Tax_Number_1__c != objSAPCMDAll.Tax_Number_1__c) objSAPCMDAll.Tax_Number_1__c = objSAPCMD.Tax_Number_1__c;
            if(objSAPCMD.Tax_Number_5__c != objSAPCMDAll.Tax_Number_5__c) objSAPCMDAll.Tax_Number_5__c = objSAPCMD.Tax_Number_5__c;
            if(objSAPCMD.VAT_Registration_Number__c != objSAPCMDAll.VAT_Registration_Number__c) objSAPCMDAll.VAT_Registration_Number__c = objSAPCMD.VAT_Registration_Number__c;
            if(objSAPCMD.Country_Additional_VAT_Number_1__c != objSAPCMDAll.Country_Additional_VAT_Number_1__c) objSAPCMDAll.Country_Additional_VAT_Number_1__c = objSAPCMD.Country_Additional_VAT_Number_1__c;
            if(objSAPCMD.Country_Additional_VAT_Number_2__c != objSAPCMDAll.Country_Additional_VAT_Number_2__c) objSAPCMDAll.Country_Additional_VAT_Number_2__c = objSAPCMD.Country_Additional_VAT_Number_2__c;
            if(objSAPCMD.Country_Additional_VAT_Number_3__c != objSAPCMDAll.Country_Additional_VAT_Number_3__c) objSAPCMDAll.Country_Additional_VAT_Number_3__c = objSAPCMD.Country_Additional_VAT_Number_3__c;
            if(objSAPCMD.Country_Additional_VAT_Number_4__c != objSAPCMDAll.Country_Additional_VAT_Number_4__c) objSAPCMDAll.Country_Additional_VAT_Number_4__c = objSAPCMD.Country_Additional_VAT_Number_4__c;
            if(objSAPCMD.Country_Additional_VAT_Number_5__c != objSAPCMDAll.Country_Additional_VAT_Number_5__c) objSAPCMDAll.Country_Additional_VAT_Number_5__c = objSAPCMD.Country_Additional_VAT_Number_5__c;
            if(objSAPCMD.Country_Additional_VAT_Number_6__c != objSAPCMDAll.Country_Additional_VAT_Number_6__c) objSAPCMDAll.Country_Additional_VAT_Number_6__c = objSAPCMD.Country_Additional_VAT_Number_6__c;
            if(objSAPCMD.Country_Additional_VAT_Number_7__c != objSAPCMDAll.Country_Additional_VAT_Number_7__c) objSAPCMDAll.Country_Additional_VAT_Number_7__c = objSAPCMD.Country_Additional_VAT_Number_7__c;
            if(objSAPCMD.Country_Additional_VAT_Number_8__c != objSAPCMDAll.Country_Additional_VAT_Number_8__c) objSAPCMDAll.Country_Additional_VAT_Number_8__c = objSAPCMD.Country_Additional_VAT_Number_8__c;
            if(objSAPCMD.Additional_VAT_Number_1_Plants_Abroad__c != objSAPCMDAll.Additional_VAT_Number_1_Plants_Abroad__c) objSAPCMDAll.Additional_VAT_Number_1_Plants_Abroad__c = objSAPCMD.Additional_VAT_Number_1_Plants_Abroad__c;
            if(objSAPCMD.Additional_VAT_Number_2_Plants_Abroad__c != objSAPCMDAll.Additional_VAT_Number_2_Plants_Abroad__c) objSAPCMDAll.Additional_VAT_Number_2_Plants_Abroad__c = objSAPCMD.Additional_VAT_Number_2_Plants_Abroad__c;
            if(objSAPCMD.Additional_VAT_Number_3_Plants_Abroad__c != objSAPCMDAll.Additional_VAT_Number_3_Plants_Abroad__c) objSAPCMDAll.Additional_VAT_Number_3_Plants_Abroad__c = objSAPCMD.Additional_VAT_Number_3_Plants_Abroad__c;
            if(objSAPCMD.Additional_VAT_Number_4_Plants_Abroad__c != objSAPCMDAll.Additional_VAT_Number_4_Plants_Abroad__c) objSAPCMDAll.Additional_VAT_Number_4_Plants_Abroad__c = objSAPCMD.Additional_VAT_Number_4_Plants_Abroad__c;
            if(objSAPCMD.Additional_VAT_Number_5_Plants_Abroad__c != objSAPCMDAll.Additional_VAT_Number_5_Plants_Abroad__c) objSAPCMDAll.Additional_VAT_Number_5_Plants_Abroad__c = objSAPCMD.Additional_VAT_Number_5_Plants_Abroad__c;
            if(objSAPCMD.Additional_VAT_Number_6_Plants_Abroad__c != objSAPCMDAll.Additional_VAT_Number_6_Plants_Abroad__c) objSAPCMDAll.Additional_VAT_Number_6_Plants_Abroad__c = objSAPCMD.Additional_VAT_Number_6_Plants_Abroad__c;
            if(objSAPCMD.Additional_VAT_Number_7_Plants_Abroad__c != objSAPCMDAll.Additional_VAT_Number_7_Plants_Abroad__c) objSAPCMDAll.Additional_VAT_Number_7_Plants_Abroad__c = objSAPCMD.Additional_VAT_Number_7_Plants_Abroad__c;
            if(objSAPCMD.Additional_VAT_Number_8_Plants_Abroad__c != objSAPCMDAll.Additional_VAT_Number_8_Plants_Abroad__c) objSAPCMDAll.Additional_VAT_Number_8_Plants_Abroad__c = objSAPCMD.Additional_VAT_Number_8_Plants_Abroad__c;
            if(objSAPCMD.Global_Account__c != objSAPCMDAll.Global_Account__c) objSAPCMDAll.Global_Account__c = objSAPCMD.Global_Account__c;
            if(objSAPCMD.Customer_Factory_Calendar__c != objSAPCMDAll.Customer_Factory_Calendar__c) objSAPCMDAll.Customer_Factory_Calendar__c = objSAPCMD.Customer_Factory_Calendar__c;
            if(objSAPCMD.Unloading_Point__c != objSAPCMDAll.Unloading_Point__c) objSAPCMDAll.Unloading_Point__c = objSAPCMD.Unloading_Point__c;
            if(objSAPCMD.Military_Usage__c != objSAPCMDAll.Military_Usage__c) objSAPCMDAll.Military_Usage__c = objSAPCMD.Military_Usage__c;
            if(objSAPCMD.Controlled_Party__c != objSAPCMDAll.Controlled_Party__c) objSAPCMDAll.Controlled_Party__c = objSAPCMD.Controlled_Party__c;
            if(objSAPCMD.SDI_Screened__c != objSAPCMDAll.SDI_Screened__c) objSAPCMDAll.SDI_Screened__c = objSAPCMD.SDI_Screened__c;
            if(objSAPCMD.Consolidated_Account_Code__c != objSAPCMDAll.Consolidated_Account_Code__c) objSAPCMDAll.Consolidated_Account_Code__c = objSAPCMD.Consolidated_Account_Code__c;
            if(objSAPCMD.Fix_Price_Ind_SP__c != objSAPCMDAll.Fix_Price_Ind_SP__c) objSAPCMDAll.Fix_Price_Ind_SP__c = objSAPCMD.Fix_Price_Ind_SP__c;
            if(objSAPCMD.Delivery_Group_Ind_SH__c != objSAPCMDAll.Delivery_Group_Ind_SH__c) objSAPCMDAll.Delivery_Group_Ind_SH__c = objSAPCMD.Delivery_Group_Ind_SH__c;
            if(objSAPCMD.Rounding_Rule_SH__c != objSAPCMDAll.Rounding_Rule_SH__c) objSAPCMDAll.Rounding_Rule_SH__c = objSAPCMD.Rounding_Rule_SH__c;
            if(objSAPCMD.Pull_Up_OK_SH__c != objSAPCMDAll.Pull_Up_OK_SH__c) objSAPCMDAll.Pull_Up_OK_SH__c = objSAPCMD.Pull_Up_OK_SH__c;
            if(objSAPCMD.Central_order_block__c != objSAPCMDAll.Central_order_block__c) objSAPCMDAll.Central_order_block__c = objSAPCMD.Central_order_block__c;
            if(objSAPCMD.Central_delivery_block__c != objSAPCMDAll.Central_delivery_block__c) objSAPCMDAll.Central_delivery_block__c = objSAPCMD.Central_delivery_block__c;
            if(objSAPCMD.Central_billing_block_for_customer__c != objSAPCMDAll.Central_billing_block_for_customer__c) objSAPCMDAll.Central_billing_block_for_customer__c = objSAPCMD.Central_billing_block_for_customer__c;
            if(objSAPCMD.Central_posting_block__c != objSAPCMDAll.Central_posting_block__c) objSAPCMDAll.Central_posting_block__c = objSAPCMD.Central_posting_block__c;
            if(objSAPCMD.Central_Deletion_Flag__c != objSAPCMDAll.Central_Deletion_Flag__c) objSAPCMDAll.Central_Deletion_Flag__c = objSAPCMD.Central_Deletion_Flag__c;
            if(objSAPCMD.Central_deletion_block__c != objSAPCMDAll.Central_deletion_block__c) objSAPCMDAll.Central_deletion_block__c = objSAPCMD.Central_deletion_block__c;
            allSapCmdToBeUpdated.add(objSAPCMDAll);
       }
   }
  }   
     update allSapCmdToBeUpdated;
    }           
}