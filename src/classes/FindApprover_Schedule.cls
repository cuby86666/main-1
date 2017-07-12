/*************************************************************************** 
Created By: Scarlett Kang
Created Date: Feb 10 2015
Description: Find approver for system adim
***************************************************************************/

global with sharing class FindApprover_Schedule implements Schedulable{
   public void execute(SchedulableContext sc) {
      Database.executeBatch(new FindApprover(), 200);
   }
}