/**********************************************************************************************
@Last Modified By :       Baji
@Last Modified Date:      18 May 2017
@Description:             Modified for SIR 544(17.06 release)
                          Commented code to deactivate auto-copy of sales area and Automotive OEM from CMD Request to Account on update of customer.
***********************************************************************************************
@Last Modified By :       Baji
@Last Modified Date:      08 Jan 2016
@Description:             Modified for SIR 627(16.02 release)
                          Do not change Account [Inactive] status when there's GID data update
***********************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      11 Jun 2013
@Description:       Class for all Customer Trigger Methods
**************************************************************************************/

public with sharing class CustomerTrigger 
{
    public static final String PRE_ACCOUNT = 'PreAccount';      
    private static RecordType preAccount;
    
    private static final String TYPE_CUSTOMER = 'Customer';
    private static final String STATUS_PENDING = 'Pending';
    private static final String DEFAULT_REGION =  'Not Found';
        
    public static Boolean IsFirstRun_AfterUpdate = true;
        
    private static void fetchAccountRecordTypes()
    {
        //get the record type
        for(RecordType rt : [Select Id, DeveloperName
                               From RecordType
                               Where SobjectType = 'Account' and DeveloperName =: PRE_ACCOUNT and IsActive=true
                               Limit 1])
        {
            preAccount = rt;
        }       
    }
        
    private static Boolean isCustomerChanged(Customer__c newCustomer, Customer__c oldCustomer)
    {
        Boolean isChanged = (newCustomer.Legal_Name__c.trim() != oldCustomer.Legal_Name__c.trim() ||
                                newCustomer.Account_Name__c.trim() != oldCustomer.Account_Name__c.trim() ||
                                newCustomer.DUNS__c != oldCustomer.DUNS__c ||
                                newCustomer.Fulfillment_Channel__c != oldCustomer.Fulfillment_Channel__c ||
                                newCustomer.DNB_Verified__c != oldCustomer.DNB_Verified__c ||
                                newCustomer.House_Number__c != oldCustomer.House_Number__c ||
                                newCustomer.Street__c.trim() != oldCustomer.Street__c.trim() ||
                                newCustomer.Street_2__c != oldCustomer.Street_2__c ||
                                newCustomer.Street_3__c != oldCustomer.Street_3__c ||
                                newCustomer.City__c.trim() != oldCustomer.City__c.trim() ||
                                newCustomer.State__c != oldCustomer.State__c ||
                                newCustomer.Country__c != oldCustomer.Country__c ||
                                newCustomer.Region__c != oldCustomer.Region__c ||
                                newCustomer.ZIP__c != oldCustomer.ZIP__c ||
                                newCustomer.GSM_Classification__c != oldCustomer.GSM_Classification__c ||                               
                                newCustomer.Industry_Segment__c != oldCustomer.Industry_Segment__c ||
                                newCustomer.Industry_Sub_Segment__c != oldCustomer.Industry_Sub_Segment__c  ||
                                newCustomer.Role__c != oldCustomer.Role__c ||
                                newCustomer.SIC_Code__c != oldCustomer.SIC_Code__c ||
                                newCustomer.NAICS_Code__c != oldCustomer.NAICS_Code__c ||
                                newCustomer.Website__c != oldCustomer.Website__c ||
                                newCustomer.EMail__c != oldCustomer.EMail__c ||
                                newCustomer.Fax__c != oldCustomer.Fax__c ||
                                newCustomer.Telephone__c != oldCustomer.Telephone__c ||
                                newCustomer.Sales_Area__c != oldCustomer.Sales_Area__c
                            );
        return isChanged;
    }
    
    private static void updateAccount(Customer__c objCustomer, Account objAccount)
    {
        //objAccount.Name = objCustomer.Account_Name__c;
        objAccount.CMD_Short_Name__c = objCustomer.Account_Name__c;
        objAccount.Legal_Name__c = objCustomer.Legal_Name__c ;
        objAccount.House_Number__c = objCustomer.House_Number__c;
        objAccount.Street__c = objCustomer.Street__c;
        objAccount.Street2__c = objCustomer.Street_2__c;
        objAccount.Street3__c = objCustomer.Street_3__c;
        objAccount.City__c = objCustomer.City__c;                       
        objAccount.State_Province__c = objCustomer.State__c;
        objAccount.Country__c = objCustomer.Country__c;
        objAccount.ZIP_Postal_Code__c = objCustomer.ZIP__c;
        objAccount.DNB_Verified__c = objCustomer.DNB_Verified__c;
        objAccount.Status_of_D_B_Cleansing__c = objCustomer.DNB_Verified__c;
        objAccount.DUNS_Number__c  = objCustomer.DUNS__c;
        objAccount.SIC_Code__c = objCustomer.SIC_Code__c;
        objAccount.NAICS_Code__c = objCustomer.NAICS_Code__c;
        objAccount.Website = objCustomer.Website__c;
        objAccount.Email__c = objCustomer.EMail__c;
        objAccount.Fax = objCustomer.Fax__c;
        objAccount.Phone = objCustomer.Telephone__c;
        objAccount.Type = objCustomer.Type__c;
        objAccount.Role__c = objCustomer.Role__c;
        objAccount.Customer_Category__c = objCustomer.GSM_Classification__c;
        objAccount.FulFillment_Channel__c = objCustomer.Fulfillment_Channel__c;
        objAccount.Sales_Area__c = objCustomer.Sales_Area__c;
        
        if(objCustomer.Region__c.indexOf('-') > -1)
        {
            //objAccount.Region__c = objCustomer.Region__c.substring(objCustomer.Region__c.indexOf('-') + 1).trim();
            objAccount.Region__c = ConvertRegionCode(objCustomer.Region__c);
        }
        
        if(objCustomer.Industry_Segment__c != null && objCustomer.Industry_Segment__c.indexOf('-') > -1)
        {
            //objAccount.Industry_Segment__c = objCustomer.Industry_Segment__c.substring(objCustomer.Industry_Segment__c.indexOf('-') + 1).trim();
            objAccount.CMD_Industry_Segment__c = objCustomer.Industry_Segment__c.substring(objCustomer.Industry_Segment__c.indexOf('-') + 1).trim();            
        }
        else
        {
            //objAccount.Industry_Segment__c = null;
            objAccount.CMD_Industry_Segment__c = null;
        }
        
        if(objCustomer.Industry_Sub_Segment__c != null && objCustomer.Industry_Sub_Segment__c.indexOf('-') > -1)
        {
            //objAccount.Sub_Segment__c = objCustomer.Industry_Sub_Segment__c.substring(objCustomer.Industry_Sub_Segment__c.indexOf('-') + 1).trim();
            objAccount.CMD_Sub_Segment__c = objCustomer.Industry_Sub_Segment__c.substring(objCustomer.Industry_Sub_Segment__c.indexOf('-') + 1).trim();
        }
        else
        {
            //objAccount.Sub_Segment__c = null;
            objAccount.CMD_Sub_Segment__c = null;
        }    
                   
   //  Commented code to deactivate auto-copy of sales area and Automotive OEM from CMD Request to Account on update of customer.
  
     /*   //get Sales Area and Automotive flag from CMD Request
        CMD_Request__c objCMD = getCMDRequestById(objCustomer.CMD_Request_Id__c);
        if (objCMD != null)
        {
            objAccount.Sales_Area__c = objCMD.Sales_Area__c;
            objAccount.Automotive_OEM__c = objCMD.Automotive_OEM__c;
        } */
    }
    
    private static Account createPreAccount(Customer__c objCustomer)
    {
        Account objAccount = new Account(RecordTypeId = preAccount.Id, NXP_GID__c = objCustomer.Name , 
                                            Name = objCustomer.Account_Name__c, Legal_Name__c = objCustomer.Legal_Name__c , 
                                            DUNS_Number__c  = objCustomer.DUNS__c,FulFillment_Channel__c = objCustomer.Fulfillment_Channel__c ,
                                            DNB_Verified__c = objCustomer.DNB_Verified__c , House_Number__c = objCustomer.House_Number__c , 
                                            Street__c = objCustomer.Street__c ,Street2__c = objCustomer.Street_2__c, 
                                            Street3__c = objCustomer.Street_3__c , City__c = objCustomer.City__c , 
                                            State_Province__c = objCustomer.State__c , Country__c = objCustomer.Country__c, 
                                            ZIP_Postal_Code__c = objCustomer.ZIP__c , Customer_Category__c = objCustomer.GSM_Classification__c, 
                                            Type = objCustomer.Type__c, Role__c = objCustomer.Role__c , SIC_Code__c = objCustomer.SIC_Code__c , 
                                            NAICS_Code__c = objCustomer.NAICS_Code__c ,Website = objCustomer.Website__c ,
                                            Email__c = objCustomer.EMail__c ,Fax = objCustomer.Fax__c , 
                                            Phone = objCustomer.Telephone__c, CMD_Request_Id__c = objCustomer.CMD_Request_Id__c,
                                            CMD_Short_Name__c = objCustomer.Account_Name__c, 
                                            Status_of_D_B_Cleansing__c = objCustomer.DNB_Verified__c,
                                            Sales_Area__c = objCustomer.Sales_Area__c
                                        );
                                        
        if(objCustomer.Region__c.indexOf('-') > -1)
        {
            //objAccount.Region__c = objCustomer.Region__c.substring(objCustomer.Region__c.indexOf('-') + 1).trim();
            objAccount.Region__c = ConvertRegionCode(objCustomer.Region__c);
        }
        
        if(objCustomer.Industry_Segment__c != null && objCustomer.Industry_Segment__c.indexOf('-') > -1)
        {
            objAccount.Industry_Segment__c = objCustomer.Industry_Segment__c.substring(objCustomer.Industry_Segment__c.indexOf('-') + 1).trim();
            objAccount.CMD_Industry_Segment__c = objCustomer.Industry_Segment__c.substring(objCustomer.Industry_Segment__c.indexOf('-') + 1).trim();            
        }
        
        if(objCustomer.Industry_Sub_Segment__c != null && objCustomer.Industry_Sub_Segment__c.indexOf('-') > -1)
        {
            objAccount.Sub_Segment__c = objCustomer.Industry_Sub_Segment__c.substring(objCustomer.Industry_Sub_Segment__c.indexOf('-') + 1).trim();
            objAccount.CMD_Sub_Segment__c = objCustomer.Industry_Sub_Segment__c.substring(objCustomer.Industry_Sub_Segment__c.indexOf('-') + 1).trim();
        }
                
        
        
        //get Sales Area and Automotive flag from CMD Request
        CMD_Request__c objCMD = getCMDRequestById(objCustomer.CMD_Request_Id__c);
        if (objCMD != null)
        {
            objAccount.Sales_Area__c = objCMD.Sales_Area__c;
            objAccount.Automotive_OEM__c = objCMD.Automotive_OEM__c;
        }
        
        return objAccount;
    }       
    
    public static void syncCustomerToSfCrm(List<Customer__c> lstCustomers)
    {   
        if(lstCustomers != null && lstCustomers.size() > 0)
        {
            //fetch the record types for Account(Std Object) in SF-CRM
            fetchAccountRecordTypes();  
            
            //prepare a map of all CustomerId to GIDs  
            Map<String, Id> mapGidToCustomerId = new Map<String, Id>();
            
            List<Account> lstAccountsToBeInserted = new List<Account>();
            Account newAcc;
            
            for(Customer__c objCustomer : lstCustomers)
            {
                //check if Sales checkbox checked and Type==Customer and Status <> 'Pending'
                if((objCustomer.Sales__c) && (objCustomer.Type__c == TYPE_CUSTOMER) && (objCustomer.Status__c <> STATUS_PENDING))
                {
                    mapGidToCustomerId.put(objCustomer.Name , objCustomer.Id);
                    
                    newAcc = createPreAccount(objCustomer);
                    lstAccountsToBeInserted.add(newAcc);
                }
            }
            
            //insert new account records
            if(lstAccountsToBeInserted.size() > 0)
            {
                insert lstAccountsToBeInserted;
/*                
                //prepare a list of Customer (Customer Hub App) to be updated back with 'LastModified Date field' 
                Set<Id> customerIds = new Set<Id>();
                
                for(Account acc: lstAccountsToBeInserted)
                {
                    if(acc.Id != null)
                    {
                        if(mapGidToCustomerId.containsKey(acc.NXP_GID__c))
                        {
                            customerIds.add(mapGidToCustomerId.get(acc.NXP_GID__c));    
                        }                               
                    }
                }
                
                if(customerIds.size() > 0)
                {
                    List<Customer__c> lstCustomersToBeUpdated = [Select Id, Last_Updated_IT_systems_for_Sales__c 
                                                                    From Customer__c
                                                                    Where Id in  : customerIds];
                    for(Customer__c obj :  lstCustomersToBeUpdated)
                    {
                        obj.Last_Updated_IT_systems_for_Sales__c =  Datetime.now();
                    }                   
                    
                    if(lstCustomersToBeUpdated.size() > 0)
                    {
                        IsFirstRun_AfterUpdate = false;
                        update lstCustomersToBeUpdated; 
                    }
                }           */
            }
        }    
    }

    public static void syncCustomerOnUpdateToSfCrm(List<Customer__c> lstCustomers, Map<Id, Customer__c> oldCustomersMap)
    {   
        system.debug('**[Scarlett] run syncCustomerOnUpdateToSfCrm...');
        
        if((lstCustomers != null && lstCustomers.size() > 0) && ( oldCustomersMap != null && oldCustomersMap.size() > 0))
        {
            //fetch the record types for Account(Std Object) in SF-CRM
            fetchAccountRecordTypes();
            
            //map of all candidate Customers with GID
            Map<String, Customer__c> mapGidToCandidateCustomers = new Map<String, Customer__c>();
            
            //prepare a map of NXP GID for all eligible customers 
            for(Customer__c objCustomer : lstCustomers)
            {
                //check if Sales checkbox checked and Type==Customer and Status <> 'Pending'
                if((objCustomer.Sales__c) && (objCustomer.Type__c == TYPE_CUSTOMER) && (objCustomer.Status__c <> STATUS_PENDING))
                {
                    system.debug('**[Scarlett] collect GID info...');
                    
                    Customer__c oldCustomer = oldCustomersMap.get(objCustomer.Id);
                    
                    //either Config Parameters changed or Customer specific parameters changed
                    Boolean isConfigChanged = (objCustomer.Sales__c != oldCustomer.Sales__c || objCustomer.Type__c != oldCustomer.Type__c || objCustomer.Status__c != oldCustomer.Status__c);
                    
                    //check if any field out of those fields to be synced with SF-CRM modified
                    if(isConfigChanged || isCustomerChanged(objCustomer, oldCustomer))
                    {
                        system.debug('**[Scarlett] isCustomerChanged...');
                        mapGidToCandidateCustomers.put(objCustomer.Name, objCustomer);
                    }
                }
            }                       
            
            //fetch all Accounts in SF-CRM for all Candiadte Customer records and prepare a map of it with GID
            //for one NXP-GID, there could be multiple Account records regardless of record type (Parent/Child/PreAccount)
                        
            Map<String, Set<Account>> mapGidToAccount = new Map<String, Set<Account>>();
            for(Account acc: [Select Id , Name, NXP_GID__c, Sales_Area__c From Account 
                                Where NXP_GID__c in : mapGidToCandidateCustomers.keySet()])
            {
                if(mapGidToAccount.containsKey(acc.NXP_GID__c))
                {
                    mapGidToAccount.get(acc.NXP_GID__c).add(acc);
                }
                else
                {
                    mapGidToAccount.put(acc.NXP_GID__c, new Set<Account>{acc}); 
                }   
            }
            
            List<Account> lstAccountsToBeUpserted = new List<Account>();
                                    
            for(Customer__c objCustomer : mapGidToCandidateCustomers.values())
            {
                //check if Account record exists 
                if(mapGidToAccount.containsKey(objCustomer.Name))
                {
                    //Account Records exists - update these record(s)
                    for(Account acc : mapGidToAccount.get(objCustomer.Name))
                    {
                        system.debug('**[Scarlett] before updateAccount...' + 'acc.Sales_Area__c: ' + acc.Sales_Area__c);
                        
                        updateAccount(objCustomer, acc);
                        lstAccountsToBeUpserted.add(acc);
                        
                        system.debug('**[Scarlett] after updateAccount...' + 'acc.Sales_Area__c: ' + acc.Sales_Area__c);
                         system.debug('**[Scarlett] Account Id: ' + acc.Id);
                    }       
                }
                else
                {
                    //Insert new Account record
                    Account newAcc = createPreAccount(objCustomer);
                    lstAccountsToBeUpserted.add(newAcc);                    
                }
            }
            
            //upsert modified account records
            if(lstAccountsToBeUpserted.size() > 0)
            {
                system.debug('**[Scarlett] upsert account...');
                upsert lstAccountsToBeUpserted;
                
/*
                //prepare a list of Customer (Customer Hub App) to be updated back with 'LastModified Date field' 
                Set<Id> customerIds = new Set<Id>();
                
                for(Account acc: lstAccountsToBeUpserted)
                {
                    if(acc.Id != null)
                    {
                        if(mapGidToCandidateCustomers.containsKey(acc.NXP_GID__c))
                        {
                            customerIds.add(mapGidToCandidateCustomers.get(acc.NXP_GID__c).Id); 
                        }                               
                    }
                }
                
                if(customerIds.size() > 0)
                {
                    List<Customer__c> lstCustomersToBeUpdated = [Select Id, Last_Updated_IT_systems_for_Sales__c
                                                                    From Customer__c
                                                                    Where Id in  : customerIds];
                    for(Customer__c obj :  lstCustomersToBeUpdated)
                    {
                        obj.Last_Updated_IT_systems_for_Sales__c =  Datetime.now();
                    }
                                        
                    if(lstCustomersToBeUpdated.size() > 0)
                    {
                        IsFirstRun_AfterUpdate = false;
                        update lstCustomersToBeUpdated; 
                    }               
                }               */
            }
        }
    }
    

/******************************   INTERFACE TRIGGER METHOD ENDS HERE  ***************************************************************/
    
    public static void AssignRegionByCountry(List<Customer__c> lstCustomers, Map<Id, Customer__c> oldCustomersMap, Boolean IsInsert, Boolean IsUpdate)
    {
        Set<String> countries = new Set<String>(); 
        Map<String, String> mapCountryToRegions = new Map<String, String>();
          
        for(Customer__c objCustomer : lstCustomers)
        {
            if((objCustomer.Country__c != null) &&( IsInsert || (IsUpdate && oldCustomersMap.get(objCustomer.Id).Country__c != objCustomer.Country__c)))
            {
                countries.add(objCustomer.Country__c.toLowerCase());
            }
        }
          
        if(countries.size() > 0)
        {
            //Fetch the Record Type for Country and Region Mapping
            List<RecordType> lstRecordTypes = [Select Id, DeveloperName From RecordType Where DeveloperName = 'Country_and_Region' and SobjectType = 'Hub_Foundation__c'];
            
            if(lstRecordTypes.size() > 0)
            {
                for (Hub_Foundation__c objRegion : [Select Country__c, Region__c From Hub_Foundation__c Where Country__c in :countries and RecordTypeId =: lstRecordTypes[0].Id ])
                {
                    mapCountryToRegions.put(objRegion.Country__c.toLowerCase() , objRegion.Region__c);
                } 
            }      
        }
          
        String strRegion;
        for(Customer__c objCustomer : lstCustomers)
        {
            if((IsInsert) || (IsUpdate && oldCustomersMap.get(objCustomer.Id).Country__c != objCustomer.Country__c))
            {
                if(objCustomer.Country__c != null)
                {
                    strRegion = mapCountryToRegions.get(objCustomer.Country__c.toLowerCase());
                }
                objCustomer.Region__c =(strRegion != null ? strRegion : DEFAULT_REGION);  
            }            
        }  
    }
    
    //CMD to CRM region code convertor
    public static String ConvertRegionCode(String sapCode)
    {
        if (sapCode.equalsIgnoreCase('EU - EMEA'))
        {
            return 'EMEA';
        } 
        else if (sapCode.equalsIgnoreCase('AP - JAPAN'))
        {
            return 'Japan';
        }
        else if (sapCode.equalsIgnoreCase('AP - KOREA'))
        {
            return 'Korea';
        }
        else if (sapCode.equalsIgnoreCase('AP - GC'))
        {
            return 'Greater China';
        }
        else if (sapCode.equalsIgnoreCase('AM - AMEC'))
        {
            return 'Americas';
        }
        else if (sapCode.equalsIgnoreCase('AP - SAP'))
        {
            return 'South Asia Pacific';
        }
        return sapCode;
    }
 
    public static CMD_Request__c getCMDRequestById(String Id)
    {
        if (Id == '' || Id == null) return null;
        List<CMD_Request__c> lstCMD = [select Id, Sales_Area__c, Automotive_OEM__c 
        from CMD_Request__c where Id = :Id];
        if (lstCMD.size() > 0) return lstCMD[0];
        return null;
    }
}