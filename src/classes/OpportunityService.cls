public with sharing class OpportunityService {
	
	public static Map<String, String> getDesignWinApprovers(Id opptyId) {
		p('getDesignWinApprovers');
		//J return OpportunityApproval.getAllApprovers(opptyId);
		return OpportunityApproval.getAllApprovers(new OpportunitiesSelector().selectByIdWithAccountAndOwner(new Set<Id>{opptyId}).get(0));	
	}
	
	public static void updateDesignWinApprovers(Set<Id> opptyIds) {
		p('updateDesignWinApprovers');
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		//J Opportunities oppties = new Opportunities(new OpportunitiesSelector().selectById(opptyIds));
		Opportunities oppties = new Opportunities(new OpportunitiesSelector().selectByIdWithAccountAndOwner(opptyIds));
		oppties.updateDesignWinApprovers(uow);	
		
		uow.commitWork();	
	}
	
	private static void p(String msg) {
		System.debug('//-v OpportunityService - ' + msg);
	}
    
}