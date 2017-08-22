public with sharing class OpportunityService {
	
	public static Map<Id, List<DesignWinApprover>> getDesignWinApprovers(Set<Id> opptyIds) {
		p('getDesignWinApprovers');
		Map<Id, List<DesignWinApprover>> result = new Map<Id, List<DesignWinApprover>>();
		
		Map<Id, Map<String, String>> approversByOpptyId = OpportunityApproval.getAllApprovers(new OpportunitiesSelector().selectByIdWithAccountAndOwner(opptyIds));
		
		for (Id opptyId : approversByOpptyId.keySet()) {
			List<DesignWinApprover> approvers = new List<DesignWinApprover>();
			
			for (String label : approversByOpptyId.get(opptyId).keySet()) {
				DesignWinApprover approver = new DesignWinApprover();
				approver.label = label;
				approver.name = approversByOpptyId.get(opptyId).get(label);
				approvers.add(approver); 	
			}		
			
			result.put(opptyId, approvers);
		}
		
		return result;
	}
	
	public static void updateDesignWinApprovers(Set<Id> opptyIds) {
		p('updateDesignWinApprovers');
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		Opportunities oppties = new Opportunities(new OpportunitiesSelector().selectByIdWithAccountAndOwner(opptyIds));
		oppties.updateDesignWinApprovers(uow);	
		
		uow.commitWork();	
	}
	
	public class DesignWinApprover {
		public String label;
		public String name;
	}
	
	public static void updateModelNExpiredOpportunities(List<Opportunity> oppties) {
		p('updateModelNExpiredOpportunities');
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
        List<Opportunity> opptiesUpdated = new Opportunities(oppties).updateModelNExpiredOpportunities(uow);
        
        new OpportunityLineItems(new OpportunityLineItemsSelector().selectByOpptyIdWithOpportunity(new Map<Id, Opportunity>(opptiesUpdated).keySet())).updateModelNExpiredOpportunityProducts(uow);
        
        uow.commitWork();
	}
	
	private static void p(String msg) {
		CommonUtils.p(OpportunityService.class, '//-v', msg);
	}
    
}