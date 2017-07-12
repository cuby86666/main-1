/************************************************************************************************************
Name            :        FindAttachments
Date            :        20 April, 2011
Author          :        Syed Jameel
Description     :        To find the attachments and agreement documents
************************************************************************************************************/

trigger FindAttachments on Apttus__APTS_Agreement__c (before update) {
    SET<ID> agreementids = new SET<ID>();
    
    //MAP<ID, List<Attachment>> agreementattachMap = new MAP<ID, List<Attachment>>();
    List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
    
    for(Apttus__APTS_Agreement__c agreement : Trigger.New){
            agreementids.add(agreement.id);
    }
    
    if(agreementids != null && agreementids.size() > 0){
        Integer numAtts=[select count() from attachment where parentid=:agreementids];
        List<Attachment> attachList = [select id, name,  parentid from attachment where parentid in : agreementids];
        List<Apttus__Agreement_Document__c> agreementDocList = [select id, name, Apttus__Agreement__c, Apttus__URL__c, Apttus__URL_Link__c from Apttus__Agreement_Document__c where Apttus__Agreement__c in : agreementids];
        
        
        Map<Id, List<Attachment>> attachMap = new Map<Id, List<Attachment>>();
        if(attachList != null && attachList.size() > 0){
            for(Attachment att : attachList){
                List<Attachment> atts = attachMap.get(att.parentId);
                if(atts != null){
                    atts.add(att);
                    attachMap.put(att.parentId, atts);
                }else{
                    atts = new List<Attachment>();
                    atts.add(att);
                    attachMap.put(att.parentId, atts);
                }
            }
        }
        
        MAP<ID, List<Apttus__Agreement_Document__c>> agreementdocMap = new MAP<ID, List<Apttus__Agreement_Document__c>>();
        if(agreementDocList != null && agreementDocList.size() > 0){
            for(Apttus__Agreement_Document__c agreedoc : agreementDocList){
                List<Apttus__Agreement_Document__c> agreedocs = agreementdocMap.get(agreedoc.Apttus__Agreement__c);
                if(agreedocs != null){
                    agreedocs.add(agreedoc);
                    agreementdocMap.put(agreedoc.Apttus__Agreement__c, agreedocs);
                }else{
                    agreedocs = new List<Apttus__Agreement_Document__c>();
                    agreedocs.add(agreedoc);
                    agreementdocMap.put(agreedoc.Apttus__Agreement__c, agreedocs);
                }
            }
        }
        //////////////////////////////////////////
        /*for(Apttus__APTS_Agreement__c agreement : Trigger.New){
            List<Attachment> attachmentList = new List<Attachment>();
            List<Apttus__Agreement_Document__c> agreementDocumentList = new List<Apttus__Agreement_Document__c>();
            for(Attachment att : attachList){
                if(att.parentid == agreement.id){
                    attachmentList.add(att);
                }
            }
            
            for(Apttus__Agreement_Document__c agreedoc : agreementDocList){
                if(agreedoc.Apttus__Agreement__c ==  agreement.id){
                    agreementDocumentList.add(agreedoc);
                }
            }
            agreementattachMap.put(agreement.id, attachmentList);
            agreementdocMap.put(agreement.id, agreementDocumentList);
        }*/
        ////////////////////////////////////////////////////
        
        for(Apttus__APTS_Agreement__c agreement : Trigger.New){
            if(Trigger.isUpdate){
                String strattachment = '';
                String stragreedoc ='';
                if(attachMap != null && attachMap.size() > 0){
                    List<Attachment> attList = attachMap.get(agreement.id);
                    if(attList != null && attList.size() > 0){
                        for(Attachment att : attList){
                            strattachment = strattachment+att.Name+', ';
                            //agreementattachMap.put(att.parentid, att);    
                        }
                        strattachment = strattachment.substring(0, strattachment.length()-2);
                    }
                }
                if(agreementdocMap != null && agreementdocMap.size() > 0){
                    List<Apttus__Agreement_Document__c> agreedocList = agreementdocMap.get(agreement.id);
                    if(agreedocList != null && agreedocList.size() > 0){
                        for(Apttus__Agreement_Document__c agreeDoc : agreeDocList){
                            stragreedoc = stragreedoc+agreeDoc.Name+', ';
                        }
                        stragreedoc = stragreedoc.substring(0, stragreedoc.length()-2);
                    }
                }
                
               // if(strattachment != '' || stragreedoc != ''){
                    agreement.Attachment_File_Name__c = strattachment;
                    agreement.Agreement_Document_Name__c = stragreedoc;
                    agreementList.add(agreement);
                //}
            }
        }
    }
}