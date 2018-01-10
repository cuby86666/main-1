public class ApproverMatrixHelper {
	
	private static final String DIRECT_OPPTY_TYPE_MAG_APPROVER = 'MAG Approver';
	private static final String DIRECT_OPPTY_TYPE_BL_APPROVER = 'BL Approver';
	private static final String DIRECT_OPPTY_TYPE_GAM = 'GAM';
	private static final String DIRECT_OPPTY_TYPE_EVP = 'EVP';
	private static final String DIRECT_OPPTY_TYPE_SEGMENT_VP = 'Segment VP';
	private static final String DIRECT_OPPTY_TYPE_GSM_SALES_DIRECTOR = 'GSM Sales Director';
	private static final String DIRECT_OPPTY_TYPE_GSM_VP_1 = 'GSM VP 1';
	private static final String DIRECT_OPPTY_TYPE_GSM_VP_2 = 'GSM VP 2';
	// Account constants
	private static final String PARENT_ACCOUNT_STAR = 'STAR';
	private static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
	private static final String CBG_AUTOMOTIVE = 'Automotive';
	private static final String REGION_GC = 'Greater China';
	private static final String REGION_SAP = 'South Asia Pacific';
	
	private static Map<Id, Approvers_Matrix__c> directOpptyApproverMatrixes;  
	
	static{
		directOpptyApproverMatrixes = getDirectOpptyApproverMatrixes(); 
	}
	
	public static Map<Id, Approvers_Matrix__c> getDirectOpptyApproverMatrixes() {
    	if (directOpptyApproverMatrixes == null) {
    		setDirectOpptyApproverMatrixes();	
    	}
    	
    	return directOpptyApproverMatrixes;
    }
    
    private static void setDirectOpptyApproverMatrixes() {
    	directOpptyApproverMatrixes = new Map<Id, Approvers_Matrix__c>(
    		new ApproverMatrixesSelector().selectByRecordTypeId(new Set<Id>{new ApproverMatrixesSelector().getRecordTypeId(ApproverMatrixesSelector.RecordType.DIRECT_OPPTY)})
    	);
	}
    
    public static Approvers_Matrix__c getDirectOpptyGamStar() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GAM && am.Criteria_1__c == PARENT_ACCOUNT_STAR) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyGamSamsung() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GAM && am.Criteria_1__c == PARENT_ACCOUNT_SAMSUNG) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyGamGeneral(Id accountId) {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GAM && am.Account__c == accountId) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyEvpStar() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_EVP && am.Criteria_1__c == PARENT_ACCOUNT_STAR) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyEvpSamsung() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_EVP && am.Criteria_1__c == PARENT_ACCOUNT_SAMSUNG) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptySegmentVpAuto() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_SEGMENT_VP && am.Criteria_1__c == CBG_AUTOMOTIVE) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyGsmSalesDirector() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GSM_SALES_DIRECTOR) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyGsmVp1() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GSM_VP_1) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;	
    }
    
    public static Approvers_Matrix__c getDirectOpptyGsmVp2AutoGc() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GSM_VP_2 && am.Criteria_1__c == CBG_AUTOMOTIVE && am.Criteria_2__c == REGION_GC) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    } 
    
    public static Approvers_Matrix__c getDirectOpptyGsmVp2AutoSap() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GSM_VP_2 && am.Criteria_1__c == CBG_AUTOMOTIVE && am.Criteria_2__c == REGION_SAP) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    } 
    
    public static List<Approvers_Matrix__c> getDirectOpptyMagApprovers(Set<String> mags) {
    	List<Approvers_Matrix__c> result = new List<Approvers_Matrix__c>();
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_MAG_APPROVER && mags.contains(am.Criteria_1__c) && am.Criteria_2__c == null) {
    			result.add(am);
    		}
    	}	
    	
    	return result;		
    }
    
    public static List<Approvers_Matrix__c> getDirectOpptyMagApproversStar(Set<String> mags) {
    	List<Approvers_Matrix__c> result = new List<Approvers_Matrix__c>();
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_MAG_APPROVER && mags.contains(am.Criteria_1__c) && am.Criteria_2__c == PARENT_ACCOUNT_STAR) {
    			result.add(am);
    		}
    	}	
    	
    	return result;		
    }
    
    public static List<Approvers_Matrix__c> getDirectOpptyBlApprovers(Set<String> bls) {
    	List<Approvers_Matrix__c> result = new List<Approvers_Matrix__c>();
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_BL_APPROVER && bls.contains(am.Criteria_1__c) && am.Criteria_2__c == null) {
    			result.add(am);
    		}
    	}	
    	
    	return result;		
    }
    
    public static List<Approvers_Matrix__c> getDirectOpptyBlApproversStar(Set<String> bls) {
    	List<Approvers_Matrix__c> result = new List<Approvers_Matrix__c>();
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_BL_APPROVER && bls.contains(am.Criteria_1__c) && am.Criteria_2__c == PARENT_ACCOUNT_STAR) {
    			result.add(am);
    		}
    	}	
    	
    	return result;		
    }
    
}