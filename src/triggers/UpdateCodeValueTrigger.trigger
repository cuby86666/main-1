trigger UpdateCodeValueTrigger on Case (before insert) {
    for(Case cs: Trigger.new)
    {  
        String Value='';
        CodeValue__c CV=new CodeValue__c();
        
        String jobID='';
        String productionID='';
        String eauID='';
        
        if(cs.Job_ID__c != null){
            jobID = 'ct-'+(String.valueof(cs.Job_ID__c)).substring(0, 1);
        }
        if(cs.Production_ID__c!=null){
            productionID = 'ps-'+(String.valueof(cs.Production_ID__c)).substring(0,1);
        }
        if(cs.EAU_ID__c !=null){
            eauID = 'eau-'+(String.valueof(cs.EAU_ID__c)).substring(0,1);
        }
          
        List<String> idList= new List<String>();
        idList.add(cs.State_Code__c);
        idList.add(cs.Alpha_3_Code__c);
        idList.add(cs.Product_Category_ID__c);
        idList.add(cs.Product_Sub_ID__c);
        idList.add(jobID);
        idList.add(productionID);
        idList.add(eauID);

        
        List<CodeValue__c> codeValueList = new List<CodeValue__c>();

        try{
            
            codeValueList=[Select CodeValue__c.Name,ValueOfCode__c from CodeValue__c where CodeValue__c.Name in :idList]; 
            
            for(CodeValue__c codeValue: codeValueList){

                
                if(cs.State_Code__c == codeValue.Name){
                    cs.Web_State__c = String.valueof(codeValue.ValueOfCode__c);
                }else if (cs.Alpha_3_Code__c == codeValue.Name){
                    cs.Web_Country__c = String.valueof(codeValue.ValueOfCode__c);
                }else if (cs.Product_Category_ID__c == codeValue.Name){
                    cs.Product_Category__c = String.valueof(codeValue.ValueOfCode__c);
                }else if (cs.Product_Sub_ID__c == codeValue.Name){
                    cs.Product_Sub__c = String.valueof(codeValue.ValueOfCode__c);
                }else if (jobID == codeValue.Name){
                    cs.Contact_Title__c = String.valueof(codeValue.ValueOfCode__c);
                }else if (productionID == codeValue.Name){
                    cs.Project_Stage__c = String.valueof(codeValue.ValueOfCode__c);
                }else if (eauID == codeValue.Name){
                    cs.Expected_annual_unit_volume__c = String.valueof(codeValue.ValueOfCode__c); 
                }
            }
        }
        catch (Exception e){
            cs.Web_State__c = 'Not Provided';
            cs.Web_Country__c = 'Not Provided';
            cs.Product_Category__c = 'Not Provided';
            cs.Product_Sub__c = 'Not Provided';
            cs.Contact_Title__c = 'Not Provided';
            cs.Project_Stage__c = 'Not Provided';
            cs.Expected_annual_unit_volume__c = 'Not Provided';
            
        }
        
    }
}