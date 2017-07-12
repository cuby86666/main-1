/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     18 Jul 2015
Description :      Class for NXP community users to submit question-CommunitySubmitQuestionFooterComponent
************************************************************************************************************/
/***************************************************************************************************************************************************************************************************************************************************** 
@Modified By :       Amrutha R
@Modified Date:      14th Sept 2015
@Description:       added edit and delete functionality for questions
******************************************************************************************************************************************************************************************************************************************************/
/***************************************************************************************************
@Modified By :      Amrutha R
@Modified Date:     23 Nov 2015
@Description:       Fixed Question Attachmnet issue
*******************************************************************************************************/

public class CommunitySubmitQuestionFooterController 
{
   
    public String strTitle{get;set;}
    public String strBody{get;set;}
    public String strCategory {get;set;}
    public String strSubCategory {get;set;}
    public List<SelectOption> lstCatOptions ;
    public List<SelectOption> lstSubCatOptions ;
    public Id userId { get; set; }
    public boolean submitQues{get;set;}
    public Attachment objAttachment {get;set;}
    public boolean editQues{get;set;}
 
    
    //method to fetch product categories
    public List<SelectOption> getCategories()
    {        
        lstCatOptions = new List<SelectOption>();
        lstCatOptions .add(new SelectOption('Select Category','Select Category'));
        lstCatOptions .add(new SelectOption('Automotive','Automotive'));       
        lstCatOptions .add(new SelectOption('I2C','I2C'));
        lstCatOptions .add(new SelectOption('Identification and Security','Identification and Security'));
        lstCatOptions .add(new SelectOption('Interface Products','Interface Products'));
        //lstCatOptions .add(new SelectOption('Microcontrollers','Microcontrollers'));
        lstCatOptions .add(new SelectOption('RF','RF small signal'));
        lstCatOptions .add(new SelectOption('Discretes and Logic','Discretes and Logic'));        
        lstCatOptions .add(new SelectOption('Other Products','Other Products'));
 
        return lstCatOptions ;
    }
    
    //method to fetch product sub categories
    public List<SelectOption> getsubCategories ()
    {
        lstSubCatOptions = new List<SelectOption>();
        lstSubCatOptions .add(new SelectOption('Select Sub Category','Select Sub Category'));
        if(strCategory == 'Identification and Security')
        {    
            lstSubCatOptions .add(new SelectOption('NFC and Reader ICs','NFC and Reader ICs'));
            lstSubCatOptions .add(new SelectOption('Smart Card ICs','Smart Card ICs'));
            lstSubCatOptions .add(new SelectOption('Car Access & Immobilizer','Car Access & Immobilizer'));
            lstSubCatOptions .add(new SelectOption('Authentication','Authentication'));
            lstSubCatOptions .add(new SelectOption('Smart Label and Tag ICs','Smart Label and Tag ICs'));
            lstSubCatOptions .add(new SelectOption('Security and Surveillance IP Camera','Security and Surveillance IP Camera'));
        }
        /*
        else if(strCategory == 'Microcontrollers')
        {    
            lstSubCatOptions .add(new SelectOption('80C51','80C51'));
            lstSubCatOptions .add(new SelectOption('Chinese','Chinese'));
            lstSubCatOptions .add(new SelectOption('Graphics','Graphics'));
            lstSubCatOptions .add(new SelectOption('LPC800','LPC800'));
            lstSubCatOptions .add(new SelectOption('LPC11xx','LPC11xx'));
            lstSubCatOptions .add(new SelectOption('LPC12xx','LPC12xx'));
            lstSubCatOptions .add(new SelectOption('LPC13xx','LPC13xx'));
            lstSubCatOptions .add(new SelectOption('LPC15xx','LPC15xx'));
            lstSubCatOptions .add(new SelectOption('LPC17xx','LPC17xx'));
            lstSubCatOptions .add(new SelectOption('LPC18xx','LPC18xx'));
            lstSubCatOptions .add(new SelectOption('LPC2000','LPC2000'));
            lstSubCatOptions .add(new SelectOption('LPC3xxx','LPC3xxx'));
            lstSubCatOptions .add(new SelectOption('LPC40xx','LPC40xx'));
            lstSubCatOptions .add(new SelectOption('LPCOpen','LPCOpen'));
            lstSubCatOptions .add(new SelectOption('LPCXpresso','LPCXpresso'));
            lstSubCatOptions .add(new SelectOption('News','News'));
            lstSubCatOptions .add(new SelectOption('Peripherals','Peripherals'));
            lstSubCatOptions .add(new SelectOption('USB','USB'));
            lstSubCatOptions .add(new SelectOption('XA','XA'));
        }*/
        else if(strCategory == 'RF')
        {
            lstSubCatOptions .add(new SelectOption('AISG Transceiver','AISG Transceiver'));
            lstSubCatOptions .add(new SelectOption('Amplifiers','Amplifiers'));
            lstSubCatOptions .add(new SelectOption('CATV Hybrids & MMICs','CATV Hybrids & MMICs'));
            lstSubCatOptions .add(new SelectOption('Diodes','Diodes'));
            lstSubCatOptions .add(new SelectOption('RF-IF Building Block ICs','RF-IF Building Block ICs'));
            lstSubCatOptions .add(new SelectOption('Mixers','Mixers'));
            lstSubCatOptions .add(new SelectOption('Modulators','Modulators'));
            lstSubCatOptions .add(new SelectOption('PLL\'s and Oscillators','PLL\'s and Oscillators'));
            lstSubCatOptions .add(new SelectOption('Power Transistors','Power Transistors'));
            lstSubCatOptions .add(new SelectOption('Sub-GHz RF','Sub-GHz RF'));
            lstSubCatOptions .add(new SelectOption('Switches','Switches'));
            lstSubCatOptions .add(new SelectOption('Transmitters','Transmitters'));
            lstSubCatOptions .add(new SelectOption('Transistors','Transistors'));
            lstSubCatOptions .add(new SelectOption('Tuners','Tuners'));
            lstSubCatOptions .add(new SelectOption('ZigBee','ZigBee'));
            lstSubCatOptions .add(new SelectOption('Others','Others'));
        }
        else if(strCategory == 'Discretes and Logic')
        {
            lstSubCatOptions .add(new SelectOption('Bipolar Transistors','Bipolar Transistors'));
            lstSubCatOptions .add(new SelectOption('Diodes','Diodes'));
            lstSubCatOptions .add(new SelectOption('ESD Protection','ESD Protection'));
            lstSubCatOptions .add(new SelectOption('MOSFETs','MOSFETs'));
            lstSubCatOptions .add(new SelectOption('Logic','Logic'));
        }
        
       return lstSubCatOptions ;
    }

