/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      12 Sep 2013
@Description:       Test class for AfterTrigger_Customer and AfterTrigger_CustomerContact Trigger
--------------------------------------------------------------------------------------------------
@Modified By:       Nisha Agrawal
@Modified Date:     Sep 08,2017
@Description:       Updated code to solve unique username issue while creating test users
*******************************************************************************************************/

@isTest
private class Hub2CrmInterfaceTest 
{
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    private static final String TYPE_LOCATION = 'Location';
    private static final String INTERNAL_CONTACT = 'Internal_Contact';
    
    private static final integer RECORD_COUNT = 50;
    private static RecordType preAccount;
    private static RecordType parentAccount;
    private static RecordType globalCustomer;
    private static RecordType locationCustomer;
    private static RecordType internalContact;
    
    private static void fetchRecordTypes()
    {
        //get Account record type
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              ((SobjectType = 'Account' and (DeveloperName =: CustomerTrigger.PRE_ACCOUNT or DeveloperName =: CustomerContactTrigger.PARENT_ACCOUNT)) or
                               (SobjectType = 'Customer__c' and (DeveloperName =: TYPE_GLOBALENTERPRISE or DeveloperName =: TYPE_LOCATION)) or
                               (SobjectType = 'Hub_Contact__c' and DeveloperName =: INTERNAL_CONTACT)                              
                              )
                              Limit 5])
        {
            if(rt.DeveloperName == TYPE_GLOBALENTERPRISE)
            {
                globalCustomer = rt;
            }
            else if(rt.DeveloperName == TYPE_LOCATION)
            {
                locationCustomer = rt;
            }
            else if(rt.DeveloperName == INTERNAL_CONTACT)
            {
                internalContact = rt;
            }
            else if(rt.DeveloperName == CustomerTrigger.PRE_ACCOUNT)
            {
                preAccount = rt; 
            }
            else if(rt.DeveloperName == CustomerContactTrigger.PARENT_ACCOUNT)
            {
                parentAccount = rt;
            }
        }
    }
    
    private static List<Hub_Contact__c> createHubContacts()
    {
        List<Hub_Contact__c> lstHubContacts = new List<Hub_Contact__c>();
        for( integer i=0 ; i < 20 ; i++ )
        {
            Hub_Contact__c objHubContact = new Hub_Contact__c(RecordTypeId = internalContact.Id, Email__c = 'test.test' + i +'@test.com' , Last_Name__c = 'ut_last'+ i ) ;
            lstHubContacts.add( objHubContact ) ;
        }       
        return lstHubContacts;
    }
    
    private static List<User> createManagerUsers()
    {
        List<User> lstUsers = new List<User>();
        Profile objProfile = [Select Id , Name From Profile Where Name = 'System Administrator' Limit 1];
        system.assert(objProfile.Id != null);
        
        User objUser;
        
        for(integer i=0; i < 20; i++)
        {
            objUser = new User(alias = 'nUser' + i, email= 'test.test' + i +'@test.com', emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', 
                               // username= 'test.test' + datetime.now().millisecond() + i +'@test.com' //commented by Nisha Agrawal on Sep 08, 2017 to solve unique username issue
                               username= 'ut.hub' + i + '@nxp.com' // added by Nisha Agrawal on Sep 08, 2017 to solve unique username issue
                              );
            
            lstUsers.add(objUser);                                          
        }
        return lstUsers;
    } 
    
    
    /***************************************************************************
        Case - New Global Enterprise Customer - > New Pre Account  
    ****************************************************************************/ 
    
    static testMethod void Hub2CrmInterfaceTest1() 
    {
        //prepare test data
        
        fetchRecordTypes();
        
        List<Customer__c> lstCustomers = new List<Customer__c>();
        Customer__c objCustomer;
        
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            if(math.MOD(i,2)==0)
            {  
                objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                                Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
            }
            else
            {
                objCustomer = new Customer__c(RecordTypeId = locationCustomer.Id, Account_Name__c = 'ut_location' + i ,
                                                Legal_Name__c = 'ut_location' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
            }
            lstCustomers.add(objCustomer);                                            
        }
        
        //start the test
        test.startTest();
        
        insert lstCustomers;
        
        //assert record ids       
        Set<Id> customerIds = new Set<Id>();
        for(Customer__c obj :  lstCustomers)
        {
            system.assert(obj.Id != null);
            customerIds.add(obj.Id);
        }
        map<String, Customer__c> mapGidToCustomers = new map<String, Customer__c>();
        
        for(Customer__c obj : [Select Id , Name , Account_Name__c , Legal_Name__c , DUNS__c , Status__c , DNB_Verified__c , House_Number__c ,
                                    Street__c , City__c , Country__c , Region__c , Zip__c , Industry_Segment__c , Type__c , Role__c , GSM_Classification__c ,
                                    Fulfillment_Channel__c,Street_2__c , Street_3__c ,State__c,Industry_Sub_Segment__c , SIC_Code__c , NAICS_Code__c ,
                                    Website__c , EMail__c , Fax__c , Telephone__c From Customer__c
                                Where Id IN :customerIds ])
        {
            mapGidToCustomers.put(obj.Name , obj);
        }
        
        //fetch account records and assert results
        
        for( Account objAccount : [ Select Id, RecordTypeId, NXP_GID__c , Name , Legal_Name__c , Industry_Segment__c  , Customer_Category__c  , DNB_Verified__c ,
                                        Region__c , FulFillment_Channel__c , Role__c,Sub_Segment__c  , Type , Country__c , State_Province__c , Street__c , 
                                        Street2__c , Street3__c , City__c , House_Number__c, ZIP_Postal_Code__c, DUNS_Number__c , SIC_Code__c , NAICS_Code__c , Website  ,
                                        Email__c , Fax , Phone, IsInactive__c , CMD_Short_Name__c , CMD_Industry_Segment__c , CMD_Sub_Segment__c , Status_of_D_B_Cleansing__c 
                                    From  Account
                                    Where NXP_GID__c IN : mapGidToCustomers.keySet() ] )
        {
            objCustomer = mapGidToCustomers.get(objAccount.NXP_GID__c);
            system.assert(objCustomer != null);
            system.assertEquals( objAccount.RecordTypeId ,preAccount.Id );
            system.assertEquals( objAccount.NXP_GID__c , objCustomer.Name );
            system.assertEquals( objAccount.Name , objCustomer.Account_Name__c ) ;
            system.assertEquals( objAccount.CMD_Short_Name__c , objCustomer.Account_Name__c ) ;
            system.assertEquals( objAccount.Legal_Name__c , objCustomer.Legal_Name__c ) ;            
            system.assertEquals( objAccount.Customer_Category__c , objCustomer.GSM_Classification__c ) ;            
            system.assertEquals( objAccount.DNB_Verified__c , objCustomer.DNB_Verified__c ) ;    
            system.assertEquals( objAccount.Status_of_D_B_Cleansing__c , objCustomer.DNB_Verified__c ) ;    
                        
            if(objCustomer.Region__c.indexOf('-') > -1)
            {
                String strRegion = objCustomer.Region__c.substring(objCustomer.Region__c.indexOf('-') + 1).trim();
                system.assertEquals( objAccount.Region__c , strRegion ) ;  
            } 
            
            if(objCustomer.Industry_Segment__c.indexOf('-') > -1)
            {
                String strIndustrySegment = objCustomer.Industry_Segment__c.substring(objCustomer.Industry_Segment__c.indexOf('-') + 1).trim();
                system.assertEquals( objAccount.Industry_Segment__c , strIndustrySegment ) ;  
                system.assertEquals( objAccount.CMD_Industry_Segment__c , strIndustrySegment ) ;  
            } 
            
            if(objCustomer.Industry_Sub_Segment__c.indexOf('-') > -1)
            {
                String strIndustrySubSegment = objCustomer.Industry_Sub_Segment__c.substring(objCustomer.Industry_Sub_Segment__c.indexOf('-') + 1).trim();
                system.assertEquals( objAccount.Sub_Segment__c, strIndustrySubSegment ) ;  
                system.assertEquals( objAccount.CMD_Sub_Segment__c, strIndustrySubSegment ) ;  
            }
                                  
            system.assertEquals( objAccount.FulFillment_Channel__c , objCustomer.FulFillment_Channel__c ) ;  
            system.assertEquals( objAccount.Type, objCustomer.Type__c ) ;
            system.assertEquals( objAccount.Role__c, objCustomer.Role__c ) ;            
            system.assertEquals( objAccount.IsInactive__c , false ) ; 
            system.assertEquals( objAccount.DUNS_Number__c, objCustomer.DUNS__c ) ; 
            system.assertEquals( objAccount.House_Number__c, objCustomer.House_Number__c ) ; 
            system.assertEquals( objAccount.Street__c , objCustomer.Street__c) ; 
            system.assertEquals( objAccount.Street2__c ,objCustomer.Street_2__c) ;
            system.assertEquals( objAccount.Street3__c, objCustomer.Street_3__c ) ; 
            system.assertEquals( objAccount.City__c, objCustomer.City__c ) ; 
            system.assertEquals( objAccount.Country__c.toLowerCase(), objCustomer.Country__c.toLowerCase()) ;
            system.assertEquals( objAccount.State_Province__c.toLowerCase(), objCustomer.State__c.toLowerCase()) ; 
            system.assertEquals( objAccount.ZIP_Postal_Code__c, objCustomer.Zip__c) ;
            system.assertEquals( objAccount.SIC_Code__c, objCustomer.SIC_Code__c) ; 
            system.assertEquals( objAccount.NAICS_Code__c, objCustomer.NAICS_Code__c); 
            system.assertEquals( objAccount.Website, objCustomer.Website__c);          
            system.assertEquals( objAccount.Email__c, objCustomer.Email__c);  
            system.assertEquals( objAccount.Fax, objCustomer.Fax__c);
            system.assertEquals( objAccount.Phone, objCustomer.Telephone__c);
        } 
        //stop the test
        test.stopTest();
    }
    
    /********************************************************************************
        Case - Existing Global Enterprise Customer/Location Customer
    *********************************************************************************/    
    
    static testMethod void Hub2CrmInterfaceTest2() 
    {
        //prepare test data        
        fetchRecordTypes();
        
        //set Sales__c false for  customers
        List<Customer__c> lstCustomers = new List<Customer__c>();
        Customer__c objCustomer;      
        
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            if(Math.mod(i,2)== 0)
            {  
                objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                                Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
            }
            else
            {
                objCustomer = new Customer__c(RecordTypeId = locationCustomer.Id, Account_Name__c = 'ut_location' + i ,
                                                Legal_Name__c = 'ut_location' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');         
            }
            lstCustomers.add(objCustomer);
        }     
        
        insert lstCustomers;
        
        //assert record ids       
        Set<Id> customerIds = new Set<Id>();
        for(Customer__c obj :  lstCustomers)
        {
            system.assert(obj.Id != null);
            customerIds.add(obj.Id);
        }
        
        //start the test
        test.startTest();
        
        //fetch all customer records
        lstCustomers = [Select Id , Name , Account_Name__c , Legal_Name__c , DUNS__c , Status__c , DNB_Verified__c , House_Number__c ,
                            Street__c , City__c , Country__c , Region__c , Zip__c , Industry_Segment__c , Type__c , Role__c , GSM_Classification__c ,
                            Fulfillment_Channel__c,Street_2__c , Street_3__c ,State__c,Industry_Sub_Segment__c , SIC_Code__c , NAICS_Code__c ,
                            Website__c , EMail__c , Fax__c , Telephone__c 
                        From Customer__c 
                        Where Id IN :customerIds ];
                        
        //update customers now
        Boolean blOdd = false;
        for(Customer__c obj: lstCustomers)
        {
            obj.Legal_Name__c = obj.Legal_Name__c + '_changed';
            obj.Account_Name__c = obj.Account_Name__c + '_new';
                        
            if(blOdd)
            {
                obj.Industry_Segment__c = 'fake' ;
                obj.Industry_Sub_Segment__c = 'fake';
            }
            else
            {
                obj.Industry_Segment__c = 'EE - Consumer' ;
                obj.Industry_Sub_Segment__c = 'E1 - TV';
            }
            
            blOdd = !blOdd; 
        }

        CustomerTrigger.IsFirstRun_AfterUpdate = true;
        update lstCustomers;
        
        map<String, Customer__c> mapGidToCustomers = new map<String, Customer__c>();
        
        for(Customer__c obj : [Select Id , Name , Account_Name__c , Legal_Name__c , DUNS__c , Status__c , DNB_Verified__c , House_Number__c ,
                                    Street__c , City__c , Country__c , Region__c , Zip__c , Industry_Segment__c , Type__c , Role__c , GSM_Classification__c ,
                                    Fulfillment_Channel__c,Street_2__c , Street_3__c ,State__c,Industry_Sub_Segment__c , SIC_Code__c , NAICS_Code__c ,
                                    Website__c , EMail__c , Fax__c , Telephone__c 
                                From Customer__c 
                                Where Id IN :customerIds ])
        {
            mapGidToCustomers.put(obj.Name , obj);
        }
                            
        //fetch account records and assert results
        for( Account objAccount : [ Select Id, RecordTypeId, NXP_GID__c , Name , Legal_Name__c , Industry_Segment__c  , Customer_Category__c  , DNB_Verified__c ,
                                        Region__c , FulFillment_Channel__c , Role__c ,Sub_Segment__c  , Type , Country__c , State_Province__c , Street__c ,
                                        Street2__c , Street3__c , City__c , House_Number__c, ZIP_Postal_Code__c, DUNS_Number__c , SIC_Code__c , NAICS_Code__c ,
                                        Website  , Email__c , Fax , Phone, IsInactive__c , CMD_Short_Name__c , CMD_Industry_Segment__c , CMD_Sub_Segment__c , Status_of_D_B_Cleansing__c
                                    From  Account
                                    Where NXP_GID__c IN : mapGidToCustomers.keySet() ] )
        {
            objCustomer = mapGidToCustomers.get(objAccount.NXP_GID__c);
            system.assert(objCustomer != null);
            system.assertEquals( objAccount.RecordTypeId ,preAccount.Id ) ;
            system.assertEquals( objAccount.NXP_GID__c , objCustomer.Name ) ;
            //system.assertEquals( objAccount.Name , objCustomer.Account_Name__c ) ;
            system.assertEquals( objAccount.CMD_Short_Name__c , objCustomer.Account_Name__c ) ;
            system.assertEquals( objAccount.Legal_Name__c , objCustomer.Legal_Name__c ) ;            
            system.assertEquals( objAccount.Customer_Category__c , objCustomer.GSM_Classification__c ) ;            
            system.assertEquals( objAccount.DNB_Verified__c , objCustomer.DNB_Verified__c ) ; 
            system.assertEquals( objAccount.Status_of_D_B_Cleansing__c , objCustomer.DNB_Verified__c ) ;            
            
            if(objCustomer.Region__c.indexOf('-') > -1)
            {
                String strRegion = objCustomer.Region__c.substring(objCustomer.Region__c.indexOf('-') + 1).trim();
                system.assertEquals( objAccount.Region__c , strRegion ) ;  
            }
            
            if(objCustomer.Industry_Segment__c.indexOf('-') > -1)
            {
                String strIndustrySegment = objCustomer.Industry_Segment__c.substring(objCustomer.Industry_Segment__c.indexOf('-') + 1).trim();
                //system.assertEquals( objAccount.Industry_Segment__c , strIndustrySegment ) ;  
                system.assertEquals( objAccount.CMD_Industry_Segment__c , strIndustrySegment ) ;  
            } 
            
            if(objCustomer.Industry_Sub_Segment__c.indexOf('-') > -1)
            {
                String strIndustrySubSegment = objCustomer.Industry_Sub_Segment__c.substring(objCustomer.Industry_Sub_Segment__c.indexOf('-') + 1).trim();
                //system.assertEquals( objAccount.Sub_Segment__c, strIndustrySubSegment ) ;  
                system.assertEquals( objAccount.CMD_Sub_Segment__c, strIndustrySubSegment ) ;  
            }
                                  
            system.assertEquals( objAccount.FulFillment_Channel__c , objCustomer.FulFillment_Channel__c ) ;            
            system.assertEquals( objAccount.Type , objCustomer.Type__c ) ;
            system.assertEquals( objAccount.Role__c, objCustomer.Role__c ) ;            
            system.assertEquals( objAccount.IsInactive__c , false ) ; 
            system.assertEquals( objAccount.DUNS_Number__c, objCustomer.DUNS__c ) ; 
            system.assertEquals( objAccount.House_Number__c, objCustomer.House_Number__c ) ; 
            system.assertEquals( objAccount.Street__c , objCustomer.Street__c) ; 
            system.assertEquals( objAccount.Street2__c ,objCustomer.Street_2__c) ;
            system.assertEquals( objAccount.Street3__c, objCustomer.Street_3__c ) ; 
            system.assertEquals( objAccount.City__c, objCustomer.City__c ) ; 
            system.assertEquals( objAccount.Country__c.toLowerCase(), objCustomer.Country__c.toLowerCase()) ;
            system.assertEquals( objAccount.State_Province__c.toLowerCase(), objCustomer.State__c.toLowerCase()) ; 
            system.assertEquals( objAccount.ZIP_Postal_Code__c, objCustomer.Zip__c) ;
            system.assertEquals( objAccount.SIC_Code__c, objCustomer.SIC_Code__c) ; 
            system.assertEquals( objAccount.NAICS_Code__c, objCustomer.NAICS_Code__c); 
            system.assertEquals( objAccount.Website, objCustomer.Website__c);          
            system.assertEquals( objAccount.Email__c, objCustomer.Email__c);  
            system.assertEquals( objAccount.Fax, objCustomer.Fax__c);
            system.assertEquals( objAccount.Phone, objCustomer.Telephone__c);
        }
        
        //stop the test
        test.stopTest();
    }
    
    /********************************************************************************
        Case - Existsing Global Enterprise Customer - > New Pre Account  
    *********************************************************************************/    
    static testMethod void Hub2CrmInterfaceTest3() 
    {
        //prepare test data        
        fetchRecordTypes();
        List<Customer__c> lstCustomers = new List<Customer__c>();
        Customer__c objCustomer;
        
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            if(Math.mod(i,2)== 0)
            {  
                objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                                Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = false,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
            }
            else
            {
                objCustomer = new Customer__c(RecordTypeId = locationCustomer.Id, Account_Name__c = 'ut_Location ' + i ,
                                                Legal_Name__c = 'ut_Location ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = false,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
  
           }
           lstCustomers.add(objCustomer);
        }
        
        insert lstCustomers;
        //assert record ids       
        Set<Id> customerIds = new Set<Id>();
        for(Customer__c obj :  lstCustomers)
        {
            system.assert(obj.Id != null);
            customerIds.add(obj.Id);
        }
        
        //start the test
        test.startTest();
        
        map<String, Customer__c> mapGidToCustomers = new map<String, Customer__c>();
        
        for(Customer__c obj : [Select Id , Name , Account_Name__c , Legal_Name__c , DUNS__c , Status__c , DNB_Verified__c , House_Number__c ,
                                    Street__c , City__c , Country__c , Region__c , Zip__c , Industry_Segment__c , Type__c , Role__c , GSM_Classification__c ,
                                    Fulfillment_Channel__c,Street_2__c , Street_3__c ,State__c,Industry_Sub_Segment__c , SIC_Code__c , NAICS_Code__c ,
                                    Website__c , EMail__c , Fax__c , Telephone__c From Customer__c Where Id IN :customerIds ])
        {
            mapGidToCustomers.put(obj.Name , obj);
        }
                    
        //fetch account records and assert results
        for( Account objAccount : [ Select Id, RecordTypeId, NXP_GID__c , Name , Legal_Name__c , Industry_Segment__c  , Customer_Category__c  , DNB_Verified__c ,
                                        Region__c , FulFillment_Channel__c , Role__c , Sub_Segment__c  , Type , Country__c , State_Province__c , Street__c , Street2__c ,
                                        Street3__c , City__c , House_Number__c , ZIP_Postal_Code__c, DUNS_Number__c , SIC_Code__c , NAICS_Code__c , Website  ,
                                         Email__c , Fax , Phone, Parent.NXP_GID__c , IsInactive__c , CMD_Short_Name__c , CMD_Industry_Segment__c , CMD_Sub_Segment__c ,
                                         Status_of_D_B_Cleansing__c
                                    From  Account
                                    Where NXP_GID__c IN : mapGidToCustomers.keySet() ] )
        {
            system.assertEquals(mapGidToCustomers.containsKey(objAccount.NXP_GID__c) , false);
            system.assertEquals(mapGidToCustomers.isEmpty(), true);
        }
        
        // Loop through the list and update the sales field to true
        for(Customer__c obj : lstCustomers)
        {
            obj.Sales__c = true ;
        }

        update lstCustomers;

        //fetch account records and assert results
        for( Account objAccount : [ Select Id, RecordTypeId, NXP_GID__c , Name , Legal_Name__c , Industry_Segment__c  , Customer_Category__c  , DNB_Verified__c ,
                                        Region__c , FulFillment_Channel__c , Role__c ,Sub_Segment__c  , Type , Country__c , State_Province__c , Street__c , Street2__c ,
                                        Street3__c , City__c , House_Number__c,ZIP_Postal_Code__c, DUNS_Number__c , SIC_Code__c , NAICS_Code__c ,
                                        Website  , Email__c , Fax , Phone, Parent.NXP_GID__c , IsInactive__c , CMD_Short_Name__c , CMD_Industry_Segment__c , CMD_Sub_Segment__c ,
                                        Status_of_D_B_Cleansing__c  
                                    From  Account
                                    Where NXP_GID__c IN : mapGidToCustomers.keySet() ] )
        {
            objCustomer = mapGidToCustomers.get(objAccount.NXP_GID__c);
            system.assert(objCustomer != null);
            system.assertEquals( objAccount.RecordTypeId , preAccount.Id ) ;
            system.assertEquals( objAccount.NXP_GID__c , objCustomer.Name ) ;
            //system.assertEquals( objAccount.Name , objCustomer.Account_Name__c ) ;
            system.assertEquals( objAccount.CMD_Short_Name__c , objCustomer.Account_Name__c ) ;
            system.assertEquals( objAccount.Legal_Name__c , objCustomer.Legal_Name__c ) ;            
            system.assertEquals( objAccount.Customer_Category__c , objCustomer.GSM_Classification__c ) ;            
            system.assertEquals( objAccount.DNB_Verified__c , objCustomer.DNB_Verified__c ) ; 
            system.assertEquals( objAccount.Status_of_D_B_Cleansing__c , objCustomer.DNB_Verified__c ) ; 
            
            if(objCustomer.Region__c.indexOf('-') > -1)
            {
                String strRegion = objCustomer.Region__c.substring(objCustomer.Region__c.indexOf('-') + 1).trim();
                system.assertEquals( objAccount.Region__c , strRegion ) ;  
            }
            
            if(objCustomer.Industry_Segment__c.indexOf('-') > -1)
            {
                String strIndustrySegment = objCustomer.Industry_Segment__c.substring(objCustomer.Industry_Segment__c.indexOf('-') + 1).trim();
                //system.assertEquals( objAccount.Industry_Segment__c , strIndustrySegment ) ;  
                system.assertEquals( objAccount.CMD_Industry_Segment__c , strIndustrySegment ) ;  
            } 
            
            if(objCustomer.Industry_Sub_Segment__c.indexOf('-') > -1)
            {
                String strIndustrySubSegment = objCustomer.Industry_Sub_Segment__c.substring(objCustomer.Industry_Sub_Segment__c.indexOf('-') + 1).trim();
                //system.assertEquals( objAccount.Sub_Segment__c, strIndustrySubSegment ) ;  
                system.assertEquals( objAccount.CMD_Sub_Segment__c, strIndustrySubSegment ) ;  
            }                       
            system.assertEquals( objAccount.FulFillment_Channel__c , objCustomer.FulFillment_Channel__c ) ;            
            system.assertEquals( objAccount.Type , objCustomer.Type__c ) ;
            system.assertEquals( objAccount.Role__c , objCustomer.Role__c ) ;            
            system.assertEquals( objAccount.IsInactive__c , false ) ;
            system.assertEquals( objAccount.DUNS_Number__c, objCustomer.DUNS__c ) ; 
            system.assertEquals( objAccount.House_Number__c, objCustomer.House_Number__c ) ; 
            system.assertEquals( objAccount.Street__c , objCustomer.Street__c) ; 
            system.assertEquals( objAccount.Street2__c ,objCustomer.Street_2__c) ;
            system.assertEquals( objAccount.Street3__c, objCustomer.Street_3__c ) ; 
            system.assertEquals( objAccount.City__c, objCustomer.City__c ) ; 
            system.assertEquals( objAccount.Country__c.toLowerCase(), objCustomer.Country__c.toLowerCase());
            system.assertEquals( objAccount.State_Province__c.toLowerCase(), objCustomer.State__c.toLowerCase()) ; 
            system.assertEquals( objAccount.ZIP_Postal_Code__c, objCustomer.Zip__c) ;
            system.assertEquals( objAccount.SIC_Code__c, objCustomer.SIC_Code__c) ; 
            system.assertEquals( objAccount.NAICS_Code__c, objCustomer.NAICS_Code__c); 
            system.assertEquals( objAccount.Website, objCustomer.Website__c);          
            system.assertEquals( objAccount.Email__c, objCustomer.Email__c);  
            system.assertEquals( objAccount.Fax, objCustomer.Fax__c);
            system.assertEquals( objAccount.Phone, objCustomer.Telephone__c);
        }        
       
        //stop the test
        test.stopTest();
    }

    /***************************************************************************
        Case - Existing Global Enterprise Customer - > No Account created  
    ****************************************************************************/
    
    static testMethod void Hub2CrmInterfaceTest4() 
    {
        //prepare test data        
        fetchRecordTypes();
        
        //set Sales__c false for  customers
        List<Customer__c> lstCustomers = new List<Customer__c>();
        Customer__c objCustomer ;
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            if(Math.mod(i,2) == 0)
            {  
                objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                                Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = false,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
            }
            else
            {
                objCustomer = new Customer__c(RecordTypeId = locationCustomer.Id, Account_Name__c = 'ut_Location ' + i ,
                                                Legal_Name__c = 'ut_Location ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = false,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
            }
            lstCustomers.add(objCustomer);
        }
        
        insert lstCustomers;
        //assert record ids       
        Set<Id> customerIds = new Set<Id>();
        for(Customer__c obj :  lstCustomers)
        {
            system.assert(obj.Id != null);
            customerIds.add(obj.Id);
        }
        
        //start the test
        test.startTest();
        
        //update customers
        //Loop through the list and update the Industry Segment field
        for(Customer__c obj: lstCustomers)
        {
            obj.Legal_Name__c = obj.Legal_Name__c + '_changed';
            obj.Industry_Segment__c = 'EE - Consumer' ;
            obj.Industry_Sub_Segment__c = 'E1 - TV';
        }

        update lstCustomers;
        
        map<String, Customer__c> mapGidToCustomers = new map<String, Customer__c>();
        
        for(Customer__c obj : [Select Id , Name , Account_Name__c From Customer__c Where Id IN :customerIds ])
        {
            mapGidToCustomers.put(obj.Name , obj);
        }
            
        //fetch account records and assert results
        for( Account objAccount : [ Select Id, RecordTypeId, NXP_GID__c , Name , Legal_Name__c , Industry_Segment__c  , Customer_Category__c  , DNB_Verified__c ,
                                        Region__c , FulFillment_Channel__c , Role__c ,Sub_Segment__c  , Type , Country__c , State_Province__c , Street__c , Street2__c , 
                                        Street3__c , City__c , House_Number__c, ZIP_Postal_Code__c, DUNS_Number__c , SIC_Code__c , NAICS_Code__c , Website  , 
                                         Email__c , Fax , Phone, Parent.NXP_GID__c , IsInactive__c, CMD_Short_Name__c, CMD_Industry_Segment__c, CMD_Sub_Segment__c ,
                                         Status_of_D_B_Cleansing__c
                                    From  Account
                                    Where NXP_GID__c IN : mapGidToCustomers.keySet() ] )
        {
            system.assertEquals(mapGidToCustomers.containsKey(objAccount.NXP_GID__c) , false);
            system.assertEquals(mapGidToCustomers.isEmpty(), true);
        } 
        
        //stop test 
        test.stopTest();
    }
        
    /***************************************************************************
        Case - New Global Enterprise Customer - > New Customer contact added  
    ****************************************************************************/
    static testMethod void Hub2CrmInterfaceTest5() 
    {
        //prepare test data        
        fetchRecordTypes();
        
        List<Hub_Contact__c> lstHubContacts = createHubContacts();
        insert lstHubContacts;
        
        Map<Id, String> mapContactIdToEmail = new Map<Id, String>();        
        //assert hub contact records        
        for(Hub_Contact__c obj : lstHubContacts)
        {
            system.assert(obj.Id != null);
            mapContactIdToEmail.put(obj.Id, obj.Email__c);          
        }
                
        List<Customer__c> lstCustomers = new List<Customer__c>();                
        Customer__c objCustomer;
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                                Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
       
            lstCustomers.add(objCustomer);                                            
        }
        insert lstCustomers;
        
        Set<Id> customerIds = new Set<Id>();
        for(Customer__c obj : lstCustomers)
        {
            system.assert(obj.Id != null);
            customerIds.add(obj.Id);        
        }
        
        //fetch NXP GIDs for these Customers

        Map<Id, String> mapCustomerIdToGid = new Map<Id, String>();
                
        for(Customer__c obj : [Select Id, Name From Customer__c Where Id in :customerIds])
        {
            mapCustomerIdToGid.put(obj.Id, obj.Name);
        }
        
         //start the test
        test.startTest();
        
        List<User> lstUsers = createManagerUsers();
        insert lstUsers;
        //assert user records
        for(User obj : lstUsers)
        {
            system.assert(obj.Id != null);
        }
        
        List<Customer_Contact__c> lstCustomerContacts = new List<Customer_Contact__c>();
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c = CustomerContactTrigger.REGION_GLOBAL, Contact__c = lstHubContacts[0].Id, Customer__c= lstCustomers[i].Id ));       
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c = CustomerContactTrigger.REGION_AMEC, Contact__c = lstHubContacts[1].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_EMEA, Contact__c = lstHubContacts[2].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_GC, Contact__c = lstHubContacts[3].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_JAPAN, Contact__c = lstHubContacts[4].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_KOREA, Contact__c = lstHubContacts[5].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_KOREA, Contact__c = lstHubContacts[6].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[7].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[8].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[9].Id, Customer__c= lstCustomers[i].Id ));
            
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c = CustomerContactTrigger.REGION_GLOBAL, Contact__c = lstHubContacts[10].Id, Customer__c= lstCustomers[i].Id ));       
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c = CustomerContactTrigger.REGION_AMEC, Contact__c = lstHubContacts[11].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_EMEA, Contact__c = lstHubContacts[12].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_GC, Contact__c = lstHubContacts[13].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_JAPAN, Contact__c = lstHubContacts[14].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_KOREA, Contact__c = lstHubContacts[15].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[16].Id, Customer__c= lstCustomers[i].Id ));
        } 
        
        insert lstCustomerContacts;
        
        //assert customer contact records
        for(Customer_Contact__c obj : lstCustomerContacts)
        {
            system.assert(obj.Id != null);   
        }
        
        //fetch all SF-CRM Account records matching NXP-GIDs for these customers
        Map<String, Account> mapCustomerGidToAccount = new Map<String , Account>();
       
        for(Account acc : [Select Id, NXP_GID__c, Account_Manager__c , Account_Manager_AMEC__c, Account_Manager_EMEA__c ,
                                    Account_Manager_GC__c , Account_Manager_Japan__c , Account_Manager_Korea__c , Account_Manager_Korea_2__c , Account_Manager_SAP__c ,
                                    Account_Manager_SAP_2__c , Account_Manager_SAP_3__c , Service_Manager__c  , Service_Manager_AMEC__c , Service_Manager_EMEA__c ,
                                    Service_Manager_GC__c , Service_Manager_Japan__c , Service_Manager_Korea__c , Service_Manager_SAP__c , Account_Manager__r.Email , Account_Manager_AMEC__r.Email , Account_Manager_EMEA__r.Email ,
                                Account_Manager_GC__r.Email , Account_Manager_Japan__r.Email , Account_Manager_Korea__r.Email , Account_Manager_Korea_2__r.Email , Account_Manager_SAP__r.Email ,
                                Account_Manager_SAP_2__r.Email , Account_Manager_SAP_3__r.Email , Service_Manager__r.Email  , Service_Manager_AMEC__r.Email , Service_Manager_EMEA__r.Email ,
                                Service_Manager_GC__r.Email , Service_Manager_Japan__r.Email , Service_Manager_Korea__r.Email , Service_Manager_SAP__r.Email
                            From Account 
                            Where NXP_GID__c in : mapCustomerIdToGid.values() 
                                and (RecordTypeId =: parentAccount.Id OR RecordTypeId =: preAccount.Id)])
        {
            mapCustomerGidToAccount.put(acc.NXP_GID__c , acc);  
        }
        
        
        //assert the results
        for(Customer_Contact__c obj : lstCustomerContacts)
        {
            //find corresponding Hub Contact's Email
            String contactEmail = mapContactIdToEmail.get(obj.Contact__c);
            system.assert(contactEmail != null);
            
            //find corresponding account record
            String customerGid = mapCustomerIdToGid.get(obj.Customer__c);
            system.assert(customerGid != null);
            
            Account acc =  mapCustomerGidToAccount.get(customerGid);
            system.assert(acc != null);
            
            System.assert( acc.Account_Manager__c != null);
            System.assert( acc.Account_Manager_AMEC__c != null ) ;
            System.assert( acc.Account_Manager_EMEA__c != null) ;
            System.assert( acc.Account_Manager_GC__c != null ) ;
            System.assert( acc.Account_Manager_Japan__c != null ) ;
            System.assert( acc.Account_Manager_Korea__c != null ) ;
            System.assert( acc.Account_Manager_Korea_2__c != null ) ;
            System.assert( acc.Account_Manager_SAP__c != null ) ;
            System.assert( acc.Account_Manager_SAP_2__c != null ) ;
            System.assert( acc.Account_Manager_SAP_3__c != null ) ;
            System.assert( acc.Service_Manager__c != null ) ;
            System.assert( acc.Service_Manager_AMEC__c != null ) ;
            System.assert( acc.Service_Manager_EMEA__c != null ) ;
            System.assert( acc.Service_Manager_GC__c != null) ;
            System.assert( acc.Service_Manager_Japan__c != null ) ;
            System.assert( acc.Service_Manager_Korea__c != null ) ;
            System.assert( acc.Service_Manager_SAP__c != null ) ;
            
            if(obj.Role__c == CustomerContactTrigger.ROLE_ACCOUNT_MANAGER)
            {
                if(obj.Region__c == CustomerContactTrigger.REGION_GLOBAL)
                {
                    System.assertEquals( acc.Account_Manager__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_AMEC)
                {
                    System.assertEquals( acc.Account_Manager_AMEC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_EMEA)
                {
                    System.assertEquals( acc.Account_Manager_EMEA__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_GC)
                {
                    System.assertEquals( acc.Account_Manager_GC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_JAPAN)
                {
                    System.assertEquals( acc.Account_Manager_JAPAN__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_KOREA)
                {                   
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_SAP)
                {                   
                }
            }
            else if(obj.Role__c == CustomerContactTrigger.ROLE_SERVICE_MANAGER)
            {
                if(obj.Region__c == CustomerContactTrigger.REGION_GLOBAL)
                {
                    System.assertEquals( acc.Service_Manager__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_AMEC)
                {
                    System.assertEquals( acc.Service_Manager_AMEC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_EMEA)
                {
                    System.assertEquals( acc.Service_Manager_EMEA__r.Email , contactEmail ) ;                                   
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_GC)
                {
                    System.assertEquals( acc.Service_Manager_GC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_JAPAN)
                {
                    System.assertEquals( acc.Service_Manager_Japan__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_KOREA)
                {
                    System.assertEquals( acc.Service_Manager_Korea__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_SAP)
                {
                    System.assertEquals( acc.Service_Manager_SAP__r.Email , contactEmail ) ;
                }
            }
        }
        //stop the test           
        test.stopTest();                                                   
    }

    /***************************************************************************
        Case - Update Customer Contact -> Account record updated  
    ****************************************************************************/
    static testMethod void Hub2CrmInterfaceTest6() 
    {
        //prepare test data        
        fetchRecordTypes();
        
        List<Hub_Contact__c> lstHubContacts = createHubContacts();
        insert lstHubContacts;
        
        Map<Id, String> mapContactIdToEmail = new Map<Id, String>();
        
        //assert hub contact records        
        for(Hub_Contact__c obj : lstHubContacts)
        {
            system.assert(obj.Id != null);
            mapContactIdToEmail.put(obj.Id, obj.Email__c);          
        }
                    
        List<Customer__c> lstCustomers = new List<Customer__c>();                
        Customer__c objCustomer;
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                                Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
       
            lstCustomers.add(objCustomer);                                            
        }
        insert lstCustomers;
        
        Set<Id> customerIds = new Set<Id>();
        for(Customer__c obj : lstCustomers)
        {
            system.assert(obj.Id != null);
            customerIds.add(obj.Id);        
        }
        
        //fetch NXP GIDs for these Customers
        Map<Id, String> mapCustomerIdToGid = new Map<Id, String>();
                
        for(Customer__c obj : [Select Id, Name From Customer__c Where Id in :customerIds])
        {
            mapCustomerIdToGid.put(obj.Id, obj.Name);
        }
        
        //start the test
        test.startTest();
        
        List<User> lstUsers = createManagerUsers();
        insert lstUsers;
        //assert user records
        for(User obj : lstUsers)
        {
            system.assert(obj.Id != null);
        }  
        
        List<Customer_Contact__c> lstCustomerContacts = new List<Customer_Contact__c>();
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c = CustomerContactTrigger.REGION_GLOBAL, Contact__c = lstHubContacts[10].Id, Customer__c= lstCustomers[i].Id ));       
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c = CustomerContactTrigger.REGION_AMEC, Contact__c = lstHubContacts[11].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_EMEA, Contact__c = lstHubContacts[12].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_GC, Contact__c = lstHubContacts[13].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_JAPAN, Contact__c = lstHubContacts[14].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_KOREA, Contact__c = lstHubContacts[15].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[16].Id, Customer__c= lstCustomers[i].Id ));
       } 
        
        insert lstCustomerContacts;
        
        //assert customer contact records
        for(Customer_Contact__c obj : lstCustomerContacts)
        {
            system.assert(obj.Id != null);   
        }
        
        //fetch all SF-CRM Account records matching NXP-GIDs for these customers
        Map<String, Account> mapCustomerGidToAccount = new Map<String , Account>();
       
        for(Account acc : [Select Id, NXP_GID__c, Account_Manager__c , Account_Manager_AMEC__c, Account_Manager_EMEA__c ,
                                    Account_Manager_GC__c , Account_Manager_Japan__c , Account_Manager_Korea__c , Account_Manager_Korea_2__c , Account_Manager_SAP__c ,
                                    Account_Manager_SAP_2__c , Account_Manager_SAP_3__c , Service_Manager__c  , Service_Manager_AMEC__c , Service_Manager_EMEA__c ,
                                    Service_Manager_GC__c , Service_Manager_Japan__c , Service_Manager_Korea__c , Service_Manager_SAP__c , Account_Manager__r.Email , Account_Manager_AMEC__r.Email , Account_Manager_EMEA__r.Email ,
                                Account_Manager_GC__r.Email , Account_Manager_Japan__r.Email , Account_Manager_Korea__r.Email , Account_Manager_Korea_2__r.Email , Account_Manager_SAP__r.Email ,
                                Account_Manager_SAP_2__r.Email , Account_Manager_SAP_3__r.Email , Service_Manager__r.Email  , Service_Manager_AMEC__r.Email , Service_Manager_EMEA__r.Email ,
                                Service_Manager_GC__r.Email , Service_Manager_Japan__r.Email , Service_Manager_Korea__r.Email , Service_Manager_SAP__r.Email
                            From Account 
                            Where NXP_GID__c in : mapCustomerIdToGid.values() 
                                and (RecordTypeId =: parentAccount.Id OR RecordTypeId =: preAccount.Id)])
        {
            mapCustomerGidToAccount.put(acc.NXP_GID__c , acc);  
        }       
        
        //assert the results
        for(Customer_Contact__c obj : lstCustomerContacts)
        {
            //find corresponding Hub Contact's Email
            String contactEmail = mapContactIdToEmail.get(obj.Contact__c);
            system.assert(contactEmail != null);
            
            //find corresponding account record
            String customerGid = mapCustomerIdToGid.get(obj.Customer__c);
            system.assert(customerGid != null);
            
            Account acc =  mapCustomerGidToAccount.get(customerGid);
            system.assert(acc != null);
            
            System.assert( acc.Account_Manager__c == null);
            System.assert( acc.Account_Manager_AMEC__c == null ) ;
            System.assert( acc.Account_Manager_EMEA__c == null) ;
            System.assert( acc.Account_Manager_GC__c == null ) ;
            System.assert( acc.Account_Manager_Japan__c == null ) ;
            System.assert( acc.Account_Manager_Korea__c == null ) ;
            System.assert( acc.Account_Manager_Korea_2__c == null ) ;
            System.assert( acc.Account_Manager_SAP__c == null ) ;
            System.assert( acc.Account_Manager_SAP_2__c == null ) ;
            System.assert( acc.Account_Manager_SAP_3__c == null ) ;
            System.assert( acc.Service_Manager__c != null ) ;
            System.assert( acc.Service_Manager_AMEC__c != null ) ;
            System.assert( acc.Service_Manager_EMEA__c != null ) ;
            System.assert( acc.Service_Manager_GC__c != null) ;
            System.assert( acc.Service_Manager_Japan__c != null ) ;
            System.assert( acc.Service_Manager_Korea__c != null ) ;
            System.assert( acc.Service_Manager_SAP__c != null ) ;
            
            if(obj.Role__c == CustomerContactTrigger.ROLE_ACCOUNT_MANAGER)
            {
                if(obj.Region__c == CustomerContactTrigger.REGION_GLOBAL)
                {
                    System.assertEquals( acc.Account_Manager__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_AMEC)
                {
                    System.assertEquals( acc.Account_Manager_AMEC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_EMEA)
                {
                    System.assertEquals( acc.Account_Manager_EMEA__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_GC)
                {
                    System.assertEquals( acc.Account_Manager_GC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_JAPAN)
                {
                    System.assertEquals( acc.Account_Manager_JAPAN__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_KOREA)
                {                   
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_SAP)
                {                   
                }
            }
            else if(obj.Role__c == CustomerContactTrigger.ROLE_SERVICE_MANAGER)
            {
                if(obj.Region__c == CustomerContactTrigger.REGION_GLOBAL)
                {
                    System.assertEquals( acc.Service_Manager__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_AMEC)
                {
                    System.assertEquals( acc.Service_Manager_AMEC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_EMEA)
                {
                    System.assertEquals( acc.Service_Manager_EMEA__r.Email , contactEmail ) ;                                   
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_GC)
                {
                    System.assertEquals( acc.Service_Manager_GC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_JAPAN)
                {
                    System.assertEquals( acc.Service_Manager_Japan__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_KOREA)
                {
                    System.assertEquals( acc.Service_Manager_Korea__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_SAP)
                {
                    System.assertEquals( acc.Service_Manager_SAP__r.Email , contactEmail ) ;
                }
            }
        }
        
        //update the Customer Contact Records
        for(Customer_Contact__c obj : lstCustomerContacts)
        {
            obj.Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER;
        }        
        update lstCustomerContacts;
        
        mapCustomerGidToAccount = new Map<String, Account>(); 
        for(Account acc : [Select Id, NXP_GID__c, Account_Manager__c , Account_Manager_AMEC__c, Account_Manager_EMEA__c ,
                                    Account_Manager_GC__c , Account_Manager_Japan__c , Account_Manager_Korea__c , Account_Manager_Korea_2__c , Account_Manager_SAP__c ,
                                    Account_Manager_SAP_2__c , Account_Manager_SAP_3__c , Service_Manager__c  , Service_Manager_AMEC__c , Service_Manager_EMEA__c ,
                                    Service_Manager_GC__c , Service_Manager_Japan__c , Service_Manager_Korea__c , Service_Manager_SAP__c , Account_Manager__r.Email , Account_Manager_AMEC__r.Email , Account_Manager_EMEA__r.Email ,
                                Account_Manager_GC__r.Email , Account_Manager_Japan__r.Email , Account_Manager_Korea__r.Email , Account_Manager_Korea_2__r.Email , Account_Manager_SAP__r.Email ,
                                Account_Manager_SAP_2__r.Email , Account_Manager_SAP_3__r.Email , Service_Manager__r.Email  , Service_Manager_AMEC__r.Email , Service_Manager_EMEA__r.Email ,
                                Service_Manager_GC__r.Email , Service_Manager_Japan__r.Email , Service_Manager_Korea__r.Email , Service_Manager_SAP__r.Email
                            From Account 
                            Where NXP_GID__c in : mapCustomerIdToGid.values() 
                                and (RecordTypeId =: parentAccount.Id OR RecordTypeId =: preAccount.Id)])
        {
            mapCustomerGidToAccount.put(acc.NXP_GID__c , acc);  
        }
        
        //assert the results
        for(Customer_Contact__c obj : lstCustomerContacts)
        {
            //find corresponding Hub Contact's Email
            String contactEmail = mapContactIdToEmail.get(obj.Contact__c);
            system.assert(contactEmail != null);
            
            //find corresponding account record
            String customerGid = mapCustomerIdToGid.get(obj.Customer__c);
            system.assert(customerGid != null);
            
            Account acc =  mapCustomerGidToAccount.get(customerGid);
            system.assert(acc != null);
                        
            System.assert( acc.Account_Manager__c != null);
            System.assert( acc.Account_Manager_AMEC__c != null ) ;
            System.assert( acc.Account_Manager_EMEA__c != null) ;
            System.assert( acc.Account_Manager_GC__c != null ) ;
            System.assert( acc.Account_Manager_Japan__c != null ) ;
            System.assert( acc.Account_Manager_Korea__c != null ) ;
            System.assert( acc.Account_Manager_Korea_2__c == null ) ;
            System.assert( acc.Account_Manager_SAP__c != null ) ;
            System.assert( acc.Account_Manager_SAP_2__c == null ) ;
            System.assert( acc.Account_Manager_SAP_3__c == null ) ;
            System.assert( acc.Service_Manager__c == null ) ;
            System.assert( acc.Service_Manager_AMEC__c == null ) ;
            System.assert( acc.Service_Manager_EMEA__c == null ) ;
            System.assert( acc.Service_Manager_GC__c == null) ;
            System.assert( acc.Service_Manager_Japan__c == null ) ;
            System.assert( acc.Service_Manager_Korea__c == null ) ;
            System.assert( acc.Service_Manager_SAP__c == null ) ;
            
            if(obj.Role__c == CustomerContactTrigger.ROLE_ACCOUNT_MANAGER)
            {
                if(obj.Region__c == CustomerContactTrigger.REGION_GLOBAL)
                {
                    System.assertEquals( acc.Account_Manager__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_AMEC)
                {
                    System.assertEquals( acc.Account_Manager_AMEC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_EMEA)
                {
                    System.assertEquals( acc.Account_Manager_EMEA__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_GC)
                {
                    System.assertEquals( acc.Account_Manager_GC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_JAPAN)
                {
                    System.assertEquals( acc.Account_Manager_JAPAN__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_KOREA)
                {
                    System.assertEquals( acc.Account_Manager_Korea__r.Email , contactEmail ) ;                  
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_SAP)
                {
                    System.assertEquals( acc.Account_Manager_SAP__r.Email , contactEmail ) ;                        
                }
            }
            else if(obj.Role__c == CustomerContactTrigger.ROLE_SERVICE_MANAGER)
            {
                if(obj.Region__c == CustomerContactTrigger.REGION_GLOBAL)
                {
                    System.assertEquals( acc.Service_Manager__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_AMEC)
                {
                    System.assertEquals( acc.Service_Manager_AMEC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_EMEA)
                {
                    System.assertEquals( acc.Service_Manager_EMEA__r.Email , contactEmail ) ;                                   
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_GC)
                {
                    System.assertEquals( acc.Service_Manager_GC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_JAPAN)
                {
                    System.assertEquals( acc.Service_Manager_Japan__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_KOREA)
                {
                    System.assertEquals( acc.Service_Manager_Korea__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_SAP)
                {
                    System.assertEquals( acc.Service_Manager_SAP__r.Email , contactEmail ) ;
                }
            }
        }
        
        //stop the test           
        test.stopTest();
    }
    
    /***************************************************************************
        Case - Customer Contact Deleted -> Account record updated  
    ****************************************************************************/
    static testMethod void Hub2CrmInterfaceTest7() 
    {
        //prepare test data        
        fetchRecordTypes();        
        List<Hub_Contact__c> lstHubContacts = createHubContacts();
        insert lstHubContacts;
        
        Map<Id, String> mapContactIdToEmail = new Map<Id, String>();
        
        //assert hub contact records        
        for(Hub_Contact__c obj : lstHubContacts)
        {
            system.assert(obj.Id != null);
            mapContactIdToEmail.put(obj.Id, obj.Email__c);          
        }    
                
        List<Customer__c> lstCustomers = new List<Customer__c>();                
        Customer__c objCustomer;
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                                Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                                Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                                House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                                City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                                Zip__c = 'ut_zip' + i , Industry_Segment__c = 'FF - Computing' ,
                                                Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2' + i ,
                                                Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                                SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                Fax__c = '+1234567890', Telephone__c = '+1234567890');
       
            lstCustomers.add(objCustomer);                                            
        }
        insert lstCustomers;
        
        Set<Id> customerIds = new Set<Id>();
        for(Customer__c obj : lstCustomers)
        {
            system.assert(obj.Id != null);
            customerIds.add(obj.Id);        
        }
        
        //fetch NXP GIDs for these Customers
        Map<Id, String> mapCustomerIdToGid = new Map<Id, String>();             
        for(Customer__c obj : [Select Id, Name From Customer__c Where Id in :customerIds])
        {
            mapCustomerIdToGid.put(obj.Id, obj.Name);
        }
        
        //start the test
        test.startTest();
        
        List<User> lstUsers = createManagerUsers();
        insert lstUsers;
        
        //assert user records
        for(User obj : lstUsers)
        {
            system.assert(obj.Id != null);
        }  
        
        List<Customer_Contact__c> lstCustomerContacts = new List<Customer_Contact__c>();                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c = CustomerContactTrigger.REGION_GLOBAL, Contact__c = lstHubContacts[0].Id, Customer__c= lstCustomers[i].Id ));       
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c = CustomerContactTrigger.REGION_AMEC, Contact__c = lstHubContacts[1].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_EMEA, Contact__c = lstHubContacts[2].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_GC, Contact__c = lstHubContacts[3].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_JAPAN, Contact__c = lstHubContacts[4].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_KOREA, Contact__c = lstHubContacts[5].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_KOREA, Contact__c = lstHubContacts[6].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[7].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[8].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_ACCOUNT_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[9].Id, Customer__c= lstCustomers[i].Id ));
            
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c = CustomerContactTrigger.REGION_GLOBAL, Contact__c = lstHubContacts[10].Id, Customer__c= lstCustomers[i].Id ));       
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c = CustomerContactTrigger.REGION_AMEC, Contact__c = lstHubContacts[11].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_EMEA, Contact__c = lstHubContacts[12].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_GC, Contact__c = lstHubContacts[13].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_JAPAN, Contact__c = lstHubContacts[14].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_KOREA, Contact__c = lstHubContacts[15].Id, Customer__c= lstCustomers[i].Id ));
            lstCustomerContacts.add(new Customer_Contact__c(Role__c = CustomerContactTrigger.ROLE_SERVICE_MANAGER , Region__c =CustomerContactTrigger.REGION_SAP, Contact__c = lstHubContacts[16].Id, Customer__c= lstCustomers[i].Id ));
       } 
        
        insert lstCustomerContacts;
        
        //assert customer contact records
        for(Customer_Contact__c obj : lstCustomerContacts)
        {
            system.assert(obj.Id != null);   
        }
        
        //fetch all SF-CRM Account records matching NXP-GIDs for these customers
        Map<String, Account> mapCustomerGidToAccount = new Map<String , Account>();
       
        for(Account acc : [Select Id, NXP_GID__c, Account_Manager__c , Account_Manager_AMEC__c, Account_Manager_EMEA__c ,
                                    Account_Manager_GC__c , Account_Manager_Japan__c , Account_Manager_Korea__c , Account_Manager_Korea_2__c , Account_Manager_SAP__c ,
                                    Account_Manager_SAP_2__c , Account_Manager_SAP_3__c , Service_Manager__c  , Service_Manager_AMEC__c , Service_Manager_EMEA__c ,
                                    Service_Manager_GC__c , Service_Manager_Japan__c , Service_Manager_Korea__c , Service_Manager_SAP__c , Account_Manager__r.Email , Account_Manager_AMEC__r.Email , Account_Manager_EMEA__r.Email ,
                                Account_Manager_GC__r.Email , Account_Manager_Japan__r.Email , Account_Manager_Korea__r.Email , Account_Manager_Korea_2__r.Email , Account_Manager_SAP__r.Email ,
                                Account_Manager_SAP_2__r.Email , Account_Manager_SAP_3__r.Email , Service_Manager__r.Email  , Service_Manager_AMEC__r.Email , Service_Manager_EMEA__r.Email ,
                                Service_Manager_GC__r.Email , Service_Manager_Japan__r.Email , Service_Manager_Korea__r.Email , Service_Manager_SAP__r.Email
                            From Account 
                            Where NXP_GID__c in : mapCustomerIdToGid.values() 
                                and (RecordTypeId =: parentAccount.Id OR RecordTypeId =: preAccount.Id)])
        {
            mapCustomerGidToAccount.put(acc.NXP_GID__c , acc);  
        }
        
        
        //assert the results
        for(Customer_Contact__c obj : lstCustomerContacts)
        {
            //find corresponding Hub Contact's Email
            String contactEmail = mapContactIdToEmail.get(obj.Contact__c);
            system.assert(contactEmail != null);
            
            //find corresponding account record
            String customerGid = mapCustomerIdToGid.get(obj.Customer__c);
            system.assert(customerGid != null);
            
            Account acc =  mapCustomerGidToAccount.get(customerGid);
            system.assert(acc != null);
            
            System.assert( acc.Account_Manager__c != null);
            System.assert( acc.Account_Manager_AMEC__c != null ) ;
            System.assert( acc.Account_Manager_EMEA__c != null) ;
            System.assert( acc.Account_Manager_GC__c != null ) ;
            System.assert( acc.Account_Manager_Japan__c != null ) ;
            System.assert( acc.Account_Manager_Korea__c != null ) ;
            System.assert( acc.Account_Manager_Korea_2__c != null ) ;
            System.assert( acc.Account_Manager_SAP__c != null ) ;
            System.assert( acc.Account_Manager_SAP_2__c != null ) ;
            System.assert( acc.Account_Manager_SAP_3__c != null ) ;
            System.assert( acc.Service_Manager__c != null ) ;
            System.assert( acc.Service_Manager_AMEC__c != null ) ;
            System.assert( acc.Service_Manager_EMEA__c != null ) ;
            System.assert( acc.Service_Manager_GC__c != null) ;
            System.assert( acc.Service_Manager_Japan__c != null ) ;
            System.assert( acc.Service_Manager_Korea__c != null ) ;
            System.assert( acc.Service_Manager_SAP__c != null ) ;
            
            if(obj.Role__c == CustomerContactTrigger.ROLE_ACCOUNT_MANAGER)
            {
                if(obj.Region__c == CustomerContactTrigger.REGION_GLOBAL)
                {
                    System.assertEquals( acc.Account_Manager__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_AMEC)
                {
                    System.assertEquals( acc.Account_Manager_AMEC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_EMEA)
                {
                    System.assertEquals( acc.Account_Manager_EMEA__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_GC)
                {
                    System.assertEquals( acc.Account_Manager_GC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_JAPAN)
                {
                    System.assertEquals( acc.Account_Manager_JAPAN__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_KOREA)
                {                   
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_SAP)
                {                   
                }
            }
            else if(obj.Role__c == CustomerContactTrigger.ROLE_SERVICE_MANAGER)
            {
                if(obj.Region__c == CustomerContactTrigger.REGION_GLOBAL)
                {
                    System.assertEquals( acc.Service_Manager__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_AMEC)
                {
                    System.assertEquals( acc.Service_Manager_AMEC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_EMEA)
                {
                    System.assertEquals( acc.Service_Manager_EMEA__r.Email , contactEmail ) ;                                   
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_GC)
                {
                    System.assertEquals( acc.Service_Manager_GC__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_JAPAN)
                {
                    System.assertEquals( acc.Service_Manager_Japan__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_KOREA)
                {
                    System.assertEquals( acc.Service_Manager_Korea__r.Email , contactEmail ) ;
                }
                else if(obj.Region__c == CustomerContactTrigger.REGION_SAP)
                {
                    System.assertEquals( acc.Service_Manager_SAP__r.Email , contactEmail ) ;
                }
            }
        }
        
        //delete customer contacts        
        delete lstCustomerContacts;
        
        //fetch account records again
        for(Account acc : [Select Id, NXP_GID__c, Account_Manager__c , Account_Manager_AMEC__c, Account_Manager_EMEA__c ,
                                    Account_Manager_GC__c , Account_Manager_Japan__c , Account_Manager_Korea__c , Account_Manager_Korea_2__c , Account_Manager_SAP__c ,
                                    Account_Manager_SAP_2__c , Account_Manager_SAP_3__c , Service_Manager__c  , Service_Manager_AMEC__c , Service_Manager_EMEA__c ,
                                    Service_Manager_GC__c , Service_Manager_Japan__c , Service_Manager_Korea__c , Service_Manager_SAP__c , Account_Manager__r.Email , Account_Manager_AMEC__r.Email , Account_Manager_EMEA__r.Email ,
                                Account_Manager_GC__r.Email , Account_Manager_Japan__r.Email , Account_Manager_Korea__r.Email , Account_Manager_Korea_2__r.Email , Account_Manager_SAP__r.Email ,
                                Account_Manager_SAP_2__r.Email , Account_Manager_SAP_3__r.Email , Service_Manager__r.Email  , Service_Manager_AMEC__r.Email , Service_Manager_EMEA__r.Email ,
                                Service_Manager_GC__r.Email , Service_Manager_Japan__r.Email , Service_Manager_Korea__r.Email , Service_Manager_SAP__r.Email
                            From Account 
                            Where NXP_GID__c IN : mapCustomerGidToAccount.keySet()])
        {
            System.assert( acc.Account_Manager__c == null);
            System.assert( acc.Account_Manager_AMEC__c == null ) ;
            System.assert( acc.Account_Manager_EMEA__c == null) ;
            System.assert( acc.Account_Manager_GC__c == null ) ;
            System.assert( acc.Account_Manager_Japan__c == null ) ;
            System.assert( acc.Account_Manager_Korea__c == null ) ;
            System.assert( acc.Account_Manager_Korea_2__c == null ) ;
            System.assert( acc.Account_Manager_SAP__c == null ) ;
            System.assert( acc.Account_Manager_SAP_2__c == null ) ;
            System.assert( acc.Account_Manager_SAP_3__c == null ) ;
            System.assert( acc.Service_Manager__c == null ) ;
            System.assert( acc.Service_Manager_AMEC__c == null ) ;
            System.assert( acc.Service_Manager_EMEA__c == null ) ;
            System.assert( acc.Service_Manager_GC__c == null) ;
            System.assert( acc.Service_Manager_Japan__c == null ) ;
            System.assert( acc.Service_Manager_Korea__c == null ) ;
            System.assert( acc.Service_Manager_SAP__c == null ) ;
        }
        
        //stop the test           
        test.stopTest();                                                   
    }   
    
    /***************************************************************************
        Test ConvertRegionCode function  
    ****************************************************************************/
    static testMethod void Hub2CrmInterfaceTest8() 
    {
        test.startTest();
        System.assert(CustomerTrigger.ConvertRegionCode('EU - EMEA').equalsIgnoreCase('EMEA'));
        System.assert(CustomerTrigger.ConvertRegionCode('AP - JAPAN').equalsIgnoreCase('Japan'));
        System.assert(CustomerTrigger.ConvertRegionCode('AP - KOREA').equalsIgnoreCase('Korea'));
        System.assert(CustomerTrigger.ConvertRegionCode('AP - GC').equalsIgnoreCase('Greater China'));
        System.assert(CustomerTrigger.ConvertRegionCode('AM - AMEC').equalsIgnoreCase('Americas'));
        System.assert(CustomerTrigger.ConvertRegionCode('AP - SAP').equalsIgnoreCase('South Asia Pacific'));
        System.assert(CustomerTrigger.ConvertRegionCode('test').equalsIgnoreCase('test'));
        test.stopTest();
    }
}