/**
 * Applicaiton specific Domain base class. Customize fflib_SObjectDomain and add common behaviour.
 **/
public abstract class ApplicationDomain extends fflib_SObjectDomain {
    
    /**
     * Constructor required for Test.createStub
     **/
    public ApplicationDomain() {
        super();
    }
    
    public ApplicationDomain(List<SObject> records) {
        super(records);
        // Disable the base class CRUD checking in preference to explicit checking elsewhere
        Configuration.disableTriggerCRUDSecurity();
    }
    
    public String getSObjectName() {
    	return getSObjectType().getDescribe().getName();
    }
    
    protected void p(String msg) {
    	CommonUtils.p(this, '//-d', msg);
    }
        
}