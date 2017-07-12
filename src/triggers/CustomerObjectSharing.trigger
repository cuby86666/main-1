trigger CustomerObjectSharing on Technical_Support_Team__c (after insert,after delete) 
{

   if(Trigger.isInsert)
   
   {
   
       //Initialising Job Share for Customer Share
       
       List<Customer_Project__share> JobShares = new List<Customer_Project__share>();
       
       for(Technical_Support_Team__c Tech : trigger.new)
       {
             
             //For every inserted Technical Support team record created two Share records for 2 users
             Customer_Project__share C1 = new Customer_Project__share();
             Customer_Project__share C2 = new Customer_Project__share();
             
             //Populate sharing Records with Required Details
             //Share Record with 1st User
             C1.ParentID=Tech.Customer_Project__c;
             C1.UserOrGroupId = Tech.CAS_1_Engineer__c;
             C1.AccessLevel ='Edit';
             C1.RowCause = Schema.Customer_Project__share.RowCause.Give_access_to_users_on_Child__c;
             
             
             //Share Record with 2nd user
             C2.ParentID=Tech.Customer_Project__c;
             C2.UserOrGroupId = Tech.CAS_2_Engineer__c;
             C2.AccessLevel ='Edit';
             C2.RowCause = Schema.Customer_Project__share.RowCause.Give_access_to_users_on_Child__c;
             
             if(Tech.CAS_1_Engineer__c!=null)
             {
             JobShares.add(C1);
             }
             
             if(Tech.CAS_2_Engineer__c!=null)
             {
             JObShares.add(C2);
             }
             
       
       
       
       }
       
       //Insert Share objects
       insert JobShares;
       
       
   }
   
   
   
   if(Trigger.isdelete)
   {
       
        List<Customer_Project__share> DeleteShare = new List<Customer_Project__share>();
        
        //List of parent Ids
        List<Id> Custproject = new List<Id>();
        
        //List of user1
        List<Id> User1 = new List<Id>();
        
        //List of user2
        List<Id> User2 = new List<Id>();
        
        
        for(Technical_Support_Team__c Tech : trigger.old)
        {
        
                 User1.add(Tech.CAS_1_Engineer__c);
                 User2.add(Tech.CAS_2_Engineer__c);
                 Custproject.add(Tech.Customer_Project__c);
        
        }
        
        
        DeleteShare =[Select id from Customer_Project__share where (UserOrGroupId in: User1 or UserOrGroupId in: User2) and Parentid in:Custproject and RowCause='Give_access_to_users_on_Child__c'];
        
        Delete DeleteShare;
        
   
   
   
   }







}