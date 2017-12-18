public class CommonUtils {
	private static final String INTEGRATION_USER_PROFILE = 'TS Standard User - API Enabled';
	private static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
	private static final String DATA_ADMIN_USER = 'Data Admin';
	
	private static Id integrationUserProfileId;
	private static Id systemAdminProfileId;
	private static Id dataAdminUserId;
	private static Map<String, FX_Rates__c> fxRatesByCurIsoCode;
	@TestVisible
	private static Boolean isLoggingActive = null;
	
	static {
		if (isLoggingActive == null) {
			isLoggingActive = ((List<Logging_Setting__mdt>)new LoggingSettingsSelector().selectWhere('MasterLabel = \'System Debug\'')).get(0).IsActive__c;
		}
		System.debug('//-c isLoggingActive: ' + isLoggingActive);		
	}
	
	public static String getSObjectTypeName(SObject so) {
		return so.getSObjectType().getDescribe().getName();
	}
	
	public static String getChildRelationshipName(Schema.SObjectType parent, Schema.SObjectType child) {
		String result = null;
		
		for (Schema.ChildRelationship cr : parent.getDescribe().getChildRelationships()) {
			if (cr.getChildSObject() == child) {
				result = cr.getRelationshipName();
				break;
			}	
		}
		
		return result;	
	}
	
	public static Double roundDouble(Double value, Integer scaleFactor) {
    	return Decimal.valueOf(value).setScale(scaleFactor).doubleValue();	
    }
    
    public static Boolean isAdminOrIntegrationUser() {
		return (isAdmin() || isIntegrationUser());
	}
    
    public static Boolean isIntegrationUser() {
    	return UserInfo.getProfileId() == getIntegrationUserProfileId();
    }
    
    public static Boolean isDataAdminUser() {
    	return UserInfo.getUserId() == getDataAdminUserId();
    }
    
    public static Boolean isAdmin() {
    	return UserInfo.getProfileId() == getSystemAdminProfileId();	
    }
    
    public static Id getIntegrationUserProfileId() {
    	if (integrationUserProfileId == null) {
    		setProfileIds();	
    	}
    	
    	return integrationUserProfileId;
    }
    
    public static Id getSystemAdminProfileId() {
    	if (systemAdminProfileId == null) {
    		setProfileIds();	
    	}
    	
    	return systemAdminProfileId;
    }
    
    public static Id getDataAdminUserId() {
    	if (dataAdminUserId == null) {
    		User u = new UsersSelector().selectByName(new Set<String>{DATA_ADMIN_USER}).get(0);
		
			dataAdminUserId = u.Id;	
    	}
    	
    	return dataAdminUserId;
    } 
    
    private static void setProfileIds() {
		List<Profile> profiles = new ProfilesSelector().selectByName(new Set<String>{INTEGRATION_USER_PROFILE, SYSTEM_ADMIN_PROFILE});
		
		for (Profile p : profiles) {
			if (p.Name == INTEGRATION_USER_PROFILE) {
				integrationUserProfileId = p.Id;
			}
			
			if (p.Name == SYSTEM_ADMIN_PROFILE) {
				systemAdminProfileId = p.Id;
			}
		}
    }
    
    public static Map<String, FX_Rates__c> getFxRatesByCurIsoCode() {
    	if (fxRatesByCurIsoCode == null) {
    		setFxRatesByCurIsoCode();	
    	}
    	
        return fxRatesByCurIsoCode;
    }
    
    private static void setFxRatesByCurIsoCode() {
    	fxRatesByCurIsoCode = new Map<String, FX_Rates__c>();  
        
        for (FX_Rates__c fr : (List<FX_Rates__c>)new FxRatesSelector().selectAll()) {
            fxRatesByCurIsoCode.put(fr.Currency_Code__c, fr);
        }
    }
        
    public static String generateGuid() {
    	Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		
		return guid; 
    }
    
    public static void p(Object obj, String prefix, String msg) {
    	if (isLoggingActive != null ? isLoggingActive : false) {
    		System.debug(prefix + ' ' + String.valueOf(obj).substring(0, String.valueOf(obj).indexOf(':')) + ' - ' + msg);
    	}
    } 
    
    public static void p(Type klass, String prefix, String msg) {
    	if (isLoggingActive != null ? isLoggingActive : false) {
    		System.debug(prefix + ' ' + klass.getName() + ' - ' + msg);
    	}
    }  
}