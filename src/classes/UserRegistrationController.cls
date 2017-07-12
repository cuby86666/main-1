/*******************************************************************************************************
Name        :     UserRegistrationController
page        :     UserRegistration
Author      :     
Date        :        17 May,2011
Description :     class for page UserRegistration, to provide the user registartion functionality
*******************************************************************************************************/

public class UserRegistrationController{//
    public Boolean changeAcc{get;set;}
    public Boolean Flag{get;set;}
    public Boolean First{get;set;}
    public String accesstype{get;set;}
    public Boolean nxp{get;set;}
    public Boolean disti{get;set;}
    public Boolean sales {get;set;}
    public Boolean var{get;set;}
    public Model_N__c modelN{get;set;}
    public String usertype{get;set;}
    public boolean success{get;set;}
    public boolean nextnxp{get;set;}
    public boolean nextdisti{get;set;}
    public boolean nextSales{get;set;}
    public boolean nextvar{get;set;}
    private String errorMessage='';
    private boolean isValid=true;
    public void init(){
        First = true;
        Flag = false;
        nxp = false;
        disti = false;
        sales = false;
        var = false;
        success = false;
        nextnxp = false;
        nextdisti = false;
        nextSales = false;
        nextvar = false;
        modelN = new Model_N__c();
    }
    public UserRegistrationController(){
        Flag = false;
        First = true;
        nxp = false;
        disti = false;
        sales = false;
        var = false;
        changeAcc = false;
        success = false;
        nextnxp = false;
        nextdisti = false;
        nextSales = false;
        nextvar = false;
        modelN = new Model_N__c();
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('NXP User','NXP User'));
        options.add(new SelectOption('Disti User','Disti User'));
        options.add(new SelectOption('Sales Rep','Sales Rep'));
        options.add(new SelectOption('VAR','VAR'));
        return options;
    }
    public void nextAType(){
        System.debug('### USer Type : '+usertype);
        if(accesstype.trim().length() > 0){
            if(accesstype == 'New User'){
                First = false;
                Flag = true;
            }else{
                First = false;
                Flag = true;
                changeAcc = true;
            }
            modelN.Access_Type__c = accesstype;
            modelN.User_Type__c = usertype;
            modelN.CurrencyIsoCode = 'EUR';
        }
    }
    public void Registration(){
       
        if(Flag == true && usertype != null){    
            if(usertype.trim().length() > 0){
                if(usertype == 'NXP User'){
                    Flag = false;
                    nxp = true;
                    disti = false;
                    sales = false;
                    var = false;
                }else if(usertype == 'Disti User'){
                    Flag = false;
                    nxp = false;
                    sales = false;
                    var = false;
                    disti = true;
                }else if(usertype == 'Sales Rep'){
                    Flag = false;
                    nxp = false;
                    sales = True;
                    var = false;
                    disti = false;
                }else{
                    Flag = false;
                    nxp = false;
                    sales = false;
                    var = true;
                    disti = false;
                }
                modelN.User_Type__c = usertype;
                modelN.CurrencyIsoCode = 'EUR';
            }else{
                Flag = true;
                nxp = false;
                disti = false;
                sales = false;
                var = false;
                First = false;
            }
        }
        System.Debug('@@@@Access Type is '+modelN.Access_Type__c);
    }
    
    public void save(){
        system.debug('### : USerType '+modelN.User_Type__c);
        if(modelN.User_Type__c.trim().length() > 0 && modelN.User_Type__c == 'NXP User' ){
          system.debug('### : USerType '+modelN);
          if(modelN.Region__c != null && modelN.Manager_Name__c != null && modelN.Manager_email_address__c != null && modelN.Tel_Mobile__c != null && modelN.Roles_Category__c != null /*&& modelN.Read_Org__c != null && modelN.Edit_Org__c != null*/){
            //modelN.name = modelN.Last_Name__c+' '+modelN.First_Name__c;
            modelN.Status__c= 'Submitted';
            modelN.Assigned_Org_VAR__c='';
            modelN.Role_Hierarchy_Country_Region__c='';
            modelN.Role_Hierarchy_Country_Sub_Region__c='';
            modelN.Role_Hierarchy_Region__c='';
            modelN.Role_Hierarchy_Sub_Region__c='';
            upsert modelN;
            flag=false;
            nxp=false;
            disti = false;
            sales = false;
            var = false;
            success = true;
            nextnxp = false;
            nextdisti = false;
            nextSales= false;
            nextvar = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your application has been successfully submitted and a response to your request will arrive shortly. The user will not be able to logon to the system until the registration has been approved. If you do not receive a response, Please contact Global Sales Application support at globalsales.appsupport@nxp.com for any assistance.'));
          } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record Not Saved !!'));
          }
        }else if(modelN.User_Type__c.trim().length() > 0 && modelN.User_Type__c == 'Disti User' ){
            if(modelN.First_Name__c != null && modelN.Last_Name__c != null && modelN.Company_Name__c != null && modelN.Company_Address__c != null && modelN.Job_Title__c != null){
            //modelN.name = modelN.Last_Name__c+' '+modelN.First_Name__c;
            modelN.Status__c= 'Submitted';
            modelN.Edit_Org__c ='';
            modelN.Read_Org__c ='';
            modelN.Edit_Org_Sub_Category__c ='';
            modelN.Read_Org_Sub_Category__c ='';
            modelN.Assigned_Org_VAR__c='';
            upsert modelN;
            flag=false;
            nxp=false;
            disti = false;
            sales = false;
            var = false;
            success = true;
            nextnxp = false;
            nextdisti = false;
            nextsales = false;
            nextvar = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your application has been successfully submitted and a response to your request will arrive shortly. The user will not be able to logon to the system until the registration has been approved. If you do not receive a response, Please contact Global Sales Application support at globalsales.appsupport@nxp.com for any assistance.'));
          } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record Not Saved !!'));
          }
        }else if(modelN.User_Type__c.trim().length() > 0 && modelN.User_Type__c == 'Sales Rep' ){
            if(modelN.First_Name__c != null && modelN.Last_Name__c != null && modelN.Company_Name__c != null && modelN.Company_Address__c != null && modelN.Job_Title__c != null && modelN.Manager_Name__c != null && modelN.Manager_email_address__c != null && modelN.Tel_Mobile__c != null){
            modelN.Status__c= 'Submitted';
            modelN.Edit_Org_Sub_Category__c ='';
            modelN.Read_Org_Sub_Category__c ='';
            modelN.Assigned_Org_VAR__c='';
            upsert modelN;
            flag=false;
            nxp=false;
            disti = false;
            sales = false;
            var = false;
            success = true;
            nextnxp = false;
            nextdisti = false;
            nextsales = false;
            nextvar = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your application has been successfully submitted and a response to your request will arrive shortly. The user will not be able to logon to the system until the registration has been approved. If you do not receive a response, Please contact Global Sales Application support at globalsales.appsupport@nxp.com for any assistance.'));    
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record Not Saved !!'));
            }
        }else{
            if(modelN.First_Name__c != null && modelN.Last_Name__c != null && modelN.Company_Name__c != null && modelN.Company_Address__c != null && modelN.Job_Title__c != null && modelN.Tel_Mobile__c != null){
            modelN.Status__c= 'Submitted';
            
            modelN.Edit_Org_Sub_Category__c ='';
            modelN.Read_Org_Sub_Category__c ='';
            modelN.Role_Hierarchy_Country_Region__c='';
            modelN.Role_Hierarchy_Country_Sub_Region__c='';
            modelN.Role_Hierarchy_Region__c='';
            modelN.Role_Hierarchy_Sub_Region__c='';
            modelN.Read_Org__c='';
            modelN.Edit_Org__c='';
            modelN.Manager_email_address__c='';
            modelN.Manager_Name__c='';
            
            upsert modelN;
            flag=false;
            nxp=false;
            disti = false;
            sales = false;
            var = false;
            success = true;
            nextnxp = false;
            nextdisti = false;
            nextsales = false;
            nextvar = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your application has been successfully submitted and a response to your request will arrive shortly. The user will not be able to logon to the system until the registration has been approved. If you do not receive a response, Please contact Global Sales Application support at globalsales.appsupport@nxp.com for any assistance.'));    
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record Not Saved !!'));
            }
        }
    }
    
    public void back(){
        if(Flag){
            First = true;
            Flag = false;
        }else{
            Flag = false;
            First = true;
        }
        if(nxp){
            nxp = false;
            Flag = true;
            First = false;
        }
        disti = false;
        sales = false;
        var = false;
        nextnxp = false;
        nextdisti = false;
        nextsales = false;
        nextvar = false;
    }
    
    public void backnxp(){
        Flag = false;
        nxp = true;
        disti = false;
        sales = false;
        var = false;
        nextnxp = false;
        nextdisti = false;
        nextsales = false;
        nextvar = false;
        if(accesstype == 'Change Access'){
            changeacc = true;
        }
    }
    
    public void backdisti (){
        Flag = false;
        nxp = false;
        disti = true;
        sales = false;
        var = false;
        nextnxp = false;
        nextdisti = false;
        nextsales = false;
        nextvar = false;
        if(accesstype == 'Change Access'){
            changeacc = true;
        }
    }
    
    public void backSales (){
        Flag = false;
        nxp = false;
        disti = false;
        sales = true;
        var = false;
        nextnxp = false;
        nextdisti = false;
        nextsales = false;
        nextvar = false;
        if(accesstype == 'Change Access'){
            changeacc = true;
        }
    }
    
    public void backVar (){
        Flag = false;
        nxp = false;
        disti = false;
        sales = false;
        var = true;
        
        nextnxp = false;
        nextdisti = false;
        nextsales = false;
        nextvar = false;
        if(accesstype == 'Change Access'){
            changeacc = true;
        }
    }
    
    private boolean validateFields(){
        if(!(validateField(modelN.User_Type__c))){
            errorMessage='<li>User Type is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.First_Name__c))){
            errorMessage+='<li>First Name is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Last_Name__c))){
            errorMessage+='<li>Last Name is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Email_Address__c))){
            errorMessage+='<li>Email Address is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Requester_Email_Address__c))){
            isValid=false;
            errorMessage+='<li>Requester Email Address is Required!</li>';
        }
        /*if(isValid==false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }*/
        return isValid;
    }
    private boolean validateCompany(){
        if(!(validateField(modelN.Company_Name__c))){
            errorMessage+='<li>Company Name is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Company_Address__c))){
            errorMessage+='<li>Company Address is Required!</li>';
            isValid=false;
        }
        return isValid;
    }
    private boolean validateManager(){
        if(!(validateField(modelN.Manager_Name__c))){
            errorMessage+='<li>Manager Name is Required!</li>';
            isValid=false; 
        }
        if(!(validateField(modelN.Manager_email_address__c))){
            errorMessage+='<li>Manager Email Address is Required!</li>';
            isValid=false;
        }
        return isValid;
    }
    private boolean validateField(String value){
        if(value!=null && value.trim().length()>0)
            return true;
        return false;
    }
    private Boolean validate_EditOrgSubCategory(){
        if(validateField(modelN.Edit_Org__c)){
            List<String> stList1 = modelN.Edit_Org__c.split(';');
            for(String val :stList1){
                if(val.equalsIgnoreCase('Worldwide distribution')){
                    return true;
                }
            }
        }
        return false;
    }
    private Boolean validate_ReadOrgSubCategory(){
        if(validateField(modelN.Read_Org__c)){
            List<String> stList2 = modelN.Read_Org__c.split(';');
            for(String val :stList2){
                if(val.equalsIgnoreCase('Worldwide distribution')){
                    return true;
                }
            }
        }
        return false;
    }
    public void nxtNxp(){
        
        isValid=true;
        System.debug('@@');
        String valEn=ApexPages.currentPage().getParameters().get('j_id0:frm:nxp:pbs2:RHRN');
        System.debug('@@Enabled==#'+valEn+'#');
        String valDs=ApexPages.currentPage().getParameters().get('j_id0:frm:nxp:pbs2:RHSN');
        System.debug('@@Disabled==#'+valDs+'#');
        errorMessage='';
                
        validateFields();
        
        if(!(validateField(modelN.Region__c))){
            errorMessage+='<li>Region is Required!</li>';
            isValid=false;
        }
        validateManager();
        if(!(validateField(modelN.Tel_Mobile__c))){
            errorMessage+='<li>Tel Mobile is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Roles_Category__c))){
            errorMessage+='<li> Function is Required!</li>';
            isValid=false;
        }else if(modelN.Roles_Category__c== 'Business Lines'){
            if(!(validateField(modelN.BU__c))){
                errorMessage+='<li> BU is Required!</li>';
                isValid=false;
            }
            if(!(validateField(modelN.MAGS__c))){
                errorMessage+='<li> MAGS is Required!</li>';
                isValid=false;
            }
        }
        if(!(validateField(modelN.Role_Sub_Category__c))){
            errorMessage+='<li>Roles is Required!</li>';
            isValid=false;
        }
        /*if(!(validateField(modelN.Read_Org__c))){
            errorMessage+='<li>Read Org is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Edit_Org__c))){
            errorMessage+='<li> Edit Org is Required!</li>';
            isValid=false;
        }*/
        //*********************************
        if(validate_ReadOrgSubCategory()){
            if(!validateField(modelN.Read_Org_Sub_Category__c)){
                errorMessage+='<li>Select Read Org Sub Category For <b>Worldwide distribution</b>!</li>';
                isValid = false;
            }
        }
        if(validate_EditOrgSubCategory()){
            if(!validateField(modelN.Edit_Org_Sub_Category__c)){
                errorMessage+='<li>Select Edit Org Sub Category For <b>Worldwide distribution</b>!</li>';
                isValid = false;
            }
        }
        /*if(!(validateField(modelN.Role_Hierarchy_Region__c))){
            errorMessage+='<li>Roles Hierarchy Region is Required!</li>';
            isValid=false;
        }
        String valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:nxp:pbs2:RHSN');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Sub_Region__c))){
            errorMessage+='<li>Role Hierarchy Sub Region is Required!</li>';
            isValid=false;
        } 
        valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:nxp:pbs2:RHCN');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Country_Region__c))){
            errorMessage+='<li>Role Hierarchy Country Region is Required!</li>';
            isValid=false;
        } 
        valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:nxp:pbs2:RHCSN');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Country_Sub_Region__c))){
            errorMessage+='<li>Role Hierarchy Country Sub Region is Required!</li>';
            isValid=false;
        }*/
        if(isValid){  
            changeAcc = false;                  
            Flag = false;
            nxp = false;
            disti = false;
            sales = false;
            var = false;
            nextnxp = true;
            nextdisti = false;
            nextsales = false;
            nextvar = false;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }
    }
    
    public void nxtDisti(){
        changeAcc = false;
        isValid=true;
         errorMessage='';
        validateFields();
        
        if(!(validateField(modelN.Job_Title__c))){
            errorMessage+='<li>Job Title is Required!</li>';
            isValid=false;
        }
       if(!(validateField(modelN.Roles_Disti_new__c))){
            errorMessage+='<li>Roles Disti is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Disti_Role_Hierarchy__c))){
            errorMessage+='<li>Assigned Org is Required!</li>';
            isValid=false;
        }
        validateCompany();
        
        if(isValid){        
            Flag = false;
            changeAcc = false;
            nxp = false;
            disti = false;
            sales = false;
            var = false;
            nextnxp = false;
            nextdisti = true;
            nextsales = false;
            nextvar = false;
        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }
    }
    
    public void nxtSales(){
        isValid=true;
        changeAcc = false;
         errorMessage='';
        validateFields();
        validateCompany();
        if(!(validateField(modelN.Role_Hierarchy_Region__c))){
            errorMessage+='<li>Role Hierarchy Region is required!</li>';
            isValid=false;
        }
        /*if(!(validateField(modelN.Read_Org__c))){
            errorMessage+='<li>Read Org is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Edit_Org__c))){
            errorMessage+='<li> Edit Org is Required!</li>';
            isValid=false;
        } */
        if(!(validateField(modelN.Tel_Mobile__c))){
            errorMessage+='<li>Tel/Mobile Number is Required!</li>';
            isValid=false;
        }
        String valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:Sales:pbs3:RHSS');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Sub_Region__c))){
            errorMessage+='<li>Role Hierarchy Sub Region is Required!</li>';
            isValid=false;
        } 
        valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:Sales:pbs3:RHCS');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Country_Region__c))){
            errorMessage+='<li>Role Hierarchy Country Region is Required!</li>';
            isValid=false;
        } 
        valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:Sales:pbs3:RHCSS');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Country_Sub_Region__c))){
            errorMessage+='<li>Role Hierarchy Country Sub Region is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Job_Title__c))){
            errorMessage+='<li>Job Title is required!</li>';
            isValid=false;
        }
        if(isValid){
            Flag = false;
            nxp = false;
            disti = false;
            sales = false;
            var = false;
            nextnxp = false;
            nextdisti = false;
            nextsales = true;
            nextvar = false;
        }else {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }    
    }
    
    public void nxtVar(){
        isValid=true;
        errorMessage='';
        validateFields();
        validateCompany();
        if(!(validateField(modelN.Job_Title__c))){
            errorMessage+='<li>Job Title is required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Tel_Mobile__c))){
            errorMessage+='<li>Tel Mobile is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Assigned_Org_VAR__c))){
            errorMessage+='<li> Assigned Org is Required!</li>';
            isValid=false;
        }
        //validateManager();
        /*if(!(validateField(modelN.Role_Hierarchy_Region__c))){
            errorMessage+='<li>Roles Hierarchy Region is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Read_Org__c))){
            errorMessage+='<li>Read Org is Required!</li>';
            isValid=false;
        }
        if(!(validateField(modelN.Edit_Org__c))){
            errorMessage+='<li> Edit Org is Required!</li>';
            isValid=false;
        }*/
        
        /*String valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:Var:pbs4:RHSV');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Sub_Region__c))){
            errorMessage+='<li>Role Hierarchy Sub Region is Required!</li>';
            isValid=false;
        } 
        valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:Var:pbs4:RHCV');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Country_Region__c))){
            errorMessage+='<li>Role Hierarchy Country Region is Required!</li>';
            isValid=false;
        } 
        valReg=ApexPages.currentPage().getParameters().get('j_id0:frm:Var:pbs4:RHCSV');
        if(valReg!='__' && !(validateField(modelN.Role_Hierarchy_Country_Sub_Region__c))){
            errorMessage+='<li>Role Hierarchy Country Sub Region is Required!</li>';
            isValid=false;
        }*/
        if(isValid){
            Flag = false;
            nxp = false;
            disti = false;
            sales = false;
            var = false;
            nextnxp = false;
            nextdisti = false;
            nextsales = false;
            nextvar = true;
            changeAcc = false;
        }else {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }
    }
    public pageReference register(){
        pageReference pg = new pageReference('/apex/UserRegistration');
        init();
        return pg;
    }
}