/*************************************************************************
@Created By:     Manikanta
@Description:    For sharing Lead activities with Distributor
**************************************************************************/

public class ShareLeadActivity {
    
     @AuraEnabled
 public static list <Lead_activity__c> fetchLeadact(String leadId) {
  List <Lead_activity__c> returnleadList = new List <Lead_activity__c>();
 
  List <Lead_activity__c> ld = [select id,Action__c,Object__c,Specific_Interest__c from Lead_activity__c 
                                where related_to_lead__c =:leadId order by lastmodifieddate desc];
  // play for loop on lstCon and add each contact to returnConList List.
    for (Lead_activity__c c: ld) {
       returnleadList.add(c);
    }

      return returnleadList;
 }
 
      @AuraEnabled
    Public static Lead getleads(String leadId){
    Lead ldd =[select id,Name,company,Job_Description__c,Normalized_Title__c,Address,Industry,Email,
              Phone,HasOptedOutOfEmail,DoNotCall,city,state,street,PostalCode,Country,Rating,Status,Owner.Email from lead where id =:leadId];
        return ldd;
    }

     @AuraEnabled
      public static void shareLead(id leadid,String Name,String company,String jobdesc,String tit,String Industry,
                                   String Emaill,String Phnn,Boolean opemail,Boolean dncall,List<string> idss,
                                   String strt,String Cty,String Stat,String Cntry,String Zp,id contactId,String addnlcontact,String ownremail,String notes){
          string loggedInUser;
          Id idd = leadid;
          string nam = Name;
          string cmpny = company;
          string job = jobdesc;                                     
          String title = tit;
          String Ind = Industry;
          String Email = Emaill;
          String Phone = Phnn;
          Boolean optemail = opemail;
          Boolean dntcall =dncall;
          String street = strt;
          String city=cty;
          String state =stat;
          String Postal = zp;
          String country=cntry;
          Id Distiid = contactId;
          String addtnlcontact = addnlcontact;
        String assc = ownremail + ',' + addtnlcontact ;
                                           
                                       
       Contact c = [select id,Email,Name from contact where id =: Distiid];
                                       String Distiributorcontactemail = c.email;
                                       String Namee = c.Name;
           
        
                       List<Lead_activity__c>  ldactss =  [select id,Response_Date_Created__c,Action__c,Object__c,Specific_Interest__c,
                                   Specific_Interest_Description__c,Order_Status__c,General_Notes__c 
                                   from Lead_activity__c where id =: idss];
          

                      
              User u = [select Id,Name, username from User where Id = :UserInfo.getUserId()];
                                     if(u !=null){
                                         loggedInUser=u.Name;
                                     }
          
           List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
           Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
                                      
                                             
            String[] sendingTo = new String[]{Distiributorcontactemail};
            String[] leadownremail = new String[]{ownremail};
          
                
              String Htmlbody ='Hello'+ ' ' + c.Name + ',' + '</br></br>' +
                               'NXP has noticed some activity for a customer we share in common, and I thought you may find it interesting.</br></br>'+
                               '<b>*NOTE: This is NOT a lead. No action or response is required.</b></br></br>'+
                               '<table border="1" width="50%" empty-cells: hide; style ="border-collapse: collapse";>'+
                               '<tr><td width="30%"><b>NXP Representative’s Message</b></td>'+'<td width="50%">'+notes+'</td></tr>'+
                               '</table></br></br>' +
                               '<b> Customer Information:</b></br></br>'+
                                '<table border="1" width="50%" empty-cells: hide; style ="border-collapse: collapse";>'+
                               '<tr><td width="50"><b>Lead Id</b></td>'+'<td width="50">'+idd+'</td></tr>'+
                               '<tr><td width="50"><b>Name</b></td>'+'<td width="50">'+nam+'</td></tr>'+
                               '<tr><td width="50"><b>company</b></td>'+'<td width="50">'+cmpny+'</td></tr>'+
                               '<tr><td width="50"><b>Job Description</b></td>'+'<td width="50">'+job+'</td></tr>'+
                               '<tr><td width="50"><b>Normalized title</b></td>'+'<td width="50">'+title+'</td></tr>'+
                               '<tr><td width="50"><b>Address</b></td>'+'<td width="50">'+street+'</br>'+city+'</br>'+state+'</br>'+Postal+'</br>'+country+'</td></tr>'+
                               '<tr><td width="50"><b>Industry</b></td>'+'<td width="50">'+Ind+'</td></tr>'+
                               '<tr><td width="50"><b>Email</b></td>'+'<td width="50">'+Email+'</td></tr>'+
                               '<tr><td width="50"><b>Phone</b></td>'+'<td width="50">'+Phone+'</td></tr>'+
                               '<tr><td width="50"><b>HasOptedOutOfEmail</b></td>'+'<td width="50">'+optemail+'</td></tr>'+
                               '<tr><td width="50"><b>DoNotCall</b></td>'+'<td width="50">'+dntcall+'</td></tr>'+
                               '</table></br></br>' +
                
            
                               'Below is a  list of Lead activities related to Lead:<b>' +nam + '</b></br></br>' +
                                
             '<table border="1" width="50%" empty-cells: hide; style ="border-collapse: collapse";><tr><th>Response Date Created</th><th>Action</th><th>Object</th><th>Specific Interest</th><th>Specific Interest Description</th><th>Order Status</th><th>General Notes</th></tr>';
         
           for(Lead_activity__c l : ldactss){
    
               Datetime Responsedate = l.Response_Date_Created__c;
               String Action = l.Action__c;
               String Objectt = l.Object__c;
               String spinterest = l.Specific_Interest__c;
               String spintdesc= l.Specific_Interest_Description__c;
               String orderstat = l.Order_Status__c;
               String gennotes = l.General_Notes__c;

        Htmlbody += '<tr><td>' + Responsedate + '</td><td>' + Action + '</td><td>' + Objectt + '</td><td>' + spinterest + '</td><td>' + spintdesc + '</td><td>' + orderstat + '</td><td>' + gennotes + '</td></tr> </br>' ;
           }
          
          Htmlbody +=  '</table></br>Regards,</br>'+
                             +loggedInUser+'</br>';

           sendEmail.setToAddresses(sendingTo);
           if(addtnlcontact != null){
           List<String> AdditionalContacts = addtnlcontact.split(',');
            AdditionalContacts.add(ownremail);
           sendEmail.setCCAddresses(AdditionalContacts);
             }
            else{
            sendEmail.setCCAddresses(leadownremail);
             }

           sendEmail.setSubject('NXP / New activity from ' + cmpny);  
           sendEmail.setHtmlBody(Htmlbody);
           sendEmail.setSaveAsActivity(false);
           emails.add(sendEmail);
          
          if (emails != NULL && emails.size() > 0)
        {
          
            try{
               Messaging.sendEmail(emails);
                
   			    List<FeedItem> feed = new List<FeedItem>();
                List<Lead> leadidss = [select id,name from Lead where id =: idd];
                List<Lead_activity__c> leadacts =   [select id,name from Lead_activity__c  where id =: idss];
                
				  for(Lead la : leadidss){
				for(Lead_activity__c a : leadacts)
					{
                    FeedItem post = new FeedItem();
                    post.ParentId = la.id; 
                    post.Body = a.name + ' is shared with contact '  + c.name + ' on ' + system.today().format();
                    
                    feed.add(post);
}
                 
                }
                insert feed;
                
                  if(idd != null && emails != NULL && emails.size() > 0){
                     Lead updstatus = new Lead();
                	 updstatus.id=idd;
                     updstatus.Manual_Update_Check__c = true;
                     Update updstatus;
                 }
                
                
                if(idd != null && emails != NULL && emails.size() > 0){
                 
                 Lead updstatus = new Lead();
                 updstatus.id=idd;
                 updstatus.status = 'Activity shared';
                 Update updstatus;
                     }
                
                if(idd != null && emails != NULL && emails.size() > 0){
                                    
                     Lead updstatus = new Lead();
                	 updstatus.id=idd;
                     updstatus.Manual_Update_Check__c = false;
                     Update updstatus;
                 
                 }
                
            }
            
            catch(exception e){
                                
            }          
          
        }
      }

    

