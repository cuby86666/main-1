public class Application {
	
	// Configure and create the UnitOfWorkFactory for this Application
	public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
		new fflib_Application.UnitOfWorkFactory(
			new List<SObjectType> { 
				Product2.SObjectType, 
				PricebookEntry.SObjectType,
				Opportunity.SObjectType, 
				OpportunityShare.SObjectType,
				OpportunitySchedule__c.SObjectType,
				OpportunityLineItem.SObjectType,
				OpportunityProductSchedule__c.SObjectType
			}
		);

	// Configure and create the DomainFactory for this Application
	public static final fflib_Application.DomainFactory Domain = 
		new fflib_Application.DomainFactory(
			Application.Selector,
			// Map SObjectType to Domain Class Constructors 
			new Map<SObjectType, Type> {
				Opportunity.SObjectType => Opportunities.Constructor.class,
				OpportunityLineItem.SObjectType => OpportunityLineItems.Constructor.class
			}
		);

	// Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(
            // Map SObjectType to Selector Class
            new Map<SObjectType, Type> {
            	Opportunity.SObjectType => OpportunitiesSelector.class,
            	OpportunityLineItem.SObjectType => OpportunityLineItemsSelector.class
            }
        ); 
                    
}