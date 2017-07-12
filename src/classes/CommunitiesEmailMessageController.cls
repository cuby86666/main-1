public class CommunitiesEmailMessageController {
public Id EmailId{get;set;}
public List<Attachment> myAttachments {get;set;}
//public Attachment myAttchment{get;set;}
    public CommunitiesEmailMessageController(ApexPages.StandardController controller) {
    
    EmailId=ApexPages.currentPage().getParameters().get('id');
    myAttachments=[Select Id,Name,BodyLength,CreatedBy.Name,CreatedDate,Body,ContentType,Description,ParentId from Attachment where ParentId= : EmailId];
    System.debug('??????????????????//'+myAttachments.size());

    }
public List<Attachment> getAttachments(){
 if(EmailId!= null ){
 myAttachments=[Select Id,Name,BodyLength,CreatedBy.Name,CreatedDate,Body,ContentType,Description,ParentId from Attachment where ParentId= : EmailId];
 
 
 }
 return myAttachments;


}
}