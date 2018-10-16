/**********************************************************************************************
@Created By :       Ranganath C N
@Created Date:      01 Jun 2018
@Description:       Test Class for Controller class SearchAndSelectContactsController

**************************************************************************************/
@isTest
private class SearchAndSelectContactsControllerTest 
{
    
            
   static testMethod void testDoGet() {
  
           
           
            Account testaccount = new Account();
            testaccount.Name='john';
            insert testaccount;
            
            Contact testcontact = new Contact();
            testcontact.LastName = 'CNR';
            testcontact.email='test@CN.BOSCH.COM';
            insert testcontact;
            
            SearchAndSelectContactsController ssc = new SearchAndSelectContactsController();
           String emailId = 'test@CN.BOSCH.COM';
           //ssc.lstRet();
      }
          
}