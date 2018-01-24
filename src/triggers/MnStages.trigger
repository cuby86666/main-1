trigger MnStages on MnStage__c (before insert) {
	fflib_SObjectDomain.triggerHandler(MnStages.class);    
}