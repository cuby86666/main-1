/*
@Created By :       Nisha Agrawal
@Created Date:      28 Sep 2012
@Description:       Trigger to create Task when Status of D&B Cleansing field changes to 'Cant Upload' and 'Please Review'              
*/



trigger AfterUpdate_Account on Account (after update) 
{
    Account oldAccount;
    List<Task> lstTasks = new List<Task>();
    Task objTask;
   // list<id> listId=new List<id>();
    //for()
    //get the record type
    List<RecordType> lstRecordTypes = [Select Id, DeveloperName, SobjectType  
                                       From RecordType
                                       Where SobjectType = 'Account' and DeveloperName = 'Child_Account' and IsActive=true
                                       Limit 1];
                               
    RecordType childAccount;
    if(lstRecordTypes.size() > 0)
    {
        childAccount = lstRecordTypes[0];
    }
    
    for(Account acc : Trigger.New)
    {  
        //if record type is "Child" 
        if(acc.RecordTypeId == childAccount.Id)
        {
            oldAccount = Trigger.oldMap.get(acc.Id);
            
            //check if Status_of_D_B_Cleansing__c is  'Can't Upload'
            if(oldAccount.Status_of_D_B_Cleansing__c != acc.Status_of_D_B_Cleansing__c && acc.Status_of_D_B_Cleansing__c == 'Can\'t Upload')
            {
                objTask = new Task(Subject = 'Please Update your Account Address' , Priority = 'High' , WhatId = acc.Id , OwnerId = acc.OwnerId , ActivityDate = Date.today().addDays(7) , IsReminderSet = true , ReminderDateTime = Date.today().addDays(7));
                objTask.Description = 'Dear NXP Account Owner, NXP GSM has decided to standardize all Account names and addresses against Dun and Bradstreet. In the future, this will enable richer functionality for you, such as quoting and revenue.  Please log into SFDC and add your account Country and State.  Any additional address information will yield a more accurate match. For more information, please see the PPT (Partners, please log in before clicking the link): https://nxp.my.salesforce.com/069D00000010zdI';
                lstTasks.add(objTask);
            }
            
            //check if Status_of_D_B_Cleansing__c is  'Please Review'
            if(oldAccount.Status_of_D_B_Cleansing__c != acc.Status_of_D_B_Cleansing__c && acc.Status_of_D_B_Cleansing__c == 'Please Review')
            {
                objTask = new Task(Subject = 'Please Validate your Account Information' , Priority = 'High' , WhatId = acc.Id , OwnerId = acc.OwnerId , ActivityDate = Date.today().addDays(7), IsReminderSet = true , ReminderDateTime = Date.today().addDays(7));
                objTask.Description = 'Dear NXP Account Owner, the GSAS team is validating all Account name and address information against Dun and Bradstreet. Dun and Bradstreet is the world’s largest and most trusted commercial database. This activity will ensure that NXP has the best data available in SFDC. You have received this task because we have found a match for your account.  Please view the data in the D&B section of your Account record and select either:  "D&B Data Accepted" or "D&B Data Rejected". Selecting D&B Data Accepted will over-write your Account Name, Account Address, and other key fields. For more information, please see the PPT (Partners, please log in before clicking the link):  https://nxp.my.salesforce.com/069D00000010ze6';
                lstTasks.add(objTask);
            }
        }
    }
    
    if(lstTasks.size() > 0)
    {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.EmailHeader.triggerUserEmail = true;
        Database.insert(lstTasks, dmlOptions);
    }
   
}