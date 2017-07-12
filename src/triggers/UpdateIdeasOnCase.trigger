trigger UpdateIdeasOnCase on Case (after update) {
	Map<Id, Case> cases = new Map<Id, Case>();
	Map<Id, RecordType> recordTypes = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE isactive =true and Name = 'Sales CRM' limit 1]);
	
	for(Case cas : trigger.new){
		if(recordTypes.get(cas.RecordTypeId) != null && cas.Type != null && cas.Type.equalsIgnoreCase('Ideas')){
			cases.put(cas.Id, cas);
		}
	}
	
	System.debug('## Trigger Key Set = ' + trigger.newMap.keySet());
    List<CaseSolution> caseSolutions = [SELECT Id, CaseId, SolutionId FROM CaseSolution WHERE CaseId in: trigger.newMap.keySet() ORDER BY CaseId, CreatedDate];
    
    Map<Id, Solution> caseSolutionMap = new Map<Id, Solution>();
    
    Map<Id, Id> solutionIds = new Map<Id, Id>();
   
    for(CaseSolution caseSolution : caseSolutions){
    	solutionIds.put(caseSolution.CaseId, caseSolution.SolutionId);
    }
    
    Map<Id, Solution> solutionMap = new Map<Id, Solution>([select id, SolutionNote from Solution where id in: solutionIds.values()]);
    
    for(Id caseId : solutionIds.keySet()){
    	caseSolutionMap.put(caseId, solutionMap.get(solutionIds.get(caseId)));
    }
    System.debug('## CS MAP = ' + caseSolutionMap);
    
    Map<Id, Id> ideaCaseMap = new Map<Id, Id>();
    Set<Id> ideaids = new Set<Id>();
    for(Case cs : cases.values()){
    	System.debug('## Related Idea Id = ' + cs.Related_Idea__c);
    	ideaids.add(cs.Related_Idea__c);
        ideaCaseMap.put(cs.Id, cs.Related_Idea__c);
    }
    
    Map<Id, Idea> ideaMap = new Map<Id, Idea>([SELECT Id, Feedback_from_Support__c FROM Idea WHERE id in: ideaids]);
    
    List<Idea> ideas = new List<Idea>();
    for(Id caseId : caseSolutionMap.keySet()){
        String solutionNote = caseSolutionMap.get(caseId).SolutionNote;
        if(solutionNote != null && solutionNote.trim().length() > 0){
        	System.debug('## Solution Note = ' + solutionNote);
            Id ideaId = ideaCaseMap.get(caseId);
            System.debug('## Idea ID = ' + ideaId);
            if(IdeaId !=  null){
            	
                Idea ida = ideaMap.get(IdeaId);
                System.debug('## Idea  = ' + ida);
                If(ida != null){
                	
                    ida.Feedback_from_Support__c = solutionNote;
                    ideas.add(ida);
                }
            }
        }
    }
    
    if(ideas.size() > 0)
        update ideas;
}