@isTest
private class Test_CaseRoutingMappingHandler {
    
    static List<Case_Routing_Mapping__c> lstCaseRouteMapping = new List<Case_Routing_Mapping__c>();
    static List<User> lstUser;
    static List<Group> lstGroup;
    
    private static void createData(){
        
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id;
        
        lstUser = new List<User>{new User(alias = 'UTest', email='unit.test@test.com', emailencodingkey='UTF-8', lastname='TestUser', languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = ProfileId, timezonesidkey='America/Los_Angeles', username= 'unit.test@test123.com'),
                                 new User(alias = 'TestUser', email='testuser.test@test.com', emailencodingkey='UTF-8', lastname='TestCaseUser', languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = ProfileId, timezonesidkey='America/Los_Angeles', username= 'testuser@test56.com')
                                };
        
        insert lstUser;
        
        lstGroup = new List<Group>{new Group(Name='TestGroup-01', Type='Queue'),
                                   new Group(Name='TestGroup-02', Type='Queue')
                                  };
                                  
        insert lstGroup;
        
        lstCaseRouteMapping = new List<Case_Routing_Mapping__c>{new Case_Routing_Mapping__c(Name = 'TestCaseRouteMapping-01', CaseOwner__c = lstUser[0].Id),
                                                                new Case_Routing_Mapping__c(Name = 'TestCaseRouteMapping-02', CaseOwner__c = lstUser[1].Id),
                                                                new Case_Routing_Mapping__c(Name = 'TestCaseRouteMapping-03', CaseOwner__c = lstGroup[0].Id)
                                                                };
        insert lstCaseRouteMapping;
        
    }
	private static testMethod void testInsertCase() {
	    
	    createData();
	    
	    //checking if Owner_Name__c is updated or not related to inserted CaseOwner__c
	    system.assertEquals('TestUser', [Select Id,Owner_Name__c FROM Case_Routing_Mapping__c WHERE Id=:lstCaseRouteMapping[0].Id].Owner_Name__c);
	    //checking if Owner_Name__c is updated or not related to inserted CaseOwner__c
	    system.assertEquals('TestCaseUser', [Select Id,Owner_Name__c FROM Case_Routing_Mapping__c WHERE Id=:lstCaseRouteMapping[1].Id].Owner_Name__c);
	    //checking if Owner_Name__c is updated or not with group related to inserted CaseOwner__c
	    system.assertEquals('TestGroup-01', [Select Id,Owner_Name__c FROM Case_Routing_Mapping__c WHERE Id=:lstCaseRouteMapping[2].Id].Owner_Name__c);
	    
	}
	
	private static testMethod void testUpdateCase() {
	    
	    createData();
	    
	    lstCaseRouteMapping[0].CaseOwner__c = lstUser[1].Id;
	    update lstCaseRouteMapping;
	    
	    lstCaseRouteMapping[1].CaseOwner__c = lstGroup[1].Id;
	    update lstCaseRouteMapping;
	    
	    //checking if Owner_Name__c is updated with user or not related to inserted CaseOwner__c
	    system.assertEquals(lstCaseRouteMapping[0].CaseOwner__c,  lstUser[1].Id);
	    //checking if Owner_Name__c is updated with group or not related to inserted CaseOwner__c
	    system.assertEquals(lstCaseRouteMapping[1].CaseOwner__c,  lstGroup[1].Id);
	    
	}

}