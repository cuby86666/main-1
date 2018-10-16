/*****************************************************************************************
@Created By :   Ranganath C N
@Created Date:  20 aug 2018
@Description:    To display Survey_answres update in case object feed as a part of SFDC-1967.
*******************************************************************************************/
trigger surveyfeedcase on Survey_Answer__c (before update) {

    
    List<Survey_Answer__c> surveyanswer = new List<Survey_Answer__c>();
    List<Survey_Answer__c > S = TRIGGER.NEW;
    map<id,Survey_Answer__c> Sa = TRIGGER.oldmap;
    surveyfeedcaseclass.casefeed(S,Sa);
    
        
     }