/******************************************************************************
@Modified By :     Scarlett Kang
@Modified Date :   31 Mar 2015
@Description :     Upsert SAP CMD Request records after update or insert
********************************************************************************
@Modified By :     Jewelslyn Shama
@Modified Date :   23 Nov 2016
@Description :     Modified As part of SFDC 119 to handle 'Apex Heap size limit Exception',line Nos:30-40
***********************************************************************************************************
@Modified By :     Baji
@Modified Date :   16 Mar 2017
@Description :     Modified as part of SFDC 363(Update SAP CMD - funloc under multiple Sales Orgs - to update General Data at once)
**********************************************************************************************************
@Modified By :     Baji
@Modified Date :   27 Jul 2017
@Description :     Modified as part of SFDC 729(to extend SFDC 363 functionlity for Version ID for International Addresses and Tax Number 5
************************************************************************************************************************/

trigger SAP_CMD_AfterTrigger on SAP_CMD__c (after update, after insert) {
    if(Trigger.isUpdate){
     list<SAP_CMD__c> lstSapCmd=new List<SAP_CMD__c>();
        for(SAP_CMD__c objSapCmd : Trigger.new){
             if( objSapCmd.CMD_Request_Id__c != null && objSapCmd.CMD_Request_Id__c != '' 
                && objSapCmd.Status__c == 'Approved and Distributed'){ 
                SAP_CMD_Trigger sapCmd = new SAP_CMD_Trigger();
                    sapCmd.updateCMDRequestStatus(objSapCmd.CMD_Request_Id__c , objSapCmd.Id);
                    SAP_CMD_Trigger.removeCMDRequestId(objSapCmd.CMD_Request_Id__c , objSapCmd.Id);
             }
       
       system.debug('test1T' + lstSapCmd.size());
       
       SAP_CMD__c oldObjSapCmd = Trigger.oldmap.get(objSapCmd.Id); 
       if(oldObjSapCmd.HUB_Customer__c != ObjSapCmd.HUB_Customer__c ||oldObjSapCmd.Name_2__c != ObjSapCmd.Name_2__c ||oldObjSapCmd.Name_4__c != ObjSapCmd.Name_4__c ||oldObjSapCmd.Legal_Name__c != ObjSapCmd.Legal_Name__c ||
       oldObjSapCmd.Name_3__c != ObjSapCmd.Name_3__c ||oldObjSapCmd.Name_1_Service_Provider__c != ObjSapCmd.Name_1_Service_Provider__c ||oldObjSapCmd.Street_2__c != ObjSapCmd.Street_2__c ||
       oldObjSapCmd.Street_1__c != ObjSapCmd.Street_1__c ||oldObjSapCmd.State_Province__c != ObjSapCmd.State_Province__c ||oldObjSapCmd.Country__c != ObjSapCmd.Country__c ||oldObjSapCmd.City__c != ObjSapCmd.City__c ||
       oldObjSapCmd.Zip__c != ObjSapCmd.Zip__c ||oldObjSapCmd.PO_Box__c != ObjSapCmd.PO_Box__c ||oldObjSapCmd.PO_Box_City__c != ObjSapCmd.PO_Box_City__c ||oldObjSapCmd.PO_Box_Postal_Code__c != ObjSapCmd.PO_Box_Postal_Code__c ||
       oldObjSapCmd.Telephone__c != ObjSapCmd.Telephone__c ||oldObjSapCmd.Email__c != ObjSapCmd.Email__c ||oldObjSapCmd.Fax__c != ObjSapCmd.Fax__c ||oldObjSapCmd.Transportation_Zone__c != ObjSapCmd.Transportation_Zone__c ||
       oldObjSapCmd.Language__c != ObjSapCmd.Language__c ||oldObjSapCmd.Chinese_Name1__c != ObjSapCmd.Chinese_Name1__c ||oldObjSapCmd.Chinese_Name2__c != ObjSapCmd.Chinese_Name2__c ||oldObjSapCmd.Chinese_Street__c != ObjSapCmd.Chinese_Street__c ||
       oldObjSapCmd.Chinese_City__c != ObjSapCmd.Chinese_City__c ||oldObjSapCmd.Version_ID_for_International_Addresses__c != ObjSapCmd.Version_ID_for_International_Addresses__c ||oldObjSapCmd.Trading_Partner__c != ObjSapCmd.Trading_Partner__c ||oldObjSapCmd.Tax_Number_1__c != ObjSapCmd.Tax_Number_1__c ||oldObjSapCmd.VAT_Registration_Number__c != ObjSapCmd.VAT_Registration_Number__c ||
       oldObjSapCmd.Tax_Number_5__c != ObjSapCmd.Tax_Number_5__c ||oldObjSapCmd.Country_Additional_VAT_Number_1__c != ObjSapCmd.Country_Additional_VAT_Number_1__c ||oldObjSapCmd.Country_Additional_VAT_Number_2__c != ObjSapCmd.Country_Additional_VAT_Number_2__c ||oldObjSapCmd.Country_Additional_VAT_Number_3__c != ObjSapCmd.Country_Additional_VAT_Number_3__c ||
       oldObjSapCmd.Country_Additional_VAT_Number_4__c != ObjSapCmd.Country_Additional_VAT_Number_4__c ||oldObjSapCmd.Country_Additional_VAT_Number_5__c != ObjSapCmd.Country_Additional_VAT_Number_5__c ||oldObjSapCmd.Country_Additional_VAT_Number_6__c != ObjSapCmd.Country_Additional_VAT_Number_6__c ||
       oldObjSapCmd.Country_Additional_VAT_Number_7__c != ObjSapCmd.Country_Additional_VAT_Number_7__c ||oldObjSapCmd.Country_Additional_VAT_Number_8__c != ObjSapCmd.Country_Additional_VAT_Number_8__c ||oldObjSapCmd.Additional_VAT_Number_1_Plants_Abroad__c != ObjSapCmd.Additional_VAT_Number_1_Plants_Abroad__c ||
       oldObjSapCmd.Additional_VAT_Number_2_Plants_Abroad__c != ObjSapCmd.Additional_VAT_Number_2_Plants_Abroad__c ||oldObjSapCmd.Additional_VAT_Number_3_Plants_Abroad__c != ObjSapCmd.Additional_VAT_Number_3_Plants_Abroad__c ||oldObjSapCmd.Additional_VAT_Number_4_Plants_Abroad__c != ObjSapCmd.Additional_VAT_Number_4_Plants_Abroad__c ||
       oldObjSapCmd.Additional_VAT_Number_5_Plants_Abroad__c != ObjSapCmd.Additional_VAT_Number_5_Plants_Abroad__c ||oldObjSapCmd.Additional_VAT_Number_6_Plants_Abroad__c != ObjSapCmd.Additional_VAT_Number_6_Plants_Abroad__c ||oldObjSapCmd.Additional_VAT_Number_7_Plants_Abroad__c != ObjSapCmd.Additional_VAT_Number_7_Plants_Abroad__c ||
       oldObjSapCmd.Additional_VAT_Number_8_Plants_Abroad__c != ObjSapCmd.Additional_VAT_Number_8_Plants_Abroad__c ||oldObjSapCmd.Global_Account__c != ObjSapCmd.Global_Account__c ||oldObjSapCmd.Customer_Factory_Calendar__c != ObjSapCmd.Customer_Factory_Calendar__c ||oldObjSapCmd.Unloading_Point__c != ObjSapCmd.Unloading_Point__c ||
       oldObjSapCmd.Military_Usage__c != ObjSapCmd.Military_Usage__c ||oldObjSapCmd.Controlled_Party__c != ObjSapCmd.Controlled_Party__c ||oldObjSapCmd.SDI_Screened__c != ObjSapCmd.SDI_Screened__c ||oldObjSapCmd.Consolidated_Account_Code__c != ObjSapCmd.Consolidated_Account_Code__c ||oldObjSapCmd.Fix_Price_Ind_SP__c != ObjSapCmd.Fix_Price_Ind_SP__c ||
       oldObjSapCmd.Delivery_Group_Ind_SH__c != ObjSapCmd.Delivery_Group_Ind_SH__c ||oldObjSapCmd.Rounding_Rule_SH__c != ObjSapCmd.Rounding_Rule_SH__c ||oldObjSapCmd.Pull_Up_OK_SH__c != ObjSapCmd.Pull_Up_OK_SH__c ||
       oldObjSapCmd.Central_order_block__c != ObjSapCmd.Central_order_block__c || oldObjSapCmd.Central_delivery_block__c != ObjSapCmd.Central_delivery_block__c || oldObjSapCmd.Central_billing_block_for_customer__c != ObjSapCmd.Central_billing_block_for_customer__c ||
       oldObjSapCmd.Central_posting_block__c != ObjSapCmd.Central_posting_block__c || oldObjSapCmd.Central_Deletion_Flag__c != ObjSapCmd.Central_Deletion_Flag__c || oldObjSapCmd.Central_deletion_block__c != ObjSapCmd.Central_deletion_block__c)
       {
       system.debug('test2T' + lstSapCmd.size());
       lstSapCmd.add(objSapCmd);
      }
    }
      if(lstSapCmd.size()>0)
        {
       if(SAP_CMD_Request_Trigger.isFirstTime)
        {
          system.debug('test3T' + lstSapCmd.size());
          SAP_CMD_Request_Trigger.isFirstTime = false;
          SAP_CMD_Request_Trigger.Update_SAPCMD_GeneralData(lstSapCmd); // to update SAP CMD General Data at once
          system.debug('test4T' + lstSapCmd.size());
          
        }
       }
    }
  
 
    
    SapCmdTrigger.syncAddressToFunloc(Trigger.new, Trigger.oldMap); 
    
    if( Trigger.isInsert || Trigger.isUpdate) //Added by Jewelslyn
    {
        list<SAP_CMD__c> lstSapCmd=new List<SAP_CMD__c>();
        for(SAP_CMD__c sapcmd : Trigger.new) 
        {        
            if( sapcmd.CMD_Request_Id__c != null && sapcmd.CMD_Request_Id__c != '') 
            {
                lstSapCmd.add(sapcmd);                
            }            
        }
        if(lstSapCmd.size()>0)
        {
           SAP_CMD_Request_Trigger.upsertSAP_CMD_Request(lstSapCmd ); 
        }
    }
}