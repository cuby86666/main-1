trigger TaskTrigger on Task (before insert, after insert, 
  							 before update, after update, 
							 before delete, after delete, after undelete) {
	TaskTrigger task = new TaskTrigger(Trigger.old, Trigger.new);
                                 
	if (Trigger.isBefore) {
    	if (Trigger.isInsert) {
      		task.updateTask();
    	} 
        
    	if (Trigger.isUpdate) {
      		task.updateTask();
    	}
    
        if (Trigger.isDelete) {}
	}

  	if (Trigger.IsAfter) {
    	if (Trigger.isInsert) {
      		task.updateCustomerProject();
    	}
        
    	if (Trigger.isUpdate) {
      		task.updateCustomerProject();
    	}
    
        if (Trigger.isDelete) {
      		task.updateCustomerProject();
    	}
        
        if (Trigger.isUndelete) {
      		task.updateCustomerProject();
    	}
	} 
}