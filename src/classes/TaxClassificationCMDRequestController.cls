/**************************************************************************************
@Created By :       Scarlett Kang
@Created Date:      21 Nov 2014
@Description:       Extension class for VF Page TaxClassification - (CMD Request Tool)
-------------------------------------------------------------------------------------
@Modified By :       Jewelslyn
@Modified Date:      5 Nov 2015
@Description:        Added Tax classificiation data for Sales Org HK91
-------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      08 Mar 2016
@Description:        Added new Sales Org for FSL order migration and added Tax Classification data for Sales Org JP60 & CN60
-------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      13 Jun 2016
@Description:        1606 Release SIR 915 - [COM] Revise Funloc CMD approval flow 
                     and add new Tax Classification for new Sales Orgs/CSC Site
-------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      24 Mar 2017
@Description:        1704 Release (SFDC 327) - Remove Nexperia sales org. ( MY61, PH62, CN61 & HK91) from SAP CMD Request picklist
-------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      27 Jun 2017
@Description:        1707 Release (SFDC 455) - Generate Tax Classifications for sales org. CN60
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      31 Jul 2017 
@Description:        1708 Release (SFDC 729) - Generate Tax Classifications for MANU/SBE sales orgs.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Anil Somani
@Modified Date:      19 Jan 2018
@Description:        (SFDC 1231) - New Attributes(CN and PH) added on Tax Classification session for sales org NL61. 
                     (SFDC 1235) - US63 - NXP San Jose Changed to US63 - NXP Austin for sales org US63.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 May 2018 
@Description:        1806 Release (SFDC 1713) - Generate Tax Classifications for new MANU sales orgs.
                     
*********************************************************************************************************/

