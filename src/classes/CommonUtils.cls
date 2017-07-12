public class CommonUtils {
	private static final String INTEGRATION_USER_PROFILE = 'TS Standard User - API Enabled';
	private static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
	private static final String DATA_ADMIN_USER = 'Data Admin';
	
	private static ID integrationUserProfileID;
	private static ID systemAdminProfileID;
	private static ID dataAdminUserID;
	
	public static String getSObjectTypeName(SObject so) {
		return so.getSObjectType().getDescribe().getName();
	}
	
	public static Double roundDouble(Double value, Integer scaleFactor) {
    	return Decimal.valueOf(value).setScale(scaleFactor).doubleValue();	
    }
    
    public static Boolean isIntegrationUser() {
    	return UserInfo.getProfileId() == getIntegrationUserProfileID();
    }
    
    public static ID getIntegrationUserProfileID() {
    	if (integrationUserProfileID == null) {
    		setProfileIDs();	
    	}
    	
    	return integrationUserProfileID;
    }
    
    public static ID getSystemAdminProfileID() {
    	if (systemAdminProfileID == null) {
    		setProfileIDs();	
    	}
    	
    	return systemAdminProfileID;
    }
    
    private static void setProfileIDs(){
		List<Profile> profiles = [
			select 	Id, Name 
			  from 	Profile 
			 where 	Name in (:INTEGRATION_USER_PROFILE, :SYSTEM_ADMIN_PROFILE)
		];
		
		for (Profile p : profiles) {
			if (p.Name == INTEGRATION_USER_PROFILE) {
				integrationUserProfileID = p.Id;
			}
			
			if (p.Name == SYSTEM_ADMIN_PROFILE) {
				systemAdminProfileID = p.Id;
			}
		}
    }
    
    public static ID getDataAdminUserID() {
    	if (dataAdminUserID == null) {
    		User u = [select Id, Name from User where Name = :DATA_ADMIN_USER];
		
			dataAdminUserID = u.Id;	
    	}
    	
    	return dataAdminUserID;
    } 
    
    public static String generateGUID() {
    	Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		
		return guid; 
    }   
}