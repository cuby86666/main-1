public class OutOfOfficeHelper
{ 

 public static void checkForOverlap(List<Out_Of_Office_Log__c> submittedHolidayPlans)
    {

        //get all backup people in a list
        List<String> backupPeople = new List<String>();
        Map<String,Out_Of_Office_Log__c> backupPersonToHolidayPlan = new Map<String,Out_Of_Office_Log__c>();
        
        for(Out_Of_Office_Log__c holidayPlan:submittedHolidayPlans){
            backupPeople.add(holidayPlan.Backup_Person__c);
            backupPersonToHolidayPlan.put(holidayPlan.Backup_Person__c,holidayPlan);
        }         
        //find holidays for these people and time
        if(!backupPeople.isEmpty()){
            //out of office records where the backup people are taking time off along with dates
            List<Out_Of_Office_Log__c> holidayPlansForBackupPeople =[select Person_taking_time_off__c,Backup_Person__c,Start_Date__c,End_Date__c from Out_Of_Office_Log__c where Person_taking_time_off__c in :backupPeople];             
            if(holidayPlansForBackupPeople!=null){
                //go through this list and check if start date of backup person's holiday is within the out of office record
                //where they are the backups
                
                for(Out_Of_Office_Log__c holidayForBakupPerson:holidayPlansForBackupPeople){
                    //get holidayplan where he is backup person
                    Out_Of_Office_Log__c submittedHolidayPlanForBackupPerson = backupPersonToHolidayPlan.get(holidayForBakupPerson.Person_taking_time_off__c);                          
                    //check start date of submitted holiday plan is out of range of the backup person's holiday plan
               //    if(submittedHolidayPlanForBackupPerson.Start_Date__c>=holidayForBakupPerson.Start_Date__c && submittedHolidayPlanForBackupPerson.End_Date__c <= holidayForBakupPerson.End_Date__c && submittedHolidayPlanForBackupPerson.End_Date__c<=holidayForBakupPerson.Start_Date__c){
                  //      submittedHolidayPlanForBackupPerson.addError('Backup person is going on vacation at the same time');
                        
                        if((submittedHolidayPlanForBackupPerson.Start_Date__c >= holidayForBakupPerson.Start_Date__c && submittedHolidayPlanForBackupPerson.Start_Date__c <= holidayForBakupPerson.End_Date__c) || (submittedHolidayPlanForBackupPerson.End_Date__c >= holidayForBakupPerson.Start_Date__c) && submittedHolidayPlanForBackupPerson.End_Date__c <= holidayForBakupPerson.End_Date__c){
                        submittedHolidayPlanForBackupPerson.addError('Backup person is going on vacation at the same time');
                    }
              
            }                   
        }
  }

    } 
    }