// 2015-09-07 by Rex: First version
// 
public class NewUserRegistrationV2Controller {

    //Group settings class
    public class GroupSettings {
        public String RegionName { get; set; }
        public String RegionCode { get; set; }
        public String BUName { get; set;}
        public String BUCode { get; set; }
        public boolean IsSelected { get; set; }
        public String myIdKey { get; set; }
        //myIdKey getter
        public String getIdKey() {
            return myIdKey;
        }
        
    }
    
    //BU settings class
    public class BUSettings implements Comparable {
        public List<GroupSettings> lstGroups { get; set; }
        public String BUName { get; set;}
        public String BUCode { get; set; }
        public boolean IsSelected { get; set; }
        //BUCode getter
        public String getKey() {
            return BUCode.replaceAll(' ','');
        }
        
        public Integer compareTo(Object compareTo) {
			return BUCode.compareTo(((BUSettings)compareTo).BUCode);
		}
    }
    
    //Region settings class
    public class RegionSettings {
        public List<GroupSettings> lstGroups { get; set; }
        public String RegionName { get; set; }
        public String RegionCode { get; set; }
        public Boolean IsSelected { get; set; }
        //RegionCode getter
        public String getKey() {
            return RegionCode.replaceAll(' ','');
        }
    }
    
    public List<RegionSettings> lstRegionSettings { get; set; }
    public List<BUSettings> lstBUSettings { get; set; }
    public New_User_Registration__c user { get;set; }
    New_User_Registration__c current; 
    public boolean newUserMode { get; set; }
    public boolean checkBoxDisabled { get; set; }
    public boolean success { get; set; }
    
    List<GroupSettings> lstAllGroupSettings;

    //Standard page layout constructor
    public NewUserRegistrationV2Controller(ApexPages.StandardController controller) {
       
        New_User_Registration__c current = (New_User_Registration__c)controller.getRecord();
        if (current.Id == null) {//newuser site
            newUserMode = true;
            success = false;
            user = new New_User_Registration__c();
        } else {
            newUserMode = false;
            success = false; 
            /*
            if (UserInfo.getProfileId().equals('00e20000001Nc7gAAC')) 
                checkBoxDisabled = false;
            else*/
            
            checkBoxDisabled = true; //disable checkbox matrix
            user = [Select Id, User_Groups__c from New_User_Registration__c where Id =: current.Id];
        }
        system.debug('##### current=' + current + ', mode=' + newUserMode);
        
     
    }
    
    //initialization
    
    
    public void init() {
        List<New_User_Reg_Settings__c> lstUserRegSettings = 
            New_User_Reg_Settings__c.getAll().values();
        
        List<New_User_Reg_Settings__c> lstRegions = new List<New_User_Reg_Settings__c>();
        List<New_User_Reg_Settings__c> lstBUs = new List<New_User_Reg_Settings__c>();
        
        //create region & bu list
        for(New_User_Reg_Settings__c obj : lstUserRegSettings) {
            if (obj.Type__c == 'Reg') //region
                lstRegions.add(obj);
            else if (obj.Type__c == 'BU') //BU
                lstBUs.add(obj);
        }
        
        lstBUs.sort();
        
        lstAllGroupSettings = new List<GroupSettings>();
        lstRegionSettings = new List<RegionSettings>();
        
        //create region group settings
        for(New_User_Reg_Settings__c obj1 : lstRegions) {
            //create region settings
            RegionSettings tmpReg = new RegionSettings();
            tmpReg.RegionName = obj1.Name;
            tmpReg.RegionCode = obj1.Code__c;
            tmpReg.IsSelected = false;
            tmpReg.lstGroups = new List<GroupSettings>();
            for(New_User_Reg_Settings__c obj2 : lstBUs) {
                GroupSettings tmpGroup = new GroupSettings();
                tmpGroup.RegionName = obj1.Name;
                tmpGroup.RegionCode = obj1.Code__c;
                tmpGroup.BUName = obj2.Name;
                tmpGroup.BUCode = obj2.Code__c;
                tmpGroup.myIdKey = tmpGroup.RegionCode.replaceAll(' ','') + tmpGroup.BUCode.replaceAll(' ','');
                tmpGroup.IsSelected = false;
                lstAllGroupSettings.add(tmpGroup);
                tmpReg.lstGroups.add(tmpGroup);
            }
            
            System.debug('////// Group::'+ lstAllGroupSettings);
            
            lstRegionSettings.add(tmpReg);
        }
        
        lstBUSettings = new List<BUSettings>();
        for(New_User_Reg_Settings__c obj : lstBUs) {
            BUSettings tmpBU = new BUSettings();
            tmpBU.BUName = obj.Name;
            tmpBU.BUCode = obj.Code__c;
            tmpBU.IsSelected = false;
            tmpBU.lstGroups = new List<GroupSettings>();
            for(GroupSettings grp : lstAllGroupSettings) {
                if (grp.BUCode == obj.Code__c) {
                    tmpBU.lstGroups.add(grp);
                }
            }
            lstBUSettings.add(tmpBU);
        }
        
        lstBUSettings.sort();
   
        if (!newUserMode) LoadUserGroup(user.User_Groups__c); 
    }
    
    //convert group settings to string
    public String SaveUserGroup() {
        //lstRegionSettings, lstBUSettings
        String tmpUserGroup = '';
        //collect region info
        system.debug('##### region settings=' + lstRegionSettings.size());
        Integer regCount = 0;
        for(RegionSettings reg : lstRegionSettings) {
            if (reg != null && reg.IsSelected) {
                tmpUserGroup += reg.RegionCode;
                tmpUserGroup += ';';
                regCount++;
            }
        }
        Integer BUCount = 0;
        for(BUSettings bu : lstBUSettings) {
            if (bu != null && bu.IsSelected) {
                tmpUserGroup += bu.BUCode;
                tmpUserGroup += ';';
                BUCount++;
            }
        }   
        /*if(lstRegionSettings.size() !=0 || lstBUSettings.size() !=0)        
        {
            return tmpUserGroup;
        } */
        
        //collect bu - region info
        
        String tmpSingleGroup = '';
        String tmpBuGroup = '';
        for(GroupSettings grp : lstAllGroupSettings) {
            system.debug('##### grp=' + grp + ', tmpUserGroup=' + tmpUserGroup + ', tmpSingleGroup=' + tmpSingleGroup);
            if (grp != null && grp.IsSelected && tmpUserGroup.indexOf(grp.RegionCode) == -1 && 
                tmpUserGroup.indexOf(grp.BUCode) == -1) 
            
             {
                tmpSingleGroup += (grp.BUCode + ' - ' + grp.RegionCode);
                tmpSingleGroup += ';';
            }            
              
        }
        //check Global user: if all regions or all BUs are selected, assign Global to user group.
            
        
        
        if (regCount == lstRegionSettings.size() || BUCount == lstBUSettings.size())
            return 'Global;';
       
      else  
       return tmpUserGroup+tmpSingleGroup ;
                                                        
    }
    
   /* String test1 = 'EU;JP;';
    String test2 = '525 AUT;510 SnC;';
    String test3 = 'EU;JP;525 AUT - KR;510 SnC - KR;525 AUT - GC;';
    String test4 = '525 AUT;510 SnC;511 SP - EU;513 LOG - EU;';
    */
    
    
    //parse string to group settings
    
   
    
    public void LoadUserGroup(String strUserGroup) {
        if (strUserGroup == null || strUserGroup.length() == 0) return;
        List<String> lstUserGroup = strUserGroup.split(';');
        //region
        for(String str : lstUserGroup) {
            for(RegionSettings reg : lstRegionSettings) {
                if (reg.RegionCode == str || strUserGroup == 'Global;') {
                    reg.IsSelected = true;
                    for(GroupSettings grp : reg.lstGroups) {
                        grp.IsSelected = true;
                    }
                }
            }
            for(BUSettings bu : lstBUSettings) {
                if (bu.BUCode == str) {
                    bu.IsSelected = true;
                    for(GroupSettings grp : bu.lstGroups) {
                        grp.IsSelected = true;
                    }

                }
            }
            for(GroupSettings grp : lstAllGroupSettings) {
                if (str.indexOf(grp.BUCode) > -1 && str.indexOf(grp.RegionCode) > -1) grp.IsSelected = true;
            }
        }
    }
    /*
    //update user group settings
    public void updateUserGroup() {
        if (UserInfo.getProfileId().equals('00e20000001Nc7gAAC')) {
            String tmpUserGroup = SaveUserGroup();
            user.User_Groups__c = tmpUserGroup;
            update user;            
        }
    }*/
    
    //save record
    
    public void Save() {
        String tmpUserGroup = SaveUserGroup();
        List<RecordType> lstRecTypeId = [Select Id from RecordType Where Name = 'New User Registration'];
        /* check group settings
        if (tmpUserGroup == null || tmpUserGroup.length() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select Data Accessibility Session. It is Required !!'));
            return;
        }*/
      
        user.User_Groups__c = tmpUserGroup;
        user.RequestforAccountin__c = 'Salesforce';
        User.Role__c = 'User';
        user.Status__c= 'Submitted';
        if (lstRecTypeId.size() > 0) user.RecordTypeId = lstRecTypeId.get(0).Id;
        upsert user;
        
       
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your application has been successfully submitted and a response to your request will arrive shortly. You will not be able to logon to the system until the registration has been approved. If you do not receive a response, Pls raise the issue via  Case tool http://nxpsemiconductors.force.com/welcome -> HELP give info. required and submit'));
        success = true;
    }  
}