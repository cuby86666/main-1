global with sharing class Approval_History_Schedule implements System.Schedulable {
	global void execute(SchedulableContext sc) {
		PendingApprovalsSearch cls = new PendingApprovalsSearch();
	}
}