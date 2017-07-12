/******************************************************************************************************************************************************************************************************************************************************* 
@Created By :       Avichal Kumar
@Created Date:      31th July 2015
@Description:       Controller class for community Faq Page
********************************************************************************************************************************************************************************************************************************************************/

/******************************************************************************************************************************************************************************************************************************************************* 
@Modified By :       Avichal Kumar
@Modified Date:      24th August 2015
@Description:       Sub Category Filtering
********************************************************************************************************************************************************************************************************************************************************/


public with sharing class CommunityFAQController {

    public Boolean PaginationDisplay { get; set; }

    public List<KnowledgeArticleVersion> articleList{get; set;}
    public list<FaqWrapper> lstFaqWrapper = new list<FaqWrapper>();
    public list<FaqWrapper> lstFaq{get; set;}
    private integer totalRecs;
    private integer OffsetSize = 0;
    private integer LimitSize= 10;
    public List<String> filterCategory{get;set;}
    public List<KnowledgeArticleVersion> lstSearchQues{get;set;}  
    public String strQues{get;set;}
    public List<KnowledgeArticleVersion> lstQue;    
    public set<id> faqIds{get;set;} 
    public list<knowledgeArticleVersion> lstFaqIds{get;set;}
    public String strCategory {get;set;}
    public String strSubCategory {get;set;}
    public List<SelectOption> lstOptions;
    public integer pageNum{get;set;}
    public integer totalPages{get;set;}
    public Id userId { get; set; }    
    
    public List<SelectOption> getCategories()
    {        
     //string cat= +'Automotive';
        lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('Select Category','Select Category'));
        lstOptions.add(new SelectOption('Automotive','Automotive'));       
        lstOptions.add(new SelectOption('I2C','I2C'));
        lstOptions.add(new SelectOption('Identification and Security','Identification and Security'));
        lstOptions.add(new SelectOption('Interface Products','Interface Products'));
        lstOptions.add(new SelectOption('Logic','Logic'));
        lstOptions.add(new SelectOption('Microcontrollers','Microcontrollers'));
        lstOptions.add(new SelectOption('RF','RF small signal'));
        lstOptions.add(new SelectOption('Standard Products','Standard Products'));        
        lstOptions.add(new SelectOption('Other Products','Other Products'));
        
        return lstOptions;
    }
    public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    public List<SelectOption> getsubCategories ()
    {    
        lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('Select Sub Category','Select Sub Category'));
        if(strCategory == 'Automotive')
        {   
            lstOptions.add(new SelectOption('General','General'));
        }
        else if(strCategory == 'Identification and Security')
        {    
            lstOptions.add(new SelectOption('NFC and Reader ICs','NFC and Reader ICs'));
            lstOptions.add(new SelectOption('Smart Card ICs','Smart Card ICs'));
            lstOptions.add(new SelectOption('Car Access & Immobilizer','Car Access & Immobilizer'));
            lstOptions.add(new SelectOption('Authentication','Authentication'));
            lstOptions.add(new SelectOption('Smart Label and Tag ICs','Smart Label and Tag ICs'));
            lstOptions.add(new SelectOption('Security and Surveillance IP Camera','Security and Surveillance IP Camera'));
        }
        else if(strCategory == 'Interface Products')
        {    
            lstOptions.add(new SelectOption('General','General'));
        }
        else if(strCategory == 'Logic')
        {    
            lstOptions.add(new SelectOption('General','General'));
        }
        else if(strCategory == 'Microcontrollers')
        {    
            lstOptions.add(new SelectOption('80C51','80C51'));
            lstOptions.add(new SelectOption('Chinese','Chinese'));
            lstOptions.add(new SelectOption('Graphics','Graphics'));
            lstOptions.add(new SelectOption('LPC800','LPC800'));
            lstOptions.add(new SelectOption('LPC11xx','LPC11xx'));
            lstOptions.add(new SelectOption('LPC12xx','LPC12xx'));
            lstOptions.add(new SelectOption('LPC13xx','LPC13xx'));
            lstOptions.add(new SelectOption('LPC15xx','LPC15xx'));
            lstOptions.add(new SelectOption('LPC17xx','LPC17xx'));
            lstOptions.add(new SelectOption('LPC18xx','LPC18xx'));
            lstOptions.add(new SelectOption('LPC2000','LPC2000'));
            lstOptions.add(new SelectOption('LPC3xxx','LPC3xxx'));
            lstOptions.add(new SelectOption('LPC40xx','LPC40xx'));
            lstOptions.add(new SelectOption('LPCOpen','LPCOpen'));
            lstOptions.add(new SelectOption('LPCXpresso','LPCXpresso'));
            lstOptions.add(new SelectOption('News','News'));
            lstOptions.add(new SelectOption('Peripherals','Peripherals'));
            lstOptions.add(new SelectOption('USB','USB'));
            lstOptions.add(new SelectOption('XA','XA'));
        }
        else if(strCategory == 'RF')
        {
            lstOptions.add(new SelectOption('AISG Transceiver','AISG Transceiver'));
            lstOptions.add(new SelectOption('Amplifiers','Amplifiers'));
            lstOptions.add(new SelectOption('CATV Hybrids and MMICs','CATV Hybrids and MMICs'));
            lstOptions.add(new SelectOption('Diodes','Diodes'));
            lstOptions.add(new SelectOption('RF-IF Building Block ICs','RF-IF Building Block ICs'));
            lstOptions.add(new SelectOption('Mixers','Mixers'));
            lstOptions.add(new SelectOption('Modulators','Modulators'));
            lstOptions.add(new SelectOption('PLLs and Oscillators','PLLs and Oscillators'));
            lstOptions.add(new SelectOption('Power Transistors','Power Transistors'));
            lstOptions.add(new SelectOption('Sub-GHz RF','Sub-GHz RF'));
            lstOptions.add(new SelectOption('Switches','Switches'));
            lstOptions.add(new SelectOption('Transmitters','Transmitters'));
            lstOptions.add(new SelectOption('Transistors','Transistors'));
            lstOptions.add(new SelectOption('Tuners','Tuners'));
            lstOptions.add(new SelectOption('ZigBee','ZigBee'));
            lstOptions.add(new SelectOption('Others','Others'));
        }
        else if(strCategory == 'Standard Product')
        {
            lstOptions.add(new SelectOption('Bipolar Transistors','Bipolar Transistors'));
            lstOptions.add(new SelectOption('Diodes','Diodes'));
            lstOptions.add(new SelectOption('ESD, EMI and Signal Conditioning','ESD, EMI and Signal Conditioning'));
            lstOptions.add(new SelectOption('MOSFETs','MOSFETs'));
            lstOptions.add(new SelectOption('Thyristors','Thyristors'));
        }
        else if(strCategory == 'Other Product')
        {
            lstOptions.add(new SelectOption('General','General'));
        }
       return lstOptions;
    }

    public CommunityFAQController() 
    {     
    
        lstFaq=new  list<FaqWrapper>();
        lstFaq=getFaqQuestions();
        system.debug('++++++++'+lstFaq);
        strCategory='select Category';
        strSubCategory='Select Sub CateGory';
        faqIds = new set<id>();
        lstFaqIds = new list<knowledgeArticleVersion>();
        Id profileId=userinfo.getProfileId();
        String strProfileName=[Select Id,Name from Profile where Id=:profileId].Name;
        lstSearchQues=new List<KnowledgeArticleVersion>();
        
        pageNum=1;
        if(lstfaq.size() == 0)
        {
         PageNum = 0;
        }
        
        
    }    
 
    //checkquestion from questview
    public void checkQues()
    { 
        String strTitle= '%'+strQues+'%';
        lstSearchQues=new List<KnowledgeArticleVersion>();
        if(strQues==null || strQues=='')
        {
            lstQue= [Select id,title from KnowledgeArticleVersion where(publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC];
        }
        else
        {
            lstQue= [Select id,title from KnowledgeArticleVersion where (title like: strTitle and publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC];
        }
        
        for(KnowledgeArticleVersion objQue: lstQue)
        {       
           lstSearchQues.add(objQue);   
        }
            
    }
    


    public List<FaqWrapper> getFaqQuestions() 
    {

         
      //  Catagory1 ='All';
       
        set<id> knowledgeids = new set<id>();
        faqIds= new  set<id>();
        lstFaqIds= new list<knowledgeArticleVersion>();
    
        lstFaqWrapper.clear(); 
        Articlelist=[SELECT Id, title  FROM knowledgeArticleVersion WHERE (PublishStatus = 'online' and Language = 'en_US' and isvisibleinpkb=true)];
        totalRecs=Articlelist.size();
        
        if(Articlelist.size() == 0)
        {
        totalpages = 0;
        }
        else
        { 
      
        totalpages=(integer)(Articlelist.size()/LimitSize);
        }
        
        if(totalRecs < limitsize && totalrecs > 0)
        {
            totalpages =1;
        }
        if((math.mod(Articlelist.size(),LimitSize))!= 0  && Articlelist.size() > limitsize )
        {
             totalpages = totalpages = totalpages + 1;
        }
  
        lstFaqIds=[select id,KnowledgeArticleid,title from knowledgeArticleVersion where (PublishStatus = 'online' and Language = 'en_US' and Isvisibleinpkb=true) limit :LimitSize offset:offsetSize];
   
        for(knowledgeArticleVersion objfaqids:lstFaqIds)
        {
            faqids.add(objfaqids.id);
        }
    
        for(knowledgeArticleVersion objfaqids:lstFaqIds)
        {
            knowledgeids.add(objfaqids.KnowledgeArticleid);
        }
        
        //List to get FAQ questions and Answers   
        list<Faq__kav> lstFaqQuestions = new list<Faq__kav>();
        lstFaqQuestions=[select id,question__c,Answer__c from Faq__kav Where (PublishStatus = 'online' and Language = 'en_US' and Isvisibleinpkb=true and id in :FaqIds)];
        
        //List to get FAQ category   
        list<Faq__DatacategorySelection> lstFaqCategory = new list<Faq__DatacategorySelection>();
        lstFaqCategory =[select parentid, DataCategoryGroupName, DataCategoryName FROM FAQ__DataCategorySelection where (IsDeleted = false and parentid in :FaqIds)];
    
        system.debug('groups::'+lstFaqCategory);
        //List To fetch FAQ rating
        list<Faq__votestat> lstFaqRating = new list<Faq__votestat>();
        system.debug(knowledgeids);
        lstFaqRating =[select parentid,Normalizedscore from faq__votestat where (channel='app' and parentid in :knowledgeids)];
        system.debug('+++++++'+lstFaqRating);
    
        for(id objfaqids:faqids)
        {
            faqwrapper objfaqwrapper = new faqwrapper(objfaqids);
            lstFaqWrapper.add(objfaqwrapper);
        }
    
        for (FaqWrapper objfaqWrapper1 :lstFaqWrapper)
          {
              for(knowledgeArticleVersion objfaqids1:lstFaqIds)
              {
                  if(objfaqWrapper1.id == objfaqids1.id)
                  {
                      objfaqWrapper1.knowledgeArticleid = objfaqids1.KnowledgeArticleid;
                      
                  }
              }
          
              system.debug('++++++'+lstFaqWrapper);
          
              for (faq__kav objfaqQuestions:lstFaqQuestions)
              {
                  if(objfaqWrapper1.id==objfaqQuestions.id)
                  {
                      objfaqWrapper1.question=objfaqQuestions.question__c;
                      objfaqWrapper1.Answer=objfaqQuestions.answer__c;
                  }
              }
              
              for (faq__datacategoryselection objfaqCategory:lstFaqCategory)
              {
                  if(objfaqWrapper1.id==objfaqCategory.parentid)
                  {
          
                      objfaqWrapper1.category= objfaqCategory.DataCategoryName;
          
                  }
              }
              
              for (faq__votestat objfaqRating:lstFaqRating)
              {
                  if(objfaqWrapper1.knowledgeArticleid==objfaqRating.parentid)
                  {
          
                      objfaqWrapper1.Rating= objfaqRating.Normalizedscore.setScale(2, RoundingMode.HALF_UP);
          
                  }
              }
          
          
           }
           return lstFaqWrapper;
    }
    
    public pagereference CatagorizedFAQ()
    {
    offsetsize=0;
    getCatagorizedFAQ2();
    if(Totalpages > 0)
    {
    pageNum=1;
    }
    else
    {
    pageNum=0;
    }
 
    return null;
    
    }
    public pagereference CatagorizedFAQ1()
    {
    
    getFaqQuestions();
    return null;
    
    }
    
    public list<faqwrapper> getCatagorizedFAQ2()
    {
  
  
        If(strCategory == 'Select Category' && strSubCategory== 'Select Sub Category')
        {
             getFaqQuestions();
        }
        else
        {
        lstFaqWrapper.clear();
        If(strSubCategory == 'Select Sub Category')
        {     
            filterCategory=getDescribeDataCategoryGroupStructureResults(strCategory);
        }
        else If(strSubCategory != 'Select Sub Category')
        {
   
            filterCategory=getDescribeDataCategoryGroupStructureResults(strSubCategory);
        }
    
        set<id> cfaqids = new set<id>();
        set<id> cfaqids1 = new set<id>();
        set<string> FilterCategory1 = new set<String>();
        
        
        For( string objFilterCategory : FilterCateGory)
        {
            FilterCateGory1.Add(objFilterCategory );
        }
    
        set<id> cknowledgeids = new set<id>();
    
        list<Faq__DatacategorySelection> lstFaqCategory = new list<Faq__DatacategorySelection>();
        lstFaqCategory =[select parentid, DataCategoryGroupName, DataCategoryName FROM FAQ__DataCategorySelection where (IsDeleted = false)];
         
        For(FAQ__DataCategorySelection objFAQcategory:lstFaqCategory)
        {
    
            if(filterCategory1.contains(objFAQcategory.DataCategoryName))
            {
                cfaqids.add(objFAQcategory.parentid);
            }
        }
    
        list<knowledgeArticleVersion> lstFaqIds1 = new list<knowledgeArticleVersion>();
        list<knowledgeArticleVersion> lstFaqIds2 = new list<knowledgeArticleVersion>();
        lstFaqIds2=[select id,KnowledgeArticleid,title from knowledgeArticleVersion where (PublishStatus = 'online' and Language = 'en_US' and Isvisibleinpkb=true and id in :cfaqids )];
        lstFaqIds1=[select id,KnowledgeArticleid,title from knowledgeArticleVersion where (PublishStatus = 'online' and Language = 'en_US' and Isvisibleinpkb=true and id in :cfaqids ) limit :LimitSize offset :OffsetSize ];
        totalRecs=lstFaqIds2.size();
       
        if(lstFaqIds2.size() == 0)
        {
        totalpages = 0;
         
        }
        else
        { 
      
        totalpages=(integer)(lstFaqIds2.size()/LimitSize);
        }
        if(totalRecs < limitsize && totalrecs > 0)
        {
            totalpages =1;
        }
        if((math.mod(lstFaqIds2.size(),LimitSize))!= 0 && lstFaqIds2.size() > limitsize )
        {
             totalpages = totalpages = totalpages + 1;
        }
        
        
        
        
        
        for(knowledgeArticleVersion objfaqids:lstFaqIds1)
        {
        cknowledgeids.add(objfaqids.KnowledgeArticleid);
        cfaqids1.add(objfaqids.id);
        }
        
        //list to fetch faq questions and answers
        list<Faq__kav> lstFaqQuestions1 = new list<Faq__kav>();
        lstFaqQuestions1=[select id,question__c,Answer__c from Faq__kav Where (PublishStatus = 'online' and Language = 'en_US' and Isvisibleinpkb=true and id in : cfaqids1)];
        
        //list to fetch faq data category
        list<Faq__DatacategorySelection> lstFaqCategory1 = new list<Faq__DatacategorySelection>();
        lstFaqCategory1 =[select parentid, DataCategoryGroupName, DataCategoryName FROM FAQ__DataCategorySelection where (IsDeleted = false and parentid in :cfaqids1)];
    
        //list to fetch faq rating
        list<Faq__votestat> lstFaqRating1 = new list<Faq__votestat>();
        lstFaqRating1 =[select parentid,Normalizedscore from faq__votestat where (channel='pkb' and parentid in :cknowledgeids)];
    
        for(id objfaqids:cfaqids1)
        {
        faqwrapper objfaqwrapper = new faqwrapper(objfaqids);
        lstFaqWrapper.add(objfaqwrapper);
        }
    
        for (FaqWrapper objfaqWrapper1 :lstFaqWrapper)
        {
           for(knowledgeArticleVersion objfaqids1:lstFaqIds1)
           {
              if(objfaqWrapper1.id == objfaqids1.id)
                  {
                      objfaqWrapper1.knowledgeArticleid = objfaqids1.KnowledgeArticleid;
                  }
           }
          
            for (faq__kav objfaqQuestions:lstFaqQuestions1)
            {
                if(objfaqWrapper1.id==objfaqQuestions.id)
                {
                    objfaqWrapper1.question=objfaqQuestions.question__c;
                    objfaqWrapper1.Answer=objfaqQuestions.answer__c;
                }
            }
            for (faq__datacategoryselection objfaqCategory:lstFaqCategory1)
            {
                if(objfaqWrapper1.id==objfaqCategory.parentid)
                {
                    objfaqWrapper1.category= objfaqCategory.DataCategoryName;
          
                }
            }
            for (faq__votestat objfaqRating:lstFaqRating1)
            {
          
                if(objfaqWrapper1.knowledgeArticleid==objfaqRating.parentid)
                {
          
                    objfaqWrapper1.Rating= objfaqRating.Normalizedscore.setScale(2, RoundingMode.HALF_UP);
          
                }
            }
          
         
         }
         for (FaqWrapper objfaqWrapper1 :lstFaqWrapper)
         {
             if(objfaqWrapper1.category=='Automotive' || objfaqWrapper1.category=='I2C' || objfaqWrapper1.category=='Identification and Security' || objfaqWrapper1.category=='Interface Products' ||
             objfaqWrapper1.category=='Logic' || objfaqWrapper1.category=='Microcontrollers' || objfaqWrapper1.category=='RF small Signal' || objfaqWrapper1.category=='standard products' ||
             objfaqWrapper1.category=='other products')
             {
                 objfaqWrapper1.Category = objfaqWrapper1.Category;
                 objfaqWrapper1.subCategory = objfaqWrapper1.Category;
             }
                
         }
         } 
         return lstFaqWrapper;
         
     
     }
     
     //Wrapper Class For FAQ Display
     public class FaqWrapper
     {

       
        public string Question{get; set;}
        
        public string Answer{ get; set; }
        
        public Id id{get;set;}
        
        public Id knowledgeArticleid{get;set;}
        
        public string category {get;set;}
        
        public string Subcategory {get;set;}
        
        public decimal rating{get;set;}
       
        
        public FaqWrapper(Id id)
        {
          
          this.id=id;
             
            
         }
      }
      //for top to bottom level category
      public List<String> getDescribeDataCategoryGroupStructureResults(string catagory)
      {
          List<DescribeDataCategoryGroupResult> describeCategoryResult;
          List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
          List<String> lstCategory=new List<String>();
          List<String> lstSubCategory=new List<String>();
          String strDataCategory;
          try 
          {
             List<String> objType = new List<String>();
             objType.add('knowledgearticleversion');
             describeCategoryResult = Schema.describeDataCategoryGroups(objType);
             List<DataCategoryGroupSobjectTypePair> pairs =new List<DataCategoryGroupSobjectTypePair>();
             for(DescribeDataCategoryGroupResult singleResult :describeCategoryResult)
             {
                DataCategoryGroupSobjectTypePair p =new DataCategoryGroupSobjectTypePair();
                p.setSobject(singleResult.getSobject());
                p.setDataCategoryGroupName(singleResult.getName());
                pairs.add(p);
             }
             //describeDataCategoryGroupStructures()
             describeCategoryStructureResult =Schema.describeDataCategoryGroupStructures(pairs, false);
             //Getting data from the result
             for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult)
             {
                 DataCategory [] toplevelCategories =singleResult.getTopCategories();
             
                //Category- All
                for(DataCategory topcategory: toplevelCategories)
                {
                    //Category- Automotive,I2C,Microcontroller etc
                    for(DataCategory category : topcategory.getChildCategories()) 
                    {
                        if(catagory.equalsIgnoreCase(category.getLabel()))
                        {
                          lstSubCategory.add(category.getName());
                            //Sub Category under above categories
                            for(DataCategory subCategory: category.getChildCategories())
                            {
                                lstSubCategory.add(subCategory.getName());          
                            }
                            
                        }
                        else
                        {
                            for(DataCategory subCategory: category.getChildCategories())
                            {
                                if(catagory.equalsIgnoreCase(Subcategory.getLabel()))
                                {
                                     lstSubCategory.add(subCategory.getName());   
                                }
                                        
                            }
                        }    
                               
                    }
                }
            }
      } 
      catch (Exception e){}
      return lstSubCategory;
      
      }
      
      
      
      public void FirstPage()
      {   
          getCatagorizedFAQ2();
          OffsetSize = 0;
          if(Totalpages > 0)
          {
          pageNum=1;
          }
          else
          {
          PageNum=0;
          }
           
          getCatagorizedFAQ2();
          
      }
      public void previous()
      {   
          getCatagorizedFAQ2();
          if(pageNum>1)
          {
              pageNum=pageNum-1;
          }
          if(offsetSize >= limitsize)
          {
              OffsetSize = OffsetSize - LimitSize;
          }
          getCatagorizedFAQ2();
      
      }
      
      public void next()
      {  
          
         getCatagorizedFAQ2();
         if(pageNum<totalPages)
          {
              pageNum=pageNum+1;
          }
          
         if(OffsetSize < totalRecs - limitsize)
         {
             OffsetSize = OffsetSize + LimitSize;
         }    
         getCatagorizedFAQ2(); 
         
      }   
      public void LastPage()
      {    
           getCatagorizedFAQ2();
           pageNum=totalPages; 
           if(totalRecs >= limitsize)
           {
           if((math.mod(totalRecs,LimitSize))== 0  )
           {
               OffsetSize = totalRecs - LimitSize - math.mod(totalRecs,LimitSize);
           }
           else
           {
               OffsetSize = totalRecs - math.mod(totalRecs,LimitSize);
           }
           }
           
           getCatagorizedFAQ2();   
        
      }    
      public boolean getprev()
      {
          if(OffsetSize == 0)
          {
              return true;
          }
          else
          {
              return false;
          }
      }
      public boolean getnxt()
      {
          getCatagorizedFAQ2();
          if((OffsetSize + LimitSize) > totalRecs)
          {
              return true;
          }    
          else
          {
              return false;
          }
      } 
      
      
}