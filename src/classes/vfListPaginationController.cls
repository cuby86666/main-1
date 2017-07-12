public class vfListPaginationController {


public String dataCategoryGroup{get; set;}
public String rootCategory{get; set;}
public String subCategory{get; set;}
public String filterString{ get;set;}
public Integer currentPage{ get; set;}
public Integer maxSize{get; set;}
public  Integer pageSize {get;set{ pageSize=10;}}
public String getCategoryName(){
rootCategory= ApexPages.currentPage().getParameters().get('rootCategory');
if (rootCategory!=null && rootCategory.length()>0){
return rootCategory.replace('_',' ');
}
return 'All';

}


public PageReference setFilterCategoryValue(){
if(subCategory!=null && subCategory!=''){
filterString=dataCategoryGroup+':'+subCategory;
String qryString='SELECT Id, title,  UrlName, LastPublishedDate,LastModifiedDate FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\') WITH DATA CATEGORY ' +dataCategoryGroup+'__c  AT '+subCategory+'__c' ;
System.debug('qryString is >>>>>>>>>>>>>>++++++++++++++'+qryString);
Database.query(qryString);
articleList= Database.query(qryString);
maxSize = articleList.size() ;

//ApexPages.currentPage().getParameters().put('maxSize', String.ValueOf(maxSize));
//ApexPages.currentPage().getParameters().put('subCategory', subCategory);
//System.debug('articlemaxSixe??????????'+maxSize);


}
rootCategory= ApexPages.currentPage().getParameters().get('rootCategory');
dataCategoryGroup= ApexPages.currentPage().getParameters().get('dataCategoryGroup');
if(filterString.contains('No Filter')){
filterString=dataCategoryGroup+':'+rootCategory;
return null;
}
return null;
}
    public List<KnowledgeArticleVersion> articleList{get;set;}
    public vfListPaginationController(ApexPages.StandardSetController controller) {
    }
    public String getCategoryKeyword() {
    rootCategory= ApexPages.currentPage().getParameters().get('rootCategory');
dataCategoryGroup= ApexPages.currentPage().getParameters().get('dataCategoryGroup');
    filterString=dataCategoryGroup+':'+rootCategory;
    String categoryCondition =System.currentPageReference().getParameters().Get('sCategory');
    if(categoryCondition!=null || categoryCondition!=''){
    filterString= dataCategoryGroup+':'+ categoryCondition;
   
 return filterString;
    
    
}
    return filterString;
    }
public String searchstring { get; set; }



public vfListPaginationController() {
pageSize=10;
currentPage=1;
filterString='NXP';
 dataCategoryGroup= ApexPages.currentPage().getParameters().get('dataCategoryGroup');
 rootCategory= ApexPages.currentPage().getParameters().get('rootCategory');
 subCategory= ApexPages.currentPage().getParameters().get('subCategory');
 
String qryString = 'SELECT Id, title,  UrlName, LastPublishedDate,LastModifiedDate FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'en_US\')';
if(dataCategoryGroup!=null && dataCategoryGroup.length()>0)
 { 
  qryString= qryString+' '+'WITH DATA CATEGORY'+' '+dataCategoryGroup+'__c';
   if (rootCategory!=null && rootCategory.length()>0) {
      if(subCategory!=null && subCategory.length()>0){
            qryString=qryString+' '+'At'+' '+subCategory+'__c';
            filterString=filterString+':'+subCategory;
        }   
    else{
            qryString=qryString+' '+'Below'+' '+rootCategory+'__c';
            filterString=filterString+':'+rootCategory;
         }
       }else{
       
          qryString=qryString+' '+ 'below ALL__c';
          filterString= filterString+':All';
       }
  }
  System.Debug('<<<<<<<<<<<<<<<<<<'+qryString);
    
        articleList= Database.query(qryString);
maxSize = articleList.size() ;
System.debug('articlemaxSixe??????????'+maxSize);
}


public boolean getPrevRequired() {
return currentPage > 1;
}
// Returns whether we need to see next button or not
public boolean getNextRequired() {
pageSize=10;

return currentPage*10 < maxSize;
//return true;
}
//Returns current page number
public Integer getCurrentPageNumber() {

return this.currentPage;
}
//action for next click
public PageReference next() {
pageSize=10;
//System.debug('maxSize Value>>>>>>>>>>>>>>>>>>>>>>>'+maxSize);
if(maxSize > this.currentPage * pageSize) {
this.currentPage = this.currentPage + 1;
//System.debug('Next Callesd*****************************currentPAge='+currentPage);
//System.debug('Next Callesd*****************************maxSize='+maxSize);
}
return null;
}
//action for previous click
public PageReference previous() {
if(this.currentPage > 1)
this.currentPage = this.currentPage - 1;
return null;
}
}