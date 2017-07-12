// 2015-08-12 by Rex: add sales org settings
// 2015-03-03 by Rex: First release
// 
global with sharing class SAPCustomerUpdateBatch implements Database.Batchable<sObject> {
    global SAPCustomerUpdateBatch() {}
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<SAP_Customer_Sales_Org__c> lstSAPCustomerSalesOrg = SAP_Customer_Sales_Org__c.getAll().Values();
        List<String> lstSalesOrg = new List<String>();
        for(SAP_Customer_Sales_Org__c obj : lstSAPCustomerSalesOrg) {
            lstSalesOrg.add(obj.Sales_Org__c);
        }
        String strQuery = 'Select SAP_Customer__r.Customer_FunLoc_Number__c, Funloc_Number__c, SAP_Customer__r.Sales_Organisation__c, SAP_Customer__r.Consolidated_Account_Code__r.Name, ' +
'SAP_Customer__r.Consolidated_Account_Code_Full__c, SAP_Customer__r.Global_Account__c, SAP_Customer__r.Grp_1_Sls_Channel_SP__c, SAP_Customer__r.RecordType.Name, ' +
'SAP_Customer__r.Region__c, SAP_Customer__r.Country__c, SAP_Customer__r.Legal_Name__c, SAP_Customer__r.Name_2__c, SAP_Customer__r.Name_3__c, SAP_Customer__r.Name_4__c, ' +
'SAP_Customer__r.Street_1__c, SAP_Customer__r.City__c, SAP_Customer__r.Zip__c, SAP_Customer__r.PO_Box__c, SAP_Customer__r.State_Province__c, SAP_Customer__r.Incoterms_1__c, ' +
'SAP_Customer__r.Incoterms_2__c, SAP_Customer__r.Terms_of_payment__c ' +
'From Partner_Function__c Where Partner_Function_Type__c = \'WE - ShipTo Party\' ' +
'And SAP_Customer__r.Sales_Organisation__c =: lstSalesOrg';
        if (Test.isRunningTest()) strQuery = strQuery + ' limit 1';
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        Set<String> setFunloc = new Set<String>();
        Set<String> setCustomerFunloc = new Set<String>();
        Set<String> setSalesOrg = new Set<String>();
        Map<String,SAP_Customer__c> mapSAPCustomer = new Map<String,SAP_Customer__c>();
        List<SAP_Customer__c> lstUpdate = new List<SAP_Customer__c>();
        for(Partner_Function__c partnerFunction : (list<Partner_Function__c>)scope) {
            if (!setFunloc.contains(partnerFunction.FunLoc_Number__c))
                setFunloc.add(partnerFunction.FunLoc_Number__c);
            if (!setCustomerFunloc.contains(partnerFunction.SAP_Customer__r.Customer_Funloc_Number__c))
                setCustomerFunloc.add(partnerFunction.SAP_Customer__r.Customer_Funloc_Number__c);
            if (!setSalesOrg.contains(partnerFunction.SAP_Customer__r.Sales_Organisation__c))
                setSalesOrg.add(partnerFunction.SAP_Customer__r.Sales_Organisation__c);
            //Unique_Key__c = Funloc__c + '-' + Customer_Funloc_Number__c + '-' + Sales_Org__c
            //String strUniqueKey = partnerFunction.FunLoc_Number__c + '-' + partnerFunction.SAP_Customer__r.Customer_Funloc_Number__c + '-' + 
            //    partnerFunction.SAP_Customer__r.Sales_Organisation__c;
            //if (!mapFunloc.containsKey(strUniqueKey)) {
            //    mapFunloc.put(strUniqueKey, partnerFunction);
            //}
        }
        String strQuery = 'SELECT Id, Account_Rep_Code__c, Account_Rep_Desc__c, CACC__c, CACC_Description__c, City__c, Country__c, Country_Code__c, Funloc__c, Global_Account__c, ' + 
            'Group__c, Group_Description__c, Incoterms_Code_SH__c, Incoterms_Name_SH__c, Market_Segment__c, Market_Segment_Description__c, Name_1__c, Name_2__c, Name_3__c, Name_4__c, ' + 
            'PO_Box__c, Payment_Terms__c, Postal_Code__c, Region__c, Name, Channel__c, Sales_Org__c, Ship_To_Party__c, State_Province__c, Street__c, Unique_Key__c FROM SAP_Customer__c ' +
            'Where Funloc__c =: setCustomerFunloc And Ship_To_Party__c =: setFunloc And Sales_Org__c =: setSalesOrg';
        List<SAP_Customer__c> lstSAPCustomer = Database.query(strQuery);
        for(SAP_Customer__c obj : lstSAPCustomer) {
            mapSAPCustomer.put(obj.Unique_Key__c, obj);
        }
        Set<String> setSAPCustomerId = new Set<String>();
        for(Partner_Function__c partnerFunction : (list<Partner_Function__c>)scope) {
            String strUniqueKey = partnerFunction.SAP_Customer__r.Customer_Funloc_Number__c + '-' + partnerFunction.FunLoc_Number__c + '-' +
                partnerFunction.SAP_Customer__r.Sales_Organisation__c;
			SAP_Customer__c newData, updateData;
            if (mapSAPCustomer.containsKey(strUniqueKey)) { // update
                updateData = mapSAPCustomer.get(strUniqueKey);
                updateData = updateRecord(updateData, partnerFunction, strUniqueKey);
                if (!setSAPCustomerId.contains(updateData.Id)) {
                	lstUpdate.add(updateData);
                    setSAPCustomerId.add(updateData.Id);
                }
            } else { // insert
                newData = newRecord(partnerFunction, strUniqueKey);
                lstUpdate.add(newData);
            }
        }
        if (lstUpdate.size() > 0) upsert lstUpdate;
    }
    
    private SAP_Customer__c newRecord(Partner_Function__c partnerFunction, String strUniqueKey) {
        SAP_Customer__c current = new SAP_Customer__c();
        return updateRecord(current, partnerFunction, strUniqueKey);
    }
    
    private SAP_Customer__c updateRecord(SAP_Customer__c current, Partner_Function__c partnerFunction, String strUniqueKey) {
        current.Name = partnerFunction.SAP_Customer__r.Customer_FunLoc_Number__c + ' - ' + partnerFunction.SAP_Customer__r.Legal_Name__c;
        current.Unique_Key__c = strUniqueKey;
        current.Funloc__c = partnerFunction.SAP_Customer__r.Customer_FunLoc_Number__c;
        current.Ship_To_Party__c = partnerFunction.FunLoc_Number__c;
        current.Sales_Org__c = partnerFunction.SAP_Customer__r.Sales_Organisation__c;
        current.CACC__c = partnerFunction.SAP_Customer__r.Consolidated_Account_Code__r.Name;
        current.CACC_Description__c = partnerFunction.SAP_Customer__r.Consolidated_Account_Code_Full__c;
        current.Global_Account__c = partnerFunction.SAP_Customer__r.Global_Account__c;
        current.Channel__c = partnerFunction.SAP_Customer__r.Grp_1_Sls_Channel_SP__c;
        //Group + Group Description
        String strRecordType = partnerFunction.SAP_Customer__r.RecordType.Name;
        List<String> lstGroup = strRecordType.split(' - ');
        current.Group__c = lstGroup.get(0);
        //current.Group_Description__c = lstGroup.get(1); // formula field
        current.Region__c = partnerFunction.SAP_Customer__r.Region__c;
        current.Country__c = partnerFunction.SAP_Customer__r.Country__c;
        current.Name_1__c = partnerFunction.SAP_Customer__r.Legal_Name__c;
        current.Name_2__c = partnerFunction.SAP_Customer__r.Name_2__c;
        current.Name_3__c = partnerFunction.SAP_Customer__r.Name_3__c;
        current.Name_4__c = partnerFunction.SAP_Customer__r.Name_4__c;
        current.Street__c = partnerFunction.SAP_Customer__r.Street_1__c;
        current.City__c = partnerFunction.SAP_Customer__r.City__c;
        current.Postal_Code__c = partnerFunction.SAP_Customer__r.Zip__c;
        current.PO_Box__c = partnerFunction.SAP_Customer__r.PO_Box__c;
        current.State_Province__c = partnerFunction.SAP_Customer__r.State_Province__c;
        current.Incoterms_Code_SH__c = partnerFunction.SAP_Customer__r.Incoterms_1__c;
        current.Incoterms_Name_SH__c = partnerFunction.SAP_Customer__r.Incoterms_2__c;
        current.Payment_Terms__c = partnerFunction.SAP_Customer__r.Terms_of_payment__c;
        return current;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}