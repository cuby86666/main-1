public class Opportunities extends ApplicationDomain {
	
	public Opportunities(List<Opportunity> oppties) {
		super(oppties);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new Opportunities(sObjectList);
		}
	}
    
}