public with sharing class TaxClassificationCMDRequestController 
{
    private static final String SALES_ORG_NL60 = 'NL60 - RSO Europe';
    private static final String SALES_ORG_US60 = 'US60 - RSO U.S.A.';
    private static final String SALES_ORG_CN62 = 'CN62 - MSO China';

    /***1606 Release SIR 915 - START***/
    private static final String SALES_ORG_CN60 = 'CN60 - MSO China CN60';
    private static final String SALES_ORG_JP60 = 'JP60 - MSO Japan';//New Sales Org for FSL Order Miration, added by Scarlett on Mar 08
    private static final String SALES_ORG_US63 = 'US63 - NXP Austin';//New Sales Org for FSL Order Miration, added by Scarlett on May 31 2016
    private static final String SALES_ORG_CN64 = 'CN64 - Tianjin';//New Sales Org for FSL Order Miration, added by Scarlett on May 31 2016
    private static final String SALES_ORG_TH61 = 'TH61 - NXP Thailand';//New Sales Org for FSL Order Miration, added by Scarlett on May 31 2016
    private static final String SALES_ORG_TW61 = 'TW61 - NXP Kaohsiung';//New Sales Org for FSL Order Miration, added by Scarlett on May 31 2016
     /***1606 Release SIR 915 - END***/ 
    private static final String SALES_ORG_AT61 = 'AT61 - SOrg. GRK';
    private static final String SALES_ORG_BE61 = 'BE61 - NXP Semicon. Leuven';
    private static final String SALES_ORG_CN68 = 'CN68 - NXP(China)Management';
    private static final String SALES_ORG_DE42 = 'DE42 - NXP Hamburg Other';
    private static final String SALES_ORG_DE63 = 'DE63 - NXP Semi. Germany';
    private static final String SALES_ORG_EM61 = 'EM61 - NXP GEM';
    private static final String SALES_ORG_FR61 = 'FR61 - NXP Caen';
    private static final String SALES_ORG_IN61 = 'IN61 - NXP India';
    private static final String SALES_ORG_MX61 = 'MX61 - SOrg. Mexico';
    private static final String SALES_ORG_NL40 = 'NL40 - NXP Nijmegen Site Su';
    private static final String SALES_ORG_NL61 = 'NL61 - Nijmegen';
    private static final String SALES_ORG_NL68 = 'NL68 - NXP Software';
    private static final String SALES_ORG_RO61 = 'RO61 - SOrg. Romania';
    // Added as part of SFDC-1713
    private static final String SALES_ORG_CA61 = 'CA61 - SOrg Canada';
    private static final String SALES_ORG_CN6A = 'CN6A - SOrg. Chongqing';
    private static final String SALES_ORG_CN69 = 'CN69 - SOrg. China';
    private static final String SALES_ORG_CZ61 = 'CZ61 - SOrg.Czech Republic';
    private static final String SALES_ORG_GB63 = 'GB63 - NXP Laboratories UK';
    private static final String SALES_ORG_HK63 = 'HK63 - NXP Semi Hong Kong';
    private static final String SALES_ORG_IN62 = 'IN62 - SOrg. Noida';
    private static final String SALES_ORG_IN63 = 'IN63 - SOrg. Hyderabad';
    private static final String SALES_ORG_JP61 = 'JP61 - SOrg. Japan';
    private static final String SALES_ORG_SG60 = 'SG60 - MSO Singapore';

              
            
    public List<Tax_Classification__c> lstTaxClassifications{get; set;}
    public CMD_Request__c objCMDRequest {get; set;}  
  
    public TaxClassificationCMDRequestController(ApexPages.StandardSetController controller) 
    {
        if(ApexPages.currentPage().getParameters()!= null && ApexPages.currentPage().getParameters().get('id')!= null)
        {
            objCMDRequest = [
                Select  Id , 
                        Name , 
                        Sales_Organisation__c, 
                        Global_Customer_ID__c 
                From    CMD_Request__c 
                Where   Id=:ApexPages.currentPage().getParameters().get('id') Limit 1
            ];
            
            //fetch all tax classification data for this Customer
            lstTaxClassifications = [
                Select  Id , 
                        CMD_Request__c , 
                        Country__c, 
                        Tax_Category__c , 
                        Tax_Classification__c
                From    Tax_Classification__c
                Where   CMD_Request__c = :objCMDRequest.Id 
            ];
            
            if(lstTaxClassifications.size() == 0)
            {
                lstTaxClassifications = new List<Tax_Classification__c>();
            
                /***Modified by Scarlett on Mar 08**/
                if(objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_NL60)
                /***Modified by Scarlett on Mar 08 - END**/  
                {
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'AT - Austria', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'AU - Australia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));    
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'BE - Belgium', Tax_Category__c = 'MWST', Tax_Classification__c = '1')); 
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'BR - Brazil', Tax_Category__c = 'MWST', Tax_Classification__c = '1')); 
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CZ - Czech Republic', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c = '1')); 
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'EE - Estonia', Tax_Category__c = 'MWST', Tax_Classification__c = '1')); 
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'ES - Spain', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'FI - Finland', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'FR - France', Tax_Category__c = 'MWST', Tax_Classification__c = '1')); 
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'GB - United Kingdom', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'GB - United Kingdom', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HU - Hungary', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'ID - Indonesia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'IE - Ireland', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'IN - India', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'IT - Italy', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'JP - Japan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'KR - South Korea', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MX - Mexico', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MY - Malaysia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    
                    //Added new country- tax category on Jan 21 2014 by Nisha Agrawal                    
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PL - Polska', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PT - Portugal', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'RO - Rumania', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'SG - Singapore', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'SK - Slovakia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TH - Thailand', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TW - Taiwan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1'));
                    
                    //Added new country on Dec 18 2013 by Nisha Agrawal
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'VN - Vietnam', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));                    
                }
                else if(objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_US60)
                {              
                    /****1606 Release SIR 915 - Removed by Scarlett and apply new Tax Classification       
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'BR - Brazil', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CA - Canada', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MX - Mexico', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    
                    //Added new country- tax category on Jan 21 2014 by Nisha Agrawal
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1'));
                    ****/
/***1606 Release SIR 915***/                    
                    //2016 new Tax Classfication
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'BR - Brazil', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CA - Canada', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MX - Mexico', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MY - Malaysia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TH - Thailand', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TW - Taiwan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1'));
                }
                else if(objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_CN62)
                {                    
                    /****1606 Release SIR 915 - Removed by Scarlett and apply new Tax Classification 
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    
                    //Added new country- tax category on Jan 21 2014 by Nisha Agrawal
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1')); 
                    ****/
/***1606 Release SIR 915***/
                    //2016 New classification                   
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MY - Malaysia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TH - Thailand', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TW - Taiwan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1'));
                }
            
                /***1606 Release SIR 915 - START***/
                //Tax Classification for Sales Org JP60
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_JP60)
                {                    
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'JP - Japan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MY - Malaysia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TH - Thailand', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TW - Taiwan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1'));
                }    
                //Tax Classifcation for Sales Org US 63
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_US63)
                {                  
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'IN - India', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1'));
                }
              
               //Tax Classification for Sales Org CN60
               else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c != '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_CN60)
                {                    
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MY - Malaysia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TH - Thailand', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TW - Taiwan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1'));
                }    
                //Tax Classifcation for Sales Org CN64
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_CN64)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
             
                //Tax Classifcation for Sales Org TH61
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_TH61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TH - Thailand', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                //Tax Classifcation for Sales Org TW61
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_TW61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TW - Taiwan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                /***1606 Release SIR 915 - END***/
                //Tax Classifcation for Sales Org MANU funloc
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_AT61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'AT - Austria', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_BE61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'BE - Belgium', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_CN68)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_DE42 || objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_DE63)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'DE - Germany', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_EM61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'KR - South Korea', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'SG - Singapore', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'TW - Taiwan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_FR61)
                {
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'FR - France', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'GB - United Kingdom', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'GB - United Kingdom', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_IN61)
                 {
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'IN - India', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                 }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_MX61)
                {
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MX - Mexico', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_NL40)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MY - Malaysia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && (objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_NL61 ))
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));      
                }              
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && (objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_NL68))
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));    
                }
                
               
                 else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_RO61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CA - Canada', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CZ - Czech Republic', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'IN - India', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'MX - Mexico', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'RO - Romania', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                 else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_CA61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CA - Canada', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                 else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_CN6A)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                 else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_CN69)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                 else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_CZ61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'CZ - Czech Republic', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                 else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_GB63)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'GB - United Kingdom', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                 else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_HK63)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                 else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_IN62)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'IN - India', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_IN63)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'IN - India', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_JP61)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'JP - Japan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
                else if((objCMDRequest.Sales_Organisation__c != null || objCMDRequest.Sales_Organisation__c == '') && objCMDRequest.Sales_Organisation__c.trim() == SALES_ORG_SG60)
                {     
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'AU - Australia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'NL - Netherlands', Tax_Category__c = 'ZWRC', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'SG - Singapore', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    lstTaxClassifications.add(new Tax_Classification__c(CMD_Request__c = objCMDRequest.Id, Country__c = 'US - USA', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                }
            }
        }
    }
    
    //save button
    public PageReference saveTaxClassification() 
    {
        try 
        {
            upsert lstTaxClassifications;
            PageReference home = new PageReference('/' + objCMDRequest.Id);
            home.setRedirect(true);
            return home;
        } 
        catch (DmlException e) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
    }
}