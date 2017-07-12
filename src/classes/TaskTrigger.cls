/**
 * Fields updated:
 *   Task
 *     ActivityDate
 *     Status
 *     Completed_Date__c  
 * 
 *   Customer_Project__c
 *     Total_Actions__c
 *     Actions_Closed__c
 *     Activity__c
 */

public class TaskTrigger {
	private List<Task> oldTasks;
    private List<Task> newTasks;
  
    public TaskTrigger(List<Task> oldTasks, List<Task> newTasks) {
        this.oldTasks = oldTasks;
        this.newTasks = newTasks;
    }
    
    public void updateTask() {
    	for (Task tNew : this.newTasks) {
            setDueDateAsToday(tNew);
            
            if (Trigger.isInsert) {
        		syncStatusAndCompletedDate(tNew);
            }
            
            if (Trigger.isUpdate) {
            	for (Task tOld : this.oldTasks) {
                	if (tNew.Id == tOld.Id) {
                		syncStatusAndCompletedDate(tOld, tNew);    
                	}
            	}
            }
        }    
    }
    
    private void setDueDateAsToday(Task task) {
        if (!task.IsRecurrence && task.ActivityDate == null) {
        	task.ActivityDate = Date.today();
        }        
    }
    
    private void syncStatusAndCompletedDate(Task task) {
    	if (task.Status == 'Completed' && task.Completed_Date__c == null) {
            task.Completed_Date__c = Date.today();
        }
        
        if (task.Status != 'Completed' && task.Completed_Date__c != null) {
        	task.Status = 'Completed';     
        }    
    }
    
    private void syncStatusAndCompletedDate(Task taskOld, Task taskNew) {
        if (taskOld.Status == 'Completed' && taskNew.Status != 'Completed') {
            taskNew.Completed_Date__c = null;     
        } else {
            syncStatusAndCompletedDate(taskNew);
        }
    }
    
    public void updateCustomerProject() {
        Set<Id> custProjIDs = new Set<Id>();
        
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            for (Task t : this.newTasks) {
                addIfCustProjID(custProjIDs, t);           
            }
        } else if (Trigger.isDelete) {
            for (Task t : this.oldTasks) {
                addIfCustProjID(custProjIDs, t);               
            }
        }
        
        if (custProjIDs.size() == 0) return;
        
        Map<ID, Customer_Project__c> custProjs = new Map<ID, Customer_Project__c>(
            [select Total_Actions__c, Actions_Closed__c, Activity__c 
               from Customer_Project__c
              where Id in :custProjIDs]
        );
        
        if (custProjs.size() == 0) return; // A safety net check. If custProjs.size() equals 0, custProjIDs.size() should be 0, too. It should return before querying Customer_Project__c.
        
        for (Customer_Project__c cp : custProjs.values()) {
            cp.Total_Actions__c = 0;
            cp.Actions_Closed__c = 0;
            cp.Activity__c = false;
        }
          
        List<Task> custProjTasks = [select WhatId, ActivityDate, Completed_Date__c 
                                      from Task
                                     where WhatId in: custProjIDs
                                       and ActivityDate != null]; // If IsRecurrence is true, there will one record created for the task without ActivityDate set. 
        
        for (Task t : custProjTasks) {
            Customer_Project__c custProj = custProjs.get(t.WhatId);
        	Date dueDate = t.ActivityDate;
            Date completedDate = t.Completed_Date__c;
            
            custProj.Total_Actions__c++;
            
            if (completedDate <= dueDate) {
            	custProj.Actions_Closed__c++;    
            }
            
            if (completedDate == null) {
            	custProj.Activity__c = true;
            }
        } 
        
        update new List<Customer_Project__c>(custProjs.values());
    }
    
    private void addIfCustProjID(Set<Id> custProjIDs, Task task) {
        String whatID = task.WhatId;
        
        if (String.isNotBlank(whatID) && whatID.startsWith('a24')) { // 'a24' is the prefix of Customer Project object.
        	custProjIDs.add(task.WhatId);    
        }
    }
}