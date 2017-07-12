/*****************************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      30 Sep 2013
@Description:       Class for all SAP CMD Trigger Methods
----------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      10 Feb 2014
@Description:        Converted Customer Name and Address formula fields in input fields 
                     and copy values for these fields from GCM for Sold To Account Groups
 ---------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:    12 Mar 2014
@Description:          de-link Region field from GCM (DO NOT sync it with GCM)
 ---------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:    25 Mar 2014
@Description:          de-link Street2 and Street 3  field from GCM (DO NOT sync it with GCM)
---------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:    25 Apr 2014
@Description:         1- Method updated to generate funloc for all account gropups from SAP CMD instead of GCM
                                        2- New method added to update funloc on SAP CMD record update  
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:    26 May 2014
@Description:         Copy End Customer GID from Consolidated Account Codes object
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    20 Mar 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Segment__c to formula
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:    10 Sep 2015
@Description:      Modified to generate funloc number in different range for NXP/Julie based on 'funloc range' field.
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    Sep 30 2015
@Description:      SIR 495 - Stop copying Industry Sub Segment from Customer object to SAP CMD
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    Oct 23 2015
@Description:      1511 Release - SIR 474, Stop copying Address information from Customer to SAP CMD
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    Dec 21 2015
@Description:      1601 Release - SIR 4596, SAP CMD - Name3 field map to funloc DB
***************************************************************************************************************************/

public class SapCmdTrigger
{
    public static final String TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER = 'Z001_SoldTo_ShipTo_BillTo_Payer';
    public static final String TYPE_Z005_SOLD_TO_BILL_TO_PAYER = 'Z005_SoldTo_BillTo_Payer';
    public static final String TYPE_Z011_SOLD_TO = 'Z011_Sold_To';
    public static final String TYPE_Z012_SOLD_TO_SHIP_TO = 'Z012_Sold_to_Ship_To';
    public static final String TYPE_Z002_SHIP_TO='Z002_Ship_To';
    public static final String TYPE_Z003_PAYER = 'Z003_Payer';
    public static final String TYPE_Z004_BILL_TO ='Z004_Bill_To';    
    public static final String TYPE_Z010_INTERMEDIATE_CONSIGNEE = 'Z010_Intermediate_Consignee';
    public static final String TYPE_Z013_PAYER_BILL_TO = 'Z013_Payer_Bill_To';
    
    public static final String TYPE_ZORG_ORGANIZATIONAL_CUSTOMERS='ZORG_Organizational_Customers';
    public static final String TYPE_ZOTHERS_NON_COMMERCIAL_ENTITIES='ZOthers_Non_Commercial_Entities';
    
    public static RecordType Z001_SoldTo_ShipTo_BillTo_Payer;
    public static RecordType Z005_SoldTo_BillTo_Payer;
    public static RecordType Z011_Sold_To;
    public static RecordType Z012_Sold_to_Ship_To;
    public static RecordType Z002_Ship_To;
    public static RecordType Z003_Payer;
    public static RecordType Z004_Bill_To;
    public static RecordType Z010_Intermediate_Consignee;
    public static RecordType Z013_Payer_Bill_To;  
    
    public static RecordType ZORG_Organizational_Customers;
    public static RecordType ZOthers_Non_Commercial_Entities;
    
    private static Set<Id> soldToRecordTypeIds = new Set<Id>();
    
    private static void fetchRecordTypes()
    {
        //get SAP CMD record type
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              (SobjectType = 'SAP_CMD__c' and 
                                                        (DeveloperName =: TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER 
                                                                or DeveloperName =: TYPE_Z010_INTERMEDIATE_CONSIGNEE
                                                                or DeveloperName =: TYPE_Z002_SHIP_TO 
                                                                or DeveloperName =: TYPE_Z011_SOLD_TO
                                                                or DeveloperName =: TYPE_Z012_SOLD_TO_SHIP_TO
                                                                or DeveloperName =: TYPE_Z003_PAYER
                                                                or DeveloperName =: TYPE_Z004_BILL_TO
                                                                or DeveloperName =: TYPE_Z005_SOLD_TO_BILL_TO_PAYER
                                                                or DeveloperName =: TYPE_Z013_PAYER_BILL_TO
                                                                or DeveloperName =: TYPE_ZORG_ORGANIZATIONAL_CUSTOMERS
                                                                or DeveloperName =: TYPE_ZOTHERS_NON_COMMERCIAL_ENTITIES
                                                               ))])
        {
            if(rt.DeveloperName == TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
            {
                Z001_SoldTo_ShipTo_BillTo_Payer = rt;
                soldToRecordTypeIds.add(rt.Id);
            }
            else if(rt.DeveloperName == TYPE_Z005_SOLD_TO_BILL_TO_PAYER)
            {
               Z005_SoldTo_BillTo_Payer  = rt;
               soldToRecordTypeIds.add(rt.Id);
            }
            else if(rt.DeveloperName == TYPE_Z011_SOLD_TO)
            {
                Z011_Sold_To = rt;
                soldToRecordTypeIds.add(rt.Id); 
            }
            else if(rt.DeveloperName == TYPE_Z012_SOLD_TO_SHIP_TO)
            {
                Z012_Sold_to_Ship_To = rt;
                soldToRecordTypeIds.add(rt.Id);
            }
            else if(rt.DeveloperName == TYPE_Z002_SHIP_TO)
            {
                Z002_Ship_To = rt;                
            }
             else if(rt.DeveloperName == TYPE_Z003_PAYER)
            {
               Z003_Payer  = rt;
            }
            else if(rt.DeveloperName == TYPE_Z004_BILL_TO)
            {
               Z004_Bill_To  = rt;
            }
            else if(rt.DeveloperName == TYPE_Z010_INTERMEDIATE_CONSIGNEE)
            {
                Z010_Intermediate_Consignee = rt;
            }
            else if(rt.DeveloperName == TYPE_Z013_PAYER_BILL_TO)
            {
                Z013_Payer_Bill_To = rt;
            }
            else if(rt.DeveloperName == TYPE_ZORG_ORGANIZATIONAL_CUSTOMERS)
            {
                ZORG_Organizational_Customers = rt;
            }
            else if(rt.DeveloperName == TYPE_ZOTHERS_NON_COMMERCIAL_ENTITIES)
            {
                ZOthers_Non_Commercial_Entities = rt;
            }        
        }            
    }
    
    public static void generateFunLocAndCopyCustomerAddress(List<SAP_CMD__c> lstSapCmd)
    {
        if(lstSapCmd != null && lstSapCmd.size() > 0)
        {
            fetchRecordTypes();
            
            Set<Id> customerIds = new Set<Id>();
            Set<Id> codeIds = new Set<Id>();
            
            for(SAP_CMD__c objSapCmd : lstSapCmd)
            {
                //prepare a set of all customer ids
                
                if( (objSapCmd.HUB_Customer__c != null)  &&
                       (  (objSapCmd.Customer_FunLoc_Number__c == null) || 
                            (soldToRecordTypeIds.contains(objSapCmd.RecordTypeId))
                       )
                    )
                {
                    customerIds.add(objSapCmd.HUB_Customer__c); 
                }
                
                //prepare a set of CACC Ids    
                if( (objSapCmd.Consolidated_Account_Code__c  != null )  &&  (objSapCmd.End_Customer_NXP_Global_ID__c == null)) 
                {
                        codeIds.add(objSapCmd.Consolidated_Account_Code__c);
                }
            }
            
            //fetch customer records for all above customerids
            Map<Id,Customer__c> mapIdToCustomer = new Map<Id,Customer__c>([Select Id, Legal_Name__c,Account_Name__c,Country__c,City__c,ZIP__c,
                                                                                Street__c,Street_2__c,Street_3__c,House_Number__c , State__c , 
                                                                                Region__c , Telephone__c ,  Fax__c ,  EMail__c , //Scarlett Industry_Segment__c,
                                                                                 Industry_Sub_Segment__c       
                                                                            From Customer__c 
                                                                            Where Id in :customerIds]);
            
            //fetch CACC records for all above caccids
            Map<Id, Consolidated_Account_Code__c> mapIdToCacc = new Map<Id, Consolidated_Account_Code__c>([Select Id , End_Customer_GID__c  
                                                                                                                                                                                                                                                    From Consolidated_Account_Code__c 
                                                                                                                                                                                                                                                    Where Id in : codeIds]);
            
            Customer__c objCustomer ;
            Map<SAP_CMD__c, FunLoc__c> mapSapCmdToFunloc = new Map<SAP_CMD__c, FunLoc__c>();
           
            
            for(SAP_CMD__c obj : lstSapCmd)
            {
                if(obj.HUB_Customer__c != null)
                {
                    //fetch the customer record from the map created 
                    objCustomer = mapIdToCustomer.get(obj.HUB_Customer__c);
                    
                    /***1511 Release - Modified by Scarlett***/
                    //copy Customer Name and address details for Sold to Requests   
                    /*                
                    if(soldToRecordTypeIds.contains(obj.RecordTypeId))
                    {
                        obj.Street_1__c = objCustomer.Street__c;
                        obj.City__c = objCustomer.City__c;
                        obj.State_Province__c = objCustomer.State__c;                       
                        obj.Country__c = objCustomer.Country__c;
                        obj.Zip__c = objCustomer.ZIP__c;
                    */
//Scarlett                      obj.Industry_Segment__c = objCustomer.Industry_Segment__c;
/***Modified by Scarlett on Sep 30 2015***/
//                        obj.Industry_Sub_Segment__c = objCustomer.Industry_Sub_Segment__c;
/***Modified by Scarlett on Sep 30 2015 - END ***/
                    //}
                    /***1511 Release - Modified by Scarlett - END***/
                    
                    //Copy End Customer GID from CACC Master
                    if( (obj.Consolidated_Account_Code__c != null )  &&  (obj.End_Customer_NXP_Global_ID__c == null)) 
                    {
                        Consolidated_Account_Code__c objCacc = mapIdToCacc.get(obj.Consolidated_Account_Code__c);
                        if(objCacc != null)
                        {
                            obj.End_Customer_NXP_Global_ID__c = objCacc.End_Customer_GID__c;
                        }
                    }
                }
                
                //generate funloc record
                if(obj.Customer_FunLoc_Number__c == null)
                {
                   // added the below if block to set the 'is Julie' checkbox to true when sales organisation = HK91 - WeEn Semiconductor.
                   if((obj.Sales_Organisation__c != null || obj.Sales_Organisation__c =='') && obj.Sales_Organisation__c == 'HK91 - WeEn Semiconductor'){
                   
                       /***1601 - SIR 459, Modified by Scarlett***/
                    FunLoc__c objJulieFunloc = new FunLoc__c(Name__c = obj.Legal_Name__c,  SubName__c = obj.Name_2__c, 
                                                                                                        Call_Name__c = obj.Legal_Name__c ,  Street_Name__c = obj.Street_1__c,
                                                                                                        District_Name__c =  obj.Name_4__c  ,  Place_Name__c = obj.City__c ,
                                                                                                        PostCode__c = obj.Zip__c ,   Country_Name__c = obj.Country__c , Subdivision_Name__c = obj.State_Province__c ,
                                                                                                        PO_Box_Post_Code__c = obj.PO_Box_Postal_Code__c , PO_Box_Place_Name__c = obj.PO_Box_City__c ,
                                                                                                        Number__c = obj.PO_Box__c, Funloc_Range__c = 'WeEN', Industrial_Zone__c = obj.Name_3__c);
                       /***1601 - SIR 459, Modified by Scarlett - END***/
                    
                    mapSapCmdToFunloc.put(obj , objJulieFunloc);
                    }
                    else{
                    
                    /***1601 - SIR 459, Modified by Scarlett***/
                    FunLoc__c objNxpFunloc = new FunLoc__c(Name__c = obj.Legal_Name__c,  SubName__c = obj.Name_2__c, 
                                                                                                        Call_Name__c = obj.Legal_Name__c ,  Street_Name__c = obj.Street_1__c,
                                                                                                        District_Name__c =  obj.Name_4__c  ,  Place_Name__c = obj.City__c ,
                                                                                                        PostCode__c = obj.Zip__c ,   Country_Name__c = obj.Country__c , Subdivision_Name__c = obj.State_Province__c ,
                                                                                                        PO_Box_Post_Code__c = obj.PO_Box_Postal_Code__c , PO_Box_Place_Name__c = obj.PO_Box_City__c ,
                                                                                                        Number__c = obj.PO_Box__c, Funloc_Range__c = 'NXP', Industrial_Zone__c = obj.Name_3__c);
                    /***1601 - SIR 459, Modified by Scarlett - END***/
                    
                    mapSapCmdToFunloc.put(obj , objNxpFunloc);
                    }
                    
                }
            }
            
           if(mapSapCmdToFunloc.size() > 0)
            {
                
                List<FunLoc__c> lstFunlocs = mapSapCmdToFunloc.values();
                insert lstFunlocs;
                
                //update SAP CMD records back with Funloc field
                for(SAP_CMD__c obj : mapSapCmdToFunloc.keySet())
                {
                    FunLoc__c objFunloc = mapSapCmdToFunloc.get(obj);
                    if(objFunloc != null && objFunloc.Id != null)
                    {
                        obj.FunLoc__c = objFunloc.Id;                               
                    }
                }
            }
        }
    }
    
    
    //update related funloc to SAP CMD
    public static void syncAddressToFunloc(List<SAP_CMD__c> lstSapCmd  , Map<Id, SAP_CMD__c> mapOldSapCmd)
    {
               if ( (lstSapCmd != null && lstSapCmd.size() > 0) &&  (mapOldSapCmd != null && mapOldSapCmd.size() > 0))
               {
                   Map<Id, SAP_CMD__c> mapFunlocToSapCmd = new Map<Id, SAP_CMD__c>();
                   
                   //prepare a set of related funloc numbers 
                   for(SAP_CMD__c obj : lstSapCmd)
                   {
                       SAP_CMD__c oldSapCmd = mapOldSapCmd.get(obj.Id);
                       
                       /***1601 - SIR 459, Modified by Scarlett***/
                       if( (obj.Legal_Name__c != oldSapCmd.Legal_Name__c) || 
                               (obj.Name_2__c != oldSapCmd.Name_2__c) ||
                               (obj.Street_1__c != oldSapCmd.Street_1__c)  ||
                               (obj.Name_4__c != oldSapCmd.Name_4__c)  ||
                               (obj.City__c != oldSapCmd.City__c) ||
                               (obj.Zip__c != oldSapCmd.Zip__c) ||
                               (obj.Country__c != oldSapCmd.Country__c)  ||
                               (obj.State_Province__c != oldSapCmd.State_Province__c)  ||
                                (obj.PO_Box_Postal_Code__c != oldSapCmd.PO_Box_Postal_Code__c) ||
                                (obj.PO_Box_City__c != oldSapCmd.PO_Box_City__c) ||
                                (obj.PO_Box__c != oldSapCmd.PO_Box__c)||
                                (obj.Name_3__c != oldSapCmd.Name_3__c)
                        )
                        /***1601 - SIR 459, Modified by Scarlett - END***/
                       {
                           mapFunlocToSapCmd.put(obj.FunLoc__c, obj);                          
                       }
                   }
                   
                   //fetch all funloc records 
                   List<FunLoc__c> lstFunlocs = [Select Id , Name__c ,   SubName__c , Street_Name__c , District_Name__c , Place_Name__c  ,
                                                                                                        PostCode__c ,   Country_Name__c  , Subdivision_Name__c , PO_Box_Post_Code__c , 
                                                                                                        PO_Box_Place_Name__c , Number__c 
                                                                                  From FunLoc__c 
                                                                                  Where Id in : mapFunlocToSapCmd.keySet()];
                   
                    for(FunLoc__c obj : lstFunlocs) 
                    {
                        SAP_CMD__c objSapCmd = mapFunlocToSapCmd.get(obj.Id);
                        if(objSapCmd != null)
                        {
                            SAP_CMD__c oldSapCmd = mapOldSapCmd.get(objSapCmd.Id);
                            
                            if( objSapCmd.Legal_Name__c != oldSapCmd.Legal_Name__c)
                            {
                                obj.Name__c = objSapCmd.Legal_Name__c;
                            }
                            
                            if( objSapCmd.Name_2__c != oldSapCmd.Name_2__c)
                            {
                                obj.SubName__c = objSapCmd.Name_2__c;
                            }
                            
                             if( objSapCmd.Street_1__c != oldSapCmd.Street_1__c)
                            {
                                obj.Street_Name__c = objSapCmd.Street_1__c;
                            }
                            
                            if( objSapCmd.Name_4__c != oldSapCmd.Name_4__c) 
                            {
                                obj.District_Name__c = objSapCmd.Name_4__c ; 
                            }
                            
                            if( objSapCmd.City__c != oldSapCmd.City__c)
                            {
                                obj.Place_Name__c = objSapCmd.City__c;
                            }
                            
                            if( objSapCmd.Zip__c != oldSapCmd.Zip__c)
                            {
                                obj.PostCode__c = objSapCmd.Zip__c;
                            }
                            
                            if( objSapCmd.Country__c != oldSapCmd.Country__c)
                            {
                                obj.Country_Name__c = objSapCmd.Country__c;
                            }
                            
                            if( objSapCmd.State_Province__c != oldSapCmd.State_Province__c)
                            {
                                obj.Subdivision_Name__c = objSapCmd.State_Province__c;
                            }
                            
                            if( objSapCmd.PO_Box_Postal_Code__c != oldSapCmd.PO_Box_Postal_Code__c)
                            {
                                obj.PO_Box_Post_Code__c = objSapCmd.PO_Box_Postal_Code__c;
                            }
                            
                            if( objSapCmd.PO_Box_City__c != oldSapCmd.PO_Box_City__c)
                            {
                                obj.PO_Box_Place_Name__c = objSapCmd.PO_Box_City__c;
                            }
                            
                            if( objSapCmd.PO_Box__c != oldSapCmd.PO_Box__c)
                            {
                                obj.Number__c = objSapCmd.PO_Box__c;
                            }            
                            /***1601 - SIR 459, Modified by Scarlett***/
                            if(objSapCmd.Name_3__c!= oldSapCmd.Name_3__c){
                                obj.Industrial_Zone__c = objSapCmd.Name_3__c;
                            }
                            /***1601 - SIR 459, Modified by Scarlett - END***/                                                                                            
                        }
                    }
                    
                    update lstFunlocs;
               }
    }     
}