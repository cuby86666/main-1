/*
        Name            :   CaseCloseController
        Author          :   Syed Jameel
        Date            :   13th April 2012
        Description     :   Controller to override standard close case functionality. 
*/

public class CaseCloseController{
    public Case cs{get;set;}
    //public boolean sendNotification{get;set;}
    public String title{set;get;}
    public String contant{set;get;}
    public CaseCloseController(ApexPages.StandardController sc){
        //sendNotification = true;
        cs = new case();
        cs = [select Id, Status, Resolution__c,Contact.Name,Contact.Email,Contact.Id from Case where Id = :sc.getId()];
    }
    //Method Saving case and send email if sendNotification is true
    public PageReference saveCase(){
        cs.Status = 'Close';
        update cs;
        sendEmail();
        /*if(sendNotification){
            system.debug('@@@@ Send Notification = '+sendNotification);
            sendEmail();
        }
        */
        return new PageReference('/'+cs.Id);
    }
    //Method saving case, send email and create 
    
    public PageReference saveAndCreateArticle(){
        saveCase();
        return new PageReference('/knowledge/publishing/articleEditSimple.apexp?retURL=%2F'+cs.Id+'&sourceId='+cs.Id+'&sfdc.override=1');
    }
    //Method cancel closing case
    public PageReference cancel(){
        return new PageReference('/'+cs.Id);
    }
    //Method send email to the contact email of case
    public void sendEmail(){
        List<EmailTemplate> templateIds = [Select Id from EmailTemplate where Name='Case Resolved with Article HTML'];
        if(templateIds.size()>0){
            List<CaseArticle> lstCaseArt = [select id, caseId, KnowledgeArticleId from CaseArticle where caseId = :cs.Id];
            List<Id> lstKnowledgeArtIds = new List<Id>();
            for(CaseArticle caseArt : lstCaseArt){
                lstKnowledgeArtIds.add(CaseArt.KnowledgeArticleId);
            }
            
            List<KnowledgeArticleVersion> lstKnowledgeArtVer = [Select KnowledgeArticleId, Id,Title, Summary From KnowledgeArticleVersion where publishstatus = 'Online' and KnowledgeArticleId in :lstKnowledgeArtIds];
            
            List<Messaging.EmailFileAttachment> efa = new List<Messaging.EmailFileAttachment>();
            if(lstKnowledgeArtVer.size()>0){
                for(KnowledgeArticleVersion knowledgeVer : lstKnowledgeArtVer){
                    //Messaging.EmailFileAttachment ef = new Messaging.EmailFileAttachment();
                    System.debug('@@@ Knowledge == ' + knowledgeVer.Id);
                    PageReference pg = new PageReference('/knowledge/articlePrintableView.apexp?id=' + String.valueOf(knowledgeVer.KnowledgeArticleId).substring(0, 15) + '&version=1');
                    Messaging.EmailFileAttachment ef = new Messaging.EmailFileAttachment();
                    ef.setFileName(knowledgeVer.title+'.pdf');
                    blob b =pg.getContentAsPDF();
                    ef.setBody(b);
                    efa.add(ef);
                }
            }

            System.debug('@@@@@@@ isze of attachment = '+ efa.size());

            List<Messaging.SingleEmailMessage> emails=new List<Messaging.SingleEmailMessage>();
            List<String> addresses = new List<String>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            addresses.add(cs.Contact.Email);
            //email.setToAddresses(addresses);
            email.setTargetObjectId(cs.Contact.Id);
            email.setTemplateId(templateIds[0].Id);
            email.setWhatId(cs.Id);
            if(efa.size()>0){
                email.setFileAttachments(efa);
            }
            emails.add(email);
            Messaging.sendEmail(emails);
            System.debug('@@@@ email sent seccessfully');
        }
    }
    /* This Method redirect the community internal users to community User interface for closing the case.
       Author:   Arjit Garg
     */
       
    public PageReference redirectToCommunityCaseCloseView(){
   
    if(((ApexPages.currentPage()).getHeaders().get('Referer')).contains('community')){
      PageReference pageref= new PageReference('/community/apex/CommunitiesCaseClose?id='+cs.id);
      pageref.setRedirect(true);
      return pageref;
    }
    
return null;
    }
}