      @AuraEnabled
    public static String getDistiContactsForLead(String leadId,List<String> messages){
        List<Distributor_Lead_Tracker__c> dlcds = [SELECT Id,Name,Distributor_Contact__r.Name,Distributor_Contact__r.Email,
                                                   Additional_Email__c,Status__c from Distributor_Lead_Tracker__c 
                                                   where Lead_Id__c=:leadId];
        
        System.debug('results '+dlcds+' for lead Id '+leadId);
        Lead ld = [SELECT Id,Note_To_Disti__c from Lead where Id=:leadId];
        if(dlcds!=null && (!dlcds.isEmpty())){
            
            //String notesToDisti = ld.Note_To_Disti__c;
            LeadDistiContactDetails ldc = new LeadDistiContactDetails();
            for(Distributor_Lead_Tracker__c dlc:dlcds){
                if(dlc.Status__c == 'Assigned'){
                    ldc.primaryDistiContact=new DistiContact(dlc.id,dlc.Distributor_Contact__r.Name+'('+dlc.Distributor_Contact__r.Email+')',dlc.Additional_Email__c,'Assigned');
                }else if(dlc.Status__c == 'Queued'){
                    ldc.secondaryDistiContact=new DistiContact(dlc.id,dlc.Distributor_Contact__r.Name+'('+dlc.Distributor_Contact__r.Email+')',dlc.Additional_Email__c,'Queued');
                }           
            }
            ldc.notesToDisti=ld.Note_To_Disti__c;
            //ldc.rejectedByPrimary=ld.Gets_rejected_by_Primary_Distributor__c;
            //ldc.expiresWithPrimary=ld.Expires_with_Primary_Distributor__c;
            if(messages !=null && (!messages.isEmpty())){
                ldc.messages=messages;
            }
            System.debug('final results '+ldc+' for lead Id '+leadId);
            return Json.serialize(ldc);                    
        }else{
            LeadDistiContactDetails ldc = new LeadDistiContactDetails();
            ldc.notesToDisti= ld.Note_To_Disti__c;
            //ldc.expiresWithPrimary=ld.Expires_with_Primary_Distributor__c;
            return  Json.serialize( ldc);
        }        

    }
    
    public class LeadDistiContactDetails{
        public DistiContact primaryDistiContact{get;set;}
        public DistiContact secondaryDistiContact{get;set;}
        public String notesToDisti{get;set;}
        public boolean expiresWithPrimary{get;set;}
        public boolean rejectedByPrimary{get;set;}
        public List<String> messages{get;set;}
    }
    
    public class DistiContact{

        public DistiContact(String currrecordId,String contactDetails,String additionalEmail,
                            String assignedLeadStatus){
            recordId=currrecordId;
            distiContact = contactDetails;
            distiAdditionalEmail=additionalEmail;
            assignedLeadStatus=assignedLeadStatus;
        }
        public String recordId{get;set;}
        public String distiContact{get;set;}
        public String distiAdditionalEmail{get;set;}
        public String assignedLeadStatus{get;set;}
    }
     

}