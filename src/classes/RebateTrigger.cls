/********************************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      04 Dec 2012
@Description:       Class for all Rebate and Rebate Product Trigger Methods
------------------------------------------------------------------------------------
@Modified By : 		Nisha Agrawal
@Modified Date : 	19 Mar 2013
@Description : 		Feature added to update BU on Rebate from Rebate Products
------------------------------------------------------------------------------------
@Modified By : 		Nisha Agrawal
@Modified Date : 	06 Aug 2013
@Description : 		Approval flow changed for Disti Rebates 
					(Seek Regional Controller's approval instead of GSM Controller without any value restriction)
------------------------------------------------------------------------------------
@Modified By : 		Scarlett Kang
@Modified Date : 	11 Nov 2014
@Description : 		Approval flow changed for Segement VP 
					(When Industry Segement = 'Automotive & Transportation' & Sales Channel = 'OEM/EMS', 
					 Regional Sales Manager will be replaced by Segment VP)
------------------------------------------------------------------------------------
@Modified By : 		Scarlett Kang
@Modified Date : 	11 Dec 2014
@Description : 		Add MAG Details (BL Marketing Mgr MAG) for BL Marketing Managers
--------------------------------------------------------------------------------------------------
@Modified By : 		Nisha Agrawal
@Modified Date : 	May 10, 2018
@Description : 		Change in Approval Flow, Populate Regional Channel Controller as per program type and region
*******************************************************************************************************************/

public with sharing class RebateTrigger 
{
    //Added by Nisha Agrawal on May 10,2018 for approval flow change
    public static string ROLE_REGIONAL_CHANNEL_CONTROLLER = 'Regional Channel Controller';
    
	public static void updateRebateCurrency(List<eRebate__c> lstRebates)
	{
		Set<String> currencyCodes = new Set<String>();
		for(eRebate__c objRebate : lstRebates)
		{
        	if (objRebate.CurrencyIsoCode != null) 
        	{
            	currencyCodes.add(objRebate.CurrencyIsoCode);
        	}
    	}
    	
    	if (currencyCodes.size() > 0) 
    	{  
      		Map<String, Id> mapCurrencyCodeToFxRate = new Map<String, Id>();
    
        	for (FX_Rates__c objRate :[Select Id, CurrencyIsoCode From FX_Rates__c where CurrencyIsoCode in :currencyCodes]) 
        	{
            	mapCurrencyCodeToFxRate.put(objRate.CurrencyIsoCode, objRate.Id);
            }
            
            for(eRebate__c objRebate : lstRebates)
	        {
	            if (mapCurrencyCodeToFxRate.containsKey(objRebate.CurrencyIsoCode)) 
	            {
	                objRebate.Rebate_Currency__c = mapCurrencyCodeToFxRate.get(objRebate.CurrencyIsoCode);	            
	        	}
        	}
    	}
	}
		
	public static void populateApprovers(List<eRebate__c> lstRebates)
	{
		//prepare the set of regions		
		Set<String> salesRegions = new Set<String>();		
		for(eRebate__c objRebate : lstRebates)
		{
			salesRegions.add(objRebate.Sales_Region__c);
		}
		
		//get all the approvers from the approval matrix for the region
		List<Rebate_Approver_Matrix__c> lstApprovers = [Select Id , Approver__c , Role__c, Region__c , MAG__c, Program_Type__c
														From Rebate_Approver_Matrix__c
														Where Region__c in : salesRegions and Role__c != 'BL Marketing Manager'
														Order By Role__c];
														
		//prepare maps from list of approvers
		//Role -> (Region -> Approver)
		Map<String, Map<String , Id>> mapRoleToRegionalApprovers = new Map<String , Map<String , Id>>();
        //Added by Nisha Agrawal on May 10,2018 for approval flow change
        Map<String, Map<String, Id>> mapProgramTypeToReginalChannelControllers = new Map<String , Map<String , Id>>();
        
        //Get Segment VP
        List<Rebate_Approver_Matrix__c> lstSegmentVP = [
            SELECT Id, Approver__c, Role__c, Region__c 
            FROM Rebate_Approver_Matrix__c
            WHERE Role__c = 'Segment VP'
        ];
        
        Map<String, Id> mapRegionSegmentVP = new Map<String, Id>();
		
		for(Rebate_Approver_Matrix__c objApprover : lstApprovers)
		{
            //if block- Added by Nisha Agrawal on May 10,2018 for approval flow change
            if(objApprover.Role__c == ROLE_REGIONAL_CHANNEL_CONTROLLER)
            {
                if(mapProgramTypeToReginalChannelControllers.containsKey(objApprover.Program_Type__c))	
                {
                    mapProgramTypeToReginalChannelControllers.get(objApprover.Program_Type__c).put(objApprover.Region__c , objApprover.Approver__c);
                }
                else
                {					
                    mapProgramTypeToReginalChannelControllers.put(objApprover.Program_Type__c , new Map<String , Id> {objApprover.Region__c => objApprover.Approver__c});
                }
            }
            else
            {
            	if(mapRoleToRegionalApprovers.containsKey(objApprover.Role__c))	
                {
                    mapRoleToRegionalApprovers.get(objApprover.Role__c).put(objApprover.Region__c , objApprover.Approver__c);
                }
                else
                {					
                    mapRoleToRegionalApprovers.put(objApprover.Role__c , new Map<String , Id> {objApprover.Region__c => objApprover.Approver__c});
                }    
            }
		}
        
        for(Rebate_Approver_Matrix__c objApprover : lstSegmentVP)
            mapRegionSegmentVP.put(objApprover.Region__c, objApprover.Approver__c);
		
		for(eRebate__c objRebate : lstRebates)
		{			
			if(objRebate.Sales_Region__c != null)
			{
				objRebate.Apttus_Rebate_Checker__c = null;
				objRebate.Legal__c = null;
				objRebate.Corporate_Controller__c = null;
				objRebate.Global_Sales_OPS_Manager__c = null;
				objRebate.Regional_Controller__c = null;
				objRebate.Regional_Channel_Controller__c = null;
				objRebate.Global_Channel_Controller__c = null;
				objRebate.Regional_Disti_Manager__c = null;
				objRebate.Regional_Sales_Manager__c = null;
				objRebate.GSM_Controller__c = null;
								
				//Level 1 - Apttus agreement checker						
				if (objRebate.Apttus_Agreement__c)
				{
					if(mapRoleToRegionalApprovers.containsKey('Apttus Aggrement Checker') && mapRoleToRegionalApprovers.get('Apttus Aggrement Checker').containsKey(objRebate.Sales_Region__c))
					{
						objRebate.Apttus_Rebate_Checker__c = mapRoleToRegionalApprovers.get('Apttus Aggrement Checker').get(objRebate.Sales_Region__c);
						
						//clear all the BL Marketing Manager approvers also
						objRebate.BL_Marketing_Mgr_1__c = null;
						objRebate.BL_Marketing_Mgr_2__c = null;
						objRebate.BL_Marketing_Mgr_3__c = null;
						objRebate.BL_Marketing_Mgr_4__c = null;
						objRebate.BL_Marketing_Mgr_5__c = null;
						objRebate.BL_Marketing_Mgr_6__c = null;
						objRebate.BL_Marketing_Mgr_7__c = null;
						objRebate.BL_Marketing_Mgr_8__c = null;
					}			
				}
				else
				{
					//Level 2 - Legal
					if (objRebate.Red_Flag__c == 'YES')
					{
						if(mapRoleToRegionalApprovers.containsKey('Legal') && mapRoleToRegionalApprovers.get('Legal').containsKey(objRebate.Sales_Region__c))
						{
							objRebate.Legal__c = mapRoleToRegionalApprovers.get('Legal').get(objRebate.Sales_Region__c);
						}	
					}
					
					//Level 3 - Corporate Control
					if(objRebate.Total_Est_Rebate_Amount_USD__c >= 5000000)
					{
						if(mapRoleToRegionalApprovers.containsKey('Corporate Control') && mapRoleToRegionalApprovers.get('Corporate Control').containsKey(objRebate.Sales_Region__c))
						{
							objRebate.Corporate_Controller__c = mapRoleToRegionalApprovers.get('Corporate Control').get(objRebate.Sales_Region__c);
						}
					}
					
					//Level 4 - Global Sales & OPS Manager / Regional Controller
					if(objRebate.Sales_Channel__c != null)
					{
						if(objRebate.Sales_Channel__c == 'Distribution')
						{
							if(mapRoleToRegionalApprovers.containsKey('Global Sales & OPS Manager') && mapRoleToRegionalApprovers.get('Global Sales & OPS Manager').containsKey(objRebate.Sales_Region__c))
							{
								objRebate.Global_Sales_OPS_Manager__c = mapRoleToRegionalApprovers.get('Global Sales & OPS Manager').get(objRebate.Sales_Region__c);
							}
						}
						else if(objRebate.Sales_Channel__c == 'EMS' || objRebate.Sales_Channel__c == 'OEM')
						{
							if(mapRoleToRegionalApprovers.containsKey('Regional Controller') && mapRoleToRegionalApprovers.get('Regional Controller').containsKey(objRebate.Sales_Region__c))
							{
								objRebate.Regional_Controller__c = mapRoleToRegionalApprovers.get('Regional Controller').get(objRebate.Sales_Region__c);
							}	
						}
					}
					
					//Level 5 - Regional Channel Controller
					//code block modified by Nisha Agrawal on May 10, 2018 for approval flow change
					if(mapProgramTypeToReginalChannelControllers.containsKey(objRebate.Programe_Type__c) && mapProgramTypeToReginalChannelControllers.get(objRebate.Programe_Type__c).containsKey(objRebate.Sales_Region__c))
					{
						objRebate.Regional_Channel_Controller__c = mapProgramTypeToReginalChannelControllers.get(objRebate.Programe_Type__c).get(objRebate.Sales_Region__c);
					}
					
					//Level 6 - Global Channel Controller
					if(mapRoleToRegionalApprovers.containsKey('Global Channel Controller') && mapRoleToRegionalApprovers.get('Global Channel Controller').containsKey(objRebate.Sales_Region__c))
					{
						objRebate.Global_Channel_Controller__c = mapRoleToRegionalApprovers.get('Global Channel Controller').get(objRebate.Sales_Region__c);
					}
					
					//Level 7 - BL Marketing Managers - Handled separately
					
					//Level 8 -	Regional Disti Manager / Regional Sales Manager
					if(objRebate.Sales_Channel__c != null)
					{
						if(objRebate.Sales_Channel__c == 'Distribution')
						{
							if(mapRoleToRegionalApprovers.containsKey('Regional Disti Manager') && mapRoleToRegionalApprovers.get('Regional Disti Manager').containsKey(objRebate.Sales_Region__c))
							{
								objRebate.Regional_Disti_Manager__c = mapRoleToRegionalApprovers.get('Regional Disti Manager').get(objRebate.Sales_Region__c);
							}
						}
						else if(objRebate.Sales_Channel__c == 'EMS' || objRebate.Sales_Channel__c == 'OEM')
						{
                            if(objRebate.Industry_Segment__c == 'Automotive & Transportation'){
                                objRebate.Regional_Sales_Manager__c = mapRegionSegmentVP.get('Global');
                            }
							else if(mapRoleToRegionalApprovers.containsKey('Regional Sales Manager') && mapRoleToRegionalApprovers.get('Regional Sales Manager').containsKey(objRebate.Sales_Region__c))
							{
								objRebate.Regional_Sales_Manager__c = mapRoleToRegionalApprovers.get('Regional Sales Manager').get(objRebate.Sales_Region__c);
							}	
						}
					}
					
					//Level 9 - Regional Controller / GSM Controller
					if(objRebate.Sales_Channel__c != null)
					{
						if(objRebate.Sales_Channel__c == 'Distribution')
						{
							if(mapRoleToRegionalApprovers.containsKey('Regional Controller') && mapRoleToRegionalApprovers.get('Regional Controller').containsKey(objRebate.Sales_Region__c))
							{
								objRebate.Regional_Controller__c = mapRoleToRegionalApprovers.get('Regional Controller').get(objRebate.Sales_Region__c);
							}
						}
						else if(objRebate.Sales_Channel__c == 'EMS' || objRebate.Sales_Channel__c == 'OEM')
						{
							if(objRebate.Capped_Payout_USD__c >= 100000)
							{
								if(mapRoleToRegionalApprovers.containsKey('GSM Controller') && mapRoleToRegionalApprovers.get('GSM Controller').containsKey(objRebate.Sales_Region__c))
								{
									objRebate.GSM_Controller__c = mapRoleToRegionalApprovers.get('GSM Controller').get(objRebate.Sales_Region__c);
								}
							}
						}
					}
				}				
			}
			else
			{
				objRebate.addError('Could not update approvers. Please select a Sales Region first.');					
			}			
		}		
	}
		
	public static void populateBLMarketingApproversFromRebate(List<eRebate__c> lstNewRebates, Map<Id, eRebate__c> mapOldRebates  )
	{
		if(mapOldRebates != null && lstNewRebates != null && mapOldRebates.size() > 0 && lstNewRebates.size() > 0)
		{
			//check for the Rebates where Apttus_Agreement__c updated from true to false
			eRebate__c oldRebate;
			List<eRebate__c> lstAffectedRebates = new List<eRebate__c>(); 
			
			for(eRebate__c objRebate : lstNewRebates)
			{
				oldRebate = mapOldRebates.get(objRebate.Id);
				if(oldRebate.Apttus_Agreement__c != objRebate.Apttus_Agreement__c && oldRebate.Apttus_Agreement__c == true && objRebate.Apttus_Agreement__c == false)
				{
					lstAffectedRebates.add(objRebate);
				}
			}
			
			if(lstAffectedRebates.size() > 0)
			{
				//fetch all the MAGS for affected rebates and prepare the map 
				Map<Id , Set<String>> mapRebateToMAG = new Map<Id, Set<String>>();
				Set<String> magsSet = new Set<String>();
				
				for(List<eRebate_Product__c> lstLines : [Select Id , MAG__c , eRebate__c From eRebate_Product__c Where eRebate__c in :lstAffectedRebates Order By eRebate__c])
				{
					for(eRebate_Product__c objLine : lstLines)
					{
						if(objLine.MAG__c != null)
						{
							if(mapRebateToMAG.containsKey(objLine.eRebate__c))
							{
								mapRebateToMAG.get(objLine.eRebate__c).add(objLine.MAG__c);
							}
							else
							{
								mapRebateToMAG.put(objLine.eRebate__c , new Set<String>{objLine.MAG__c} );
							}
							
							magsSet.add(objLine.MAG__c);
						}
					}
				}
				
				if(magsSet.size () > 0)
				{
					//get all the approvers from the approval matrix for the MAGs
					List<Rebate_Approver_Matrix__c> lstApprovers = [Select Id , Approver__c , Region__c , MAG__c
																	From Rebate_Approver_Matrix__c
																	Where MAG__c in : magsSet and Role__c = 'BL Marketing Manager'];
					
					//MAG -> (Region -> Approver)
					Map<String, Map<String , Id>> mapMAGToRegionalApprovers = new Map<String , Map<String , Id>>();
					
					//prepare the approver map from the list
					for(Rebate_Approver_Matrix__c objApprover : lstApprovers)
					{
						if(objApprover.MAG__c != null)
						{
							if(mapMAGToRegionalApprovers.containsKey(objApprover.MAG__c))	
							{
								mapMAGToRegionalApprovers.get(objApprover.MAG__c).put(objApprover.Region__c , objApprover.Approver__c);
							}
							else
							{					
								mapMAGToRegionalApprovers.put(objApprover.MAG__c , new Map<String , Id> {objApprover.Region__c => objApprover.Approver__c});
							}
						}			
					}
					
                    //Scarlett
                    Map<String, String> mapApproverToMAG = new Map<String, String>();
                    
					for(eRebate__c objRebate : lstAffectedRebates)
					{
						//clear all the approvers first
						objRebate.BL_Marketing_Mgr_1__c = null;
						objRebate.BL_Marketing_Mgr_2__c = null;
						objRebate.BL_Marketing_Mgr_3__c = null;
						objRebate.BL_Marketing_Mgr_4__c = null;
						objRebate.BL_Marketing_Mgr_5__c = null;
						objRebate.BL_Marketing_Mgr_6__c = null;
						objRebate.BL_Marketing_Mgr_7__c = null;
						objRebate.BL_Marketing_Mgr_8__c = null;
                        //Scarlett
                        objRebate.BL_Marketing_Mgr_1_MAG__c = null;
                        objRebate.BL_Marketing_Mgr_2_MAG__c = null;
                        objRebate.BL_Marketing_Mgr_3_MAG__c = null;
                        objRebate.BL_Marketing_Mgr_4_MAG__c = null;
                        objRebate.BL_Marketing_Mgr_5_MAG__c = null;
                        objRebate.BL_Marketing_Mgr_6_MAG__c = null;
                        objRebate.BL_Marketing_Mgr_7_MAG__c = null;
                        objRebate.BL_Marketing_Mgr_8_MAG__c = null;
						
						if(objRebate.Sales_Region__c != null)
						{
							//prepare the list of approvers
							//List<Id> lstApproverIds = new List<Id>();
							Set<Id> magApprovers = new Set<Id>();
							
							for(String strMAG : mapRebateToMAG.get(objRebate.Id))
							{
								if(mapMAGToRegionalApprovers.containsKey(strMAG) && mapMAGToRegionalApprovers.get(strMAG).containsKey(objRebate.Sales_Region__c))
								{
									magApprovers.add(mapMAGToRegionalApprovers.get(strMAG).get(objRebate.Sales_Region__c));
                                    //Scarlett
                                    mapApproverToMAG.put(mapMAGToRegionalApprovers.get(strMAG).get(objRebate.Sales_Region__c), strMAG);
								}
							}
							
							//populate all the approvers
							//for (integer i=0; i< lstApproverIds.size(); i++)
							integer i=0;
							for (Id approverId : magApprovers)
							{
								if(i == 0)
								{
									objRebate.BL_Marketing_Mgr_1__c = approverId;
                                    objRebate.BL_Marketing_Mgr_1_MAG__c = mapApproverToMAG.get(approverId);
		                        }
		                        else if(i == 1) 
		                        {
									objRebate.BL_Marketing_Mgr_2__c = approverId;
                                    objRebate.BL_Marketing_Mgr_2_MAG__c = mapApproverToMAG.get(approverId);
		                        } 
		                        else if(i == 2) 
		                        {
		                            objRebate.BL_Marketing_Mgr_3__c = approverId;
                                    objRebate.BL_Marketing_Mgr_3_MAG__c = mapApproverToMAG.get(approverId);
		                        } 
		                        else if(i == 3) 
		                        {
		                            objRebate.BL_Marketing_Mgr_4__c = approverId;
                                    objRebate.BL_Marketing_Mgr_4_MAG__c = mapApproverToMAG.get(approverId);
		                        } 
		                        else if(i == 4) 
		                        {
		                            objRebate.BL_Marketing_Mgr_5__c = approverId;
                                    objRebate.BL_Marketing_Mgr_5_MAG__c = mapApproverToMAG.get(approverId);
		                        } 
		                        else if(i == 5) 
		                        {
		                            objRebate.BL_Marketing_Mgr_6__c = approverId;
                                    objRebate.BL_Marketing_Mgr_6_MAG__c = mapApproverToMAG.get(approverId);
		                        }
		                        else if(i == 6) 
		                        {
		                            objRebate.BL_Marketing_Mgr_7__c = approverId;
                                    objRebate.BL_Marketing_Mgr_7_MAG__c = mapApproverToMAG.get(approverId);
		                        }
		                        else if(i == 7)
		                        {
		                            objRebate.BL_Marketing_Mgr_8__c = approverId;
                                    objRebate.BL_Marketing_Mgr_8_MAG__c = mapApproverToMAG.get(approverId);
		                        }
		                        
		                        i++;
							}					
						}
						else
						{
							objRebate.addError('Could not update approvers. Please select a Sales Region first.');
						}
					}
				}
			}
		}		
	}
	
	public static void populateMarketingManagersAndBU(List<eRebate_Product__c> lstRebateProducts)
	{
		if(lstRebateProducts != null && lstRebateProducts.size() > 0)
		{
			//prepare set of Rebate Ids
			Set<Id> rebateIds = new Set<Id>();
			
			for(eRebate_Product__c objLine :  lstRebateProducts)
			{
				rebateIds.add(objLine.eRebate__c);
			}
			
			if(rebateIds.size() > 0)
			{
				//fetch all the MAGS and BUs for affected rebates and prepare the map 
				Set<String> magsSet = new Set<String>();
				
				Map<Id , Set<String>> mapRebateToMAG = new Map<Id, Set<String>>();
				Map<Id, Set<String>> mapRebateToBU = new Map<Id, Set<String>>();
				
				for(List<eRebate_Product__c> lstLines : [Select Id , MAG__c , BU__c, eRebate__c From eRebate_Product__c Where eRebate__c in :rebateIds Order By eRebate__c])
				{
					for(eRebate_Product__c objLine : lstLines)
					{
						if(objLine.MAG__c != null)
						{
							if(mapRebateToMAG.containsKey(objLine.eRebate__c))
							{
								mapRebateToMAG.get(objLine.eRebate__c).add(objLine.MAG__c);
							}
							else
							{
								mapRebateToMAG.put(objLine.eRebate__c , new Set<String>{objLine.MAG__c} );
							}
							magsSet.add(objLine.MAG__c);
						}
						
						if(objLine.BU__c != null)
						{
							if(mapRebateToBU.containsKey(objLine.eRebate__c))
							{
								mapRebateToBU.get(objLine.eRebate__c).add(objLine.BU__c);
							}
							else
							{
								mapRebateToBU.put(objLine.eRebate__c , new Set<String>{objLine.BU__c} );
							}
						}
					}
				}
			
				//fetch MAG Approvers
				Map<String, Map<String , Id>> mapMAGToRegionalApprovers = fetchMAGApprovers(magsSet);				
				
				//fetch all the affected Rebates
				List<eRebate__c> lstRebates = [Select Id, BU__c , Sales_Region__c, Apttus_Agreement__c ,  BL_Marketing_Mgr_1__c ,  BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c , BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
												From eRebate__c 
												Where Id = :rebateIds];
                
                //Scarlett
                Map<String, String> mapApproverToMAG = new Map<String, String>();
												
				for(eRebate__c objRebate : lstRebates)
				{
					//clear the BU
					objRebate.BU__c = null;
					
					//assign BUs					
					if(mapRebateToBU.containsKey(objRebate.Id))
					{
						String strBUs = '';
						for(String bu :  mapRebateToBU.get(objRebate.Id))
						{
							strBUs = strBUs + (strBUs != '' ? '|' : '') + bu; 
						}
						objRebate.BU__c = strBUs;	
					}
					
					/************************ Assign MAG Approvers ******************************/
					
					//clear all the approvers first
					objRebate.BL_Marketing_Mgr_1__c = null;
					objRebate.BL_Marketing_Mgr_2__c = null;
					objRebate.BL_Marketing_Mgr_3__c = null;
					objRebate.BL_Marketing_Mgr_4__c = null;
					objRebate.BL_Marketing_Mgr_5__c = null;
					objRebate.BL_Marketing_Mgr_6__c = null;
					objRebate.BL_Marketing_Mgr_7__c = null;
					objRebate.BL_Marketing_Mgr_8__c = null;
                    //Scarlett
                    objRebate.BL_Marketing_Mgr_1_MAG__c = null;
                    objRebate.BL_Marketing_Mgr_2_MAG__c = null;
                    objRebate.BL_Marketing_Mgr_3_MAG__c = null;
                    objRebate.BL_Marketing_Mgr_4_MAG__c = null;
                    objRebate.BL_Marketing_Mgr_5_MAG__c = null;
                    objRebate.BL_Marketing_Mgr_6_MAG__c = null;
                    objRebate.BL_Marketing_Mgr_7_MAG__c = null;
                    objRebate.BL_Marketing_Mgr_8_MAG__c = null;
					
					if((!objRebate.Apttus_Agreement__c) && objRebate.Sales_Region__c != null)
					{
						//prepare the list of approvers
						//List<Id> lstApproverIds = new List<Id>();
						
						Set<Id> magApprovers = new Set<Id>();
						
						if(mapRebateToMAG.containsKey(objRebate.Id))
						{
							for(String strMAG : mapRebateToMAG.get(objRebate.Id))
							{
								if(mapMAGToRegionalApprovers.containsKey(strMAG) && mapMAGToRegionalApprovers.get(strMAG).containsKey(objRebate.Sales_Region__c))
								{
									magApprovers.add(mapMAGToRegionalApprovers.get(strMAG).get(objRebate.Sales_Region__c));
                                    mapApproverToMAG.put(mapMAGToRegionalApprovers.get(strMAG).get(objRebate.Sales_Region__c), strMAG);
								}
							}
							
							//populate all the approvers
							//for (integer i=0; i< lstApproverIds.size(); i++)
							integer i=0;
							for (Id approverId : magApprovers)							
							{
								if(i == 0)
								{
									objRebate.BL_Marketing_Mgr_1__c = approverId;
                                    objRebate.BL_Marketing_Mgr_1_MAG__c = mapApproverToMAG.get(approverId);
		                        }
		                        else if(i == 1) 
		                        {
									objRebate.BL_Marketing_Mgr_2__c = approverId;
                                    objRebate.BL_Marketing_Mgr_2_MAG__c = mapApproverToMAG.get(approverId);
		                        } 
		                        else if(i == 2) 
		                        {
		                            objRebate.BL_Marketing_Mgr_3__c = approverId;
                                    objRebate.BL_Marketing_Mgr_3_MAG__c = mapApproverToMAG.get(approverId);
		                        } 
		                        else if(i == 3) 
		                        {
		                            objRebate.BL_Marketing_Mgr_4__c = approverId;
                                    objRebate.BL_Marketing_Mgr_4_MAG__c = mapApproverToMAG.get(approverId);
		                        } 
		                        else if(i == 4) 
		                        {
		                            objRebate.BL_Marketing_Mgr_5__c = approverId;
                                    objRebate.BL_Marketing_Mgr_5_MAG__c = mapApproverToMAG.get(approverId);
		                        } 
		                        else if(i == 5) 
		                        {
		                            objRebate.BL_Marketing_Mgr_6__c = approverId;
                                    objRebate.BL_Marketing_Mgr_6_MAG__c = mapApproverToMAG.get(approverId);
		                        }
		                        else if(i == 6) 
		                        {
		                            objRebate.BL_Marketing_Mgr_7__c = approverId;
                                    objRebate.BL_Marketing_Mgr_7_MAG__c = mapApproverToMAG.get(approverId);
		                        }
		                        else if(i == 7)
		                        {
		                            objRebate.BL_Marketing_Mgr_8__c = approverId;
                                    objRebate.BL_Marketing_Mgr_8_MAG__c = mapApproverToMAG.get(approverId);
		                        }
		                        
		                        i++;
							}
						}					
					}
				}
				
				if(lstRebates.size() > 0)
				{
					update lstRebates;
				}									
			}			
		}
	}

	private static Map<String, Map<String , Id>> fetchMAGApprovers(Set<String> magsSet)
	{
		//MAG -> (Region -> Approver)
		Map<String, Map<String , Id>> mapMAGToRegionalApprovers = new Map<String , Map<String , Id>>();
		
		if(magsSet != null && magsSet.size() > 0)
		{
			//get all the approvers from the approval matrix for the MAGs
			List<Rebate_Approver_Matrix__c> lstApprovers = [Select Id , Approver__c , Region__c , MAG__c
															From Rebate_Approver_Matrix__c
															Where MAG__c in : magsSet and Role__c = 'BL Marketing Manager'];
			
			//prepare the approver map from the list
			for(Rebate_Approver_Matrix__c objApprover : lstApprovers)
			{
				if(objApprover.MAG__c != null)
				{
					if(mapMAGToRegionalApprovers.containsKey(objApprover.MAG__c))	
					{
						mapMAGToRegionalApprovers.get(objApprover.MAG__c).put(objApprover.Region__c , objApprover.Approver__c);
					}
					else
					{					
						mapMAGToRegionalApprovers.put(objApprover.MAG__c , new Map<String , Id> {objApprover.Region__c => objApprover.Approver__c});
					}
				}			
			}	
		}				
		return mapMAGToRegionalApprovers;
	}
		
	public static void populateCorpControllerApprovers(List<eRebate_Product__c> lstNewProducts, Map<Id, eRebate_Product__c> mapOldProducts)
	{
		if(lstNewProducts != null && mapOldProducts != null && lstNewProducts.size() > 0 && mapOldProducts.size() > 0)
		{
			//prepare set of Rebate Ids
			Set<Id> rebateIds = new Set<Id>();
			eRebate_Product__c oldLine;
			
			for(eRebate_Product__c objLine : lstNewProducts)
			{
				oldLine = mapOldProducts.get(objLine.Id);
				if((oldLine.Quantity__c != objLine.Quantity__c) || (oldLine.Price_Gap__c != objLine.Price_Gap__c))
				{
					rebateIds.add(objLine.eRebate__c);
				}
			}
			
			if(rebateIds.size() > 0)
			{
				//get all the approvers from the approval matrix for the MAGs
				List<Rebate_Approver_Matrix__c> lstApprovers = [Select Id , Approver__c , Region__c 
																From Rebate_Approver_Matrix__c
																Where Role__c = 'Corporate Control'];
				
				//Region -> Approver
				Map<String, Id> mapRegionToApprovers = new Map<String , Id>();
				
				//prepare the approver map from the list
				for(Rebate_Approver_Matrix__c objApprover : lstApprovers)
				{
					if(!mapRegionToApprovers.containsKey(objApprover.Region__c))	
					{
						mapRegionToApprovers.put(objApprover.Region__c , objApprover.Approver__c);
					}			
				}
				
				List<eRebate__c> lstAffectedRebates = new List<eRebate__c>();
				 
				//fetch all the affected Rebates
				for(List<eRebate__c> lstRebates : [Select Id, Sales_Region__c, Apttus_Agreement__c ,  Corporate_Controller__c, Total_Est_Rebate_Amount_USD__c
													From eRebate__c 
													Where Id = :rebateIds])
				{
					for(eRebate__c objRebate : lstRebates)
					{
						if( !objRebate.Apttus_Agreement__c && objRebate.Total_Est_Rebate_Amount_USD__c >= 5000000)
						{
							objRebate.Corporate_Controller__c = mapRegionToApprovers.get(objRebate.Sales_Region__c);
							lstAffectedRebates.add(objRebate);
						}
					}	
				}				
							
				if(lstAffectedRebates.size() > 0)
				{
					update lstAffectedRebates;
				}	
			}
		}
	}
}