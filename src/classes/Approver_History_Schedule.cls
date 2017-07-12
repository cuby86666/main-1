/********************************************************************************************************
@Last Modified:  Scarlett Kang
@Last Modified:  Jan 15, 2016
@Description:  SIR 665 Approver History Schedule Job is failed caused by Large SOQL Queries
----------------------------------------------------------------------------------------------------------
@Last Modified:  Scarlett Kang
@Last Modified Date: Feb 22, 2016
@Description:  SIR 665 Approver History Schedule Job is failed caused by Large SOQL Queries, change batch size
----------------------------------------------------------------------------------------------------------
@Last Modified:  Scarlett Kang
@Last Modified Date: Mar 03, 2016
@Description:  SIR 665 Approver History Schedule Job is failed caused by Large SOQL Queries, change batch size
********************************************************************************************************/
global with sharing class Approver_History_Schedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      RemoveExistingApproverHistory removeAH = new RemoveExistingApproverHistory(); 
      //database.executebatch(removeAH, 500);
      database.executebatch(removeAH, 150);
   }
}