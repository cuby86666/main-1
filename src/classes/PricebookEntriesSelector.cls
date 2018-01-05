public class PricebookEntriesSelector extends ApplicationSelector {
    
    public override Schema.SObjectType getSObjectType() {
		return PricebookEntry.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			PricebookEntry.Id,
			PricebookEntry.Name,
			PricebookEntry.Pricebook2Id,
			PricebookEntry.Product2Id,
			PricebookEntry.CurrencyIsoCode,
			PricebookEntry.IsActive
		};
	}
	
	public List<PricebookEntry> selectByProdSalesItemWithProduct(Set<String> prodSalesItems) {
		p('selectByProdSalesItemWithProduct');
		prodSalesItems = (prodSalesItems != null) ? prodSalesItems : new Set<String>();
		
		fflib_QueryFactory pricebookEntriesQueryFactory = newQueryFactory();
		
		new ProductsSelector().configureQueryFactoryFields(pricebookEntriesQueryFactory, PricebookEntry.Product2Id.getDescribe().getRelationshipName());
		
		String condition = 'IsActive = true AND '; 
		
		if (Test.isRunningTest()) {
			Id pricebookId = Test.getStandardPricebookId();
			condition += 'Pricebook2Id = :pricebookId AND ';			
		} else {
			condition += 'Pricebook2.IsStandard = true AND ';	
		}
		
		condition += 'Product2.Sales_Item__c in :prodSalesItems';
	
		return (List<PricebookEntry>)Database.query(pricebookEntriesQueryFactory.setCondition(condition).toSOQL());
	}
	/*
	public List<PricebookEntry> selectByProdBasicTypeOrSalesItemWithProduct(Set<String> prodBasicTypes, Set<String> prodSalesItems) {
		p('selectByProdBasicTypeOrSalesItemWithProduct');
		prodBasicTypes = (prodBasicTypes != null) ? prodBasicTypes : new Set<String>();
		prodSalesItems = (prodSalesItems != null) ? prodSalesItems : new Set<String>();
		
		fflib_QueryFactory pricebookEntriesQueryFactory = newQueryFactory();
		
		new ProductsSelector().configureQueryFactoryFields(pricebookEntriesQueryFactory, PricebookEntry.Product2Id.getDescribe().getRelationshipName());
		
		String condition = 'IsActive = true AND '; 
		
		if (Test.isRunningTest()) {
			Id pricebookId = Test.getStandardPricebookId();
			condition += 'Pricebook2Id = :pricebookId AND ';			
		} else {
			condition += 'Pricebook2.IsStandard = true AND ';	
		}
		
		condition += '(Product2.Basic_Type__c in :prodBasicTypes OR Product2.Sales_Item__c in :prodSalesItems)';
	
		return (List<PricebookEntry>)Database.query(pricebookEntriesQueryFactory.setCondition(condition).toSOQL());
	}
	*/
}