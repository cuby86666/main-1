/* @Name            :    AgreementController
   @Author          :    Syed Jameel
   @Date            :    11 Nov, 2011
   @Description     :    Use to bind data of Aggrement object to Aggrement Page. 
*/

public class AgreementController{

    public blob Attach { get; set; }
    public blob Abody { get; set; }
    public String fileName { get; set; }
    public String fileNameC { get; set; }
    public String contentType { get; set; }
    public Apttus__APTS_Agreement__c arg{get;set;}
    public boolean nxp{get;set;}
    public boolean nxp1{get;set;}
    public boolean isError{get;set;}
    public String flagMsg;
    public List<RecordType> recIdLst{get;set;}
    private Attachment att;
    public String Responsible_email{get;set;}
    
    //constructor
    public AgreementController(){   
        nxp=true;
        isError=false;
        nxp1=false;
        flagMsg='';
        arg = new Apttus__APTS_Agreement__c();
        recIdLst=[Select id from RecordType where SobjectType='Apttus__APTS_Agreement__c' and Name='NDA / Evaluation (Sales)'];
        System.Debug('>>>>>>>>>>>>>>>'+recIdLst);
        att = new Attachment();
    }
    public String getFileName() {
        return null;
    }
    public String getContentType() {
        return null;
    }
    public String getResponsible_email() {
        return null;
    }
    public PageReference next(){
       /* system.debug('$$$$$$$$$$$$$'+flagMsg);
        flagMsg='Following Fields are required.';
        //isError=false;
       if(arg.nxp_account_Legal_Entity__c == null){
           flagMsg += '<li>Account Legal Entity</li>';
           isError=True;
       }
       if(arg.nxp_account_Legal_Entity__c != null && arg.nxp_account_Legal_Entity__c.trim().length()==0){
           flagMsg += '<li>Account Legal Entity</li>';
           isError=True;
       }  
       if(arg.NXP_Legal_Entity__c == null){
           flagMsg += '<li>NXP Legal Entity</li>';
           isError=True;
       }
       if(arg.NXP_Legal_Entity__c != null && arg.NXP_Legal_Entity__c.trim().length()==0){
           flagMsg += '<li>NXP Legal Entity</li>';
           isError=True;
       }
       if(arg.Name == null){
           flagMsg += '<li>Agreement Name</li> ';
           isError=True;
       }
       if(arg.Name != null && arg.Name.trim().length()==0){
           flagMsg += '<li>Agreement Name</li> ';
           isError=True;
       }
       if(arg.nxp_agreement_info__c == null){
           flagMsg += '<li>Agreement Information</li>';
           isError=True;
       }
        if(arg.nxp_agreement_info__c != null && arg.nxp_agreement_info__c.trim().length()==0){
           flagMsg += '<li>Agreement Information</li>';
           isError=True;
       }
       if(arg.nxp_stakeholders__c == null ){
            flagMsg += '<li>StakeHolders</li> ';
           isError=True;
       }
       if(arg.nxp_stakeholders__c != null && arg.nxp_stakeholders__c.trim().length()==0){
            flagMsg += '<li>StakeHolders</li>';
           isError=True;
       }
       if(arg.Apttus__Contract_Start_Date__c == null){
           flagMsg += '<li>Agreement Start Date</li> ';
           isError=True;
       }
       if(arg.Apttus__Contract_End_Date__c == null){
           flagMsg += '<li>Agreement End Date</li>';
           isError=True;
       }
       if(arg.Submitter_Email_Address__c == null){
           flagMsg += '<li>Submitter Email Address</li>';
           isError=True;
       }
       if(Attach == null){
           flagMsg += '<li>Attachment</li>';
           isError=True;
       }*/
       /*if(!(arg.Submitter_Email_Address__c!=null && Attach != null)){
           flagMsg += '<li>The Submitter Email Address field & Attachment are required inorder to submit the form. Please provide the Email Address and Attachment to proceed.</li>'; 
           isError=True;    
       }*/
       
      // String st1=' Following Fields are required.';
       /*if(!isError){   
           system.debug('##################'+flagMsg);
           //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,flagMsg +'Field are required. In order to submit the form. Please Fill to proceed'));
           
          //if(arg.Submitter_Email_Address__c!=null && Attach != null){         
            try{
                 nxp=false;
                 nxp1=true;
                att.Body = Attach;
                att.Name = fileName;
                fileNameC = fileName;
                att.ContentType = contentType;
                ABody = Attach;
                //Attach=null;
                contentType=null;

                }catch(Exception e){
                    ApexPages.addMessages(e);
                } 
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, flagMsg ));
        }
       */
        return null;
    }
    public PageReference pre(){
        nxp=true;
        nxp1=false;
        fileName = fileNamec;
        Attach = Abody;
        contentType=null;
        //initAttach();
        return null;
    }
    public PageReference save(){
        //search user by email
        List<User> currentUser = [SELECT Id, Name, Username from User where IsActive=true and Email = :Responsible_email Limit 1];
        if (currentUser.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot find correct Responsible. Please fill correct Responsible Email Address!!!!!'));
            return null;
        }

        if(recIdLst.size()>0 && Attach != null&& arg.Submitter_Email_Address__c!=null){
            try{
                 att.Body = Attach;
                att.Name = fileName;
                att.ContentType = contentType;
                Attach=null;
                contentType=null;
                arg.recordTypeId=recIdLst.get(0).id;
                arg.nxp_Responsible__c = currentUser[0].Id;
                insert arg;
                //fileName = null;
                System.debug('*********** argID'+arg.id);
                att.ParentId = arg.id;
                insert att;                

                //initAttach();
                return new pageReference('/AgreementComplete');
            }catch(System.DMLException e){
                ApexPages.addMessages(e);
            }       
         }else{
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Submitter Email Address & Attachment are Required inorder to submit the form.Please fill Email field And Attachment!!!!!'));
         }
        return null;
    }
        
    private void initAttach(){
        Attach =null;
        att.Body=null;
        att.name=null;
        att.ContentType=null;
        fileName =null;
        att.Body=null;
    }
}