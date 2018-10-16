/***************************************************************************************************
@Modified By :      Gunjan Singh
@Modified Date:     11 Sep 2018
@Description:       SFDC-2078 Web-to-Case form without Login - Enhancement (Creating contact along with case)
                    Created method createContact to create Contact, along with Case if contact doesnot exist 
**********************************************************************************************************/

trigger CaseMasterTrigger on Case (before insert,before update,after insert,after update) 
{

         if(Trigger.isInsert)
         {
            if(Trigger.isBefore)
            {
            
                 /**Calling Method to populate the Product Values based on the Product Type Number to Case**/
                 CaseTrigger.populateProductValuesToCase(Trigger.New);
                 
                
                
                 /**Calling Method to asssign the Case Owner and Account to Case**/
                 CaseTrigger.newProcessCasesToAssignOwnerAndAccount(Trigger.New);
                 
                 /**Calling Method to assign case owner & case assigned to based on related entitlement**/
                 CaseTrigger.CasesOwnerAssignment(Trigger.New);
                 
                 /**Calling Method to verify email to case contact**/
                 CaseTrigger.emailToCaseContactCheck(Trigger.New);
                 
                 /**Calling Method to fetch Contact info **/
                 CaseTrigger.fetchContactInfo(Trigger.New);
                 
                 /**Calling Method that determines/Verifies Entitlement Pattern**/
                 CaseTrigger.EntitlementIdentificationForCases(Trigger.New,Trigger.NewMap,Trigger.Old,Trigger.OldMap);
                 
                 /**Calling set of Methods that perform Service level calculations**/
                 caseTrigger.PSLIdentification(Trigger.New);
                 caseTrigger.projectServiceLevelIdentification(Trigger.New);
                 caseTrigger.caseServiceLevelIdentification(Trigger.New);
                 caseTrigger.casePriority(Trigger.New); 
                 
                 /**Calling method to calculate Due date on Case Insert**/
                 caseTrigger.dueDateInsert(Trigger.New);
                 
                 /**Calling  Method to convert country value to USA if coming from Web form **/
                 caseTrigger.convertCountryValuetoUSA(Trigger.New);
                 
                 /**Calling Method to update certain case fields befor Inserting **/
                 caseTrigger.updateCaseFieldsonInsert(Trigger.New);
                
                 /**Calling a routine related to 7summits code **/
                 MappingCaseRouting objMCR = new MappingCaseRouting();
                 objMCR.onBeforeInsert(Trigger.new); 
                 
                 //Created as part of SFDC-2078
                 /**Calling method createContact to create Contact, along with Case if contact doesnot exist  **/
                 caseTrigger.createContact(Trigger.New);
            }
            
            else if(Trigger.isAfter)
            {
                 /**Calling method to assign gsas cases***/
                 CaseTrigger.assignGsasCases(Trigger.New);
                 
                 /**Calling method to set autorepsonseEmail= true for Cases with Record Type 'TS_Webmaster' & 'TS_Community'**/
                 CaseTrigger.setAutoResponseEmail(Trigger.New);
                 
                 /**Calling method to delete cases with origin ="Unkown Contact" **/
                 CaseTrigger.deleteCaseWithUnkownContact(Trigger.New); 
                 
                 /**Calling a routine related to 7summits code **/
                 MappingCaseRouting objMCR = new MappingCaseRouting();
                 objMCR.onAfterInsert(Trigger.new); 
                 
                 
                
            
            
            }
         
         
         
         
         }
         
         else if(Trigger.isUpdate)
         {
             
             if(Trigger.isBefore)
            {
            
                       /**Calling Method to fetch Contact info **/
                       CaseTrigger.fetchContactInfo(Trigger.New);
                       
                       /**Calling Method to update Case Fields like MAG,BU,BL from Related Product Information**/
                       CaseTrigger.updateCaseFieldsWithProductInfo(Trigger.New,Trigger.NewMap,Trigger.OldMap);
                       
                       /**Calling  Method Method that determines/Verifies Entitlement Pattern**/
                       CaseTrigger.EntitlementIdentificationForCases(Trigger.New,Trigger.NewMap,Trigger.Old,Trigger.OldMap);
                       
                        /**Calling set of Methods that perform Service level calculations**/
                         caseTrigger.PSLIdentification(Trigger.New);
                         caseTrigger.projectServiceLevelIdentification(Trigger.New);
                         caseTrigger.caseServiceLevelIdentification(Trigger.New);
                         caseTrigger.casePriority(Trigger.New); 
                         
                      /**Calling Method that calculates case due date on update **/
                      caseTrigger.CalculateDueDate(Trigger.New,Trigger.oldMap);
            
            }
            
            else if(Trigger.isAfter)
            {
            
                     /**Calling  Method to populate the Product Values based on the Product Type Number to Case **/
                     caseTrigger.EntitlementUpdate(Trigger.New,Trigger.Old);
            
            }
         
         
         }




}