public class communityController {
   public Case c {get;set;}
    public communityController(ApexPages.StandardController controller) {
       c=(Case)controller.getRecord();
      
    }
    public PageReference redirectToCommunityDetailView(){
    Id profileId=userinfo.getProfileId();
 
      //System.Debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%Headers'+ApexPages.currentPage().getHeaders().get('Referer'));
      if(ApexPages.currentPage().getHeaders()!=null){
      if(((ApexPages.currentPage()).getHeaders().get('Referer'))!=null){
    if(((ApexPages.currentPage()).getHeaders().get('Referer')).contains('community')){
    PageReference pageref= new PageReference('/community/apex/CommunitiesCaseDetailView?id='+c.id);
pageref.setRedirect(true);
return pageref;
    }
   }
   }
return null;
    
    }

}