    //method to fetch user photo url
    public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    

    public CommunitySubmitQuestionFooterController()
    {

        submitQues=true;
        editQues=false;
        //if edit question
        if(ApexPages.currentPage().getParameters().get('strQuesId')!=null)
        {
            submitQues=false;
            editQues=true;
            List<Question> objQues=[Select id,title,body,createdBy.id,Product_Category__c,Product_Sub_Category__c from Question where id=: ApexPages.currentPage().getParameters().get('strQuesId') LIMIT 1];
            if(objQues!=null || objQues.size()!=0)
            {
                strTitle= objQues[0].title;
                strBody= objQues[0].body;
                strCategory=  objQues[0].Product_Category__c;
                strSubCategory=  objQues[0].Product_Sub_Category__c;
            }
            
        }
       objAttachment= new attachment();
    }
    
    //method to edit question
    public PageReference editQues()
    {
        Community objCom= [Select Id, name From Community Where Name='NXP Community'];
        List<Question> objQue=[Select id,title,body,createdBy.id,Product_Category__c,Product_Sub_Category__c from Question where id=: ApexPages.currentPage().getParameters().get('strQuesId') LIMIT 1];
        if(objQue!=null || objQue.size()!=0)
        {
            objQue[0].Title= strTitle;
            objQue[0].Body= strBody;
            objQue[0].Product_Category__c= strCategory ;
            objQue[0].Product_Sub_Category__c= strSubCategory ;
        }
        if(objQue[0].Title=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter title for your question'));
            return null;
        }
        if(objQue[0].Body=='' || objQue[0].Body==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Description for your question'));
            return null;
        }
        if(objQue[0].Product_Category__c =='' || objQue[0].Product_Category__c  =='Select Category')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select category'));
            return null;
        }
        try 
            {
                update objQue;
               
                PageReference pageRef;
                pageRef=new PageReference('/CommunityQuestionview?id='+objQue[0].id);
                pageref.setRedirect(true);
                return pageref;
            }
            catch (DMLException e) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error is updating Question'));
                return null;
            }
    }

    //method to submit question to forum
    public PageReference submitQues()
    {
        Community objCom= [Select Id, name From Community Where Name='NXP Community'];
        if(strTitle=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter title for your question'));
            return null;
        }
        if(strBody=='' || strBody==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Description for your question'));
            return null;
        }
        if(strCategory =='' || strCategory  =='Select Category')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select category'));
            return null;
        }
        else
        {
            Question objQue= new Question();
            objQue.Title= strTitle;
            objQue.Body= strBody;
            objQue.Product_Category__c= strCategory ;
            objQue.Product_Sub_Category__c= strSubCategory ;
            objQue.CommunityId= objCom.id;
            Savepoint sp = Database.setSavepoint();
           try 
            {
                insert objQue;
                
                QuestionDataCategorySelection objQueSel= new QuestionDataCategorySelection();
                objQueSel.ParentId= objQue.id;
                objQueSel.DataCategoryGroupName= 'NXP';
                objQueSel.DataCategoryName= getDescribeDataCategoryGroupStructureResults();
                insert objQueSel;
                
                 PageReference pageRef;
                if(strSubCategory=='' || strSubCategory=='Select Sub Category')
                {
                   pageRef=new PageReference('/CommunityForumQuestionList?category='+strCategory);
                }
                else
                {
                if(strSubCategory.equalsIgnoreCase('Diodes'))
                {
                    if(strCategory.equalsIgnoreCase('RF'))
                    {
                        pageRef=new PageReference('/CommunityForumQuestionList?category=RF Diodes');
                        
                    }
                    else if(strCategory.equalsIgnoreCase('Discretes and Logic'))
                    {
                        pageRef=new PageReference('/CommunityForumQuestionList?category=Diodes');
                        
                    }
                } 
                else if(strSubCategory!='' || strSubCategory!='Select Sub Category')
                {
                    pageRef=new PageReference('/CommunityForumQuestionList?category='+strSubCategory);
                }
                }
                // code added by Avichal Kumar
                
                if(objAttachment.body!=null)
                {
                	Question_Attachment__c objQuestionAttachment= new Question_Attachment__c();
                	objQuestionAttachment.Question_Attachment__c=objQue.id;
                    
                	insert objQuestionAttachment;
                 	objAttachment.ParentId=objQuestionAttachment.id;
                
                    insert(objAttachment);
                }
                 // code added by Avichal Kumar ends here 
                pageref.setRedirect(true);
                return pageref;
            }
            catch (DMLException e) 
            {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error is inserting Question'));
                return null;
            }
            
       }        
    }
 
  //method to fetch categories unique name which is used while inserting questiondatacategoryselection record for a question
   public String getDescribeDataCategoryGroupStructureResults()
   {
      List<DescribeDataCategoryGroupResult> describeCategoryResult;
      List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
      String strDataCategory;
      try 
      {
         //Making the call to the describeDataCategoryGroups to
         //get the list of category groups associated
         List<String> objType = new List<String>();
         objType.add('Question');
         describeCategoryResult = Schema.describeDataCategoryGroups(objType);
         //Creating a list of pair objects to use as a parameter
         //for the describe call
         List<DataCategoryGroupSobjectTypePair> pairs =new List<DataCategoryGroupSobjectTypePair>();
         //Looping throught the first describe result to create
         //the list of pairs for the second describe call
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
             if(strSubCategory==null || strSubCategory=='--None--' || strSubCategory=='Select Sub category')
             {
                 for(DataCategory topcategory: toplevelCategories)
                 {
                     for(DataCategory category:topcategory.getChildCategories())
                     {
                        if(category.getLabel().Contains(strCategory))
                        {
                            strDataCategory= category.getName();
                            break;
                        }
                     } 
                 }
             }
             else
             {
                //Category- All
                for(DataCategory topcategory: toplevelCategories)
                {
                    //Category- Automotive,I2C,Microcontroller etc
                    for(DataCategory category : topcategory.getChildCategories()) 
                    {
                        if(category.getLabel().Contains(strCategory))
                        {
                            //Sub Category under above categories
                            for(DataCategory subCategory: category.getChildCategories())
                            {
                                if(subCategory.getLabel().Contains(strSubCategory))
                                {
                                    strDataCategory= subCategory.getName();
                                    break;
                                }
                            } 
                        }
                    }
                }
             }
         }
      } 
      catch (Exception e){}
      return strDataCategory;
    }
 
}