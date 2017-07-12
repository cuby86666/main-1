Trigger ReportUpdate on Account (before insert,before update) {
    Integer SucInitial=5;
    Integer SucDiscovery=4;
    Integer SucAssessment=3;
    Integer SucRecommendation=2;
    Integer SucDecision=1;

    List<RecordType> rtypes = [Select Name, Id From RecordType 
                  where sObjectType='Account' and isActive=true];
     
     //Create a map between the Record Type Name and Id for easy retrieval
     Map<String,String> accountRecordTypes = new Map<String,String>{};
     for(RecordType rt: rtypes)
        accountRecordTypes.put(rt.Name,rt.Id);

    for(Account ac:trigger.new){
        if(ac.RecordTypeId !=Null && ac.RecordTypeId==accountRecordTypes.get('Parent Account')){
        
            System.debug('@@@@@'+ac.Init_Comm_Prob__c);
        
            Decimal a= (ac.Init_Comm_Prob__c != null?ac.Init_Comm_Prob__c:0);
            Decimal b= (ac.Init_Lost_Prob__c != null?ac.Init_Lost_Prob__c:0);
            Decimal c= (ac.Disc_Comm_Prob__c != null?ac.Disc_Comm_Prob__c:0);
            Decimal d= (ac.Disc_Lost_Prob__c != null?ac.Disc_Lost_Prob__c:0);
            Decimal e= (ac.Asse_Comm_Prob__c != null?ac.Asse_Comm_Prob__c:0);
            Decimal f= (ac.Asse_Lost_Prob__c != null?ac.Asse_Lost_Prob__c:0);
            Decimal g= (ac.Reco_Comm_Prob__c != null?ac.Reco_Comm_Prob__c:0);
            Decimal h= (ac.Reco_Lost_Prob__c != null?ac.Reco_Lost_Prob__c:0);
            Decimal i= (ac.Deci_Comm_Prob__c != null?ac.Deci_Comm_Prob__c:0);
            Decimal j= (ac.Deci_Lost_Prob__c != null?ac.Deci_Lost_Prob__c:0);
           
            Decimal TotalInitial        =a+b;
            Decimal TotalDiscovery      =c+d;
            Decimal TotalAssessment     =e+f;
            Decimal TotalRecommendation =g+h;
            Decimal TotalDecision       =i+j;
        
            Decimal  Lpsinitial=b/SucInitial;
            Decimal  LpsDiscovery=d/SucDiscovery;
            Decimal  LpsAssessment=f/SucAssessment;
            Decimal  LpsRecommendation=h/SucRecommendation;
            Decimal  LpsDecision=j/SucDecision;
            
            Decimal IcommstageInitial = TotalInitial;
            Decimal IcommstageDiscovery = IcommstageInitial-Lpsinitial;
            Decimal IcommstageAssessment = IcommstageDiscovery-Lpsinitial;
            Decimal IcommstageRecommendation  = IcommstageAssessment -Lpsinitial;
            Decimal IcommstageDecision = IcommstageRecommendation-Lpsinitial;
            Integer IcommstageFinal = Math.round(IcommstageDecision-Lpsinitial);
            
            Decimal DCommStageDiscovery = TotalDiscovery;
            Decimal DCommStageAssessment = DCommStageDiscovery - LpsDiscovery;
            Decimal DCommStageRecommendation = DCommStageAssessment - LpsDiscovery;
            Decimal DCommStageDecision = DCommStageRecommendation - LpsDiscovery;
            Integer DCommStageFinal = Math.round(DCommStageDecision - LpsDiscovery);
        
            Decimal ACommStageAssessment = TotalAssessment;
            Decimal ACommStageRecommendation = ACommStageAssessment - LpsAssessment;
            Decimal ACommStageDecision = ACommStageRecommendation - LpsAssessment;
            Integer ACommStageFinal = Math.round(ACommStageDecision - LpsAssessment);
            
            Decimal RCommStageRecommendation = TotalRecommendation;
            Decimal RCommStageDecision = RCommStageRecommendation - LpsRecommendation;
            Integer RCommStageFinal = Math.round(RCommStageDecision - LpsRecommendation);
            
            Decimal DECommStageDecision = TotalDecision;
            Integer DEommStageFinal = Math.round(DECommStageDecision - LpsDecision);
        
            Integer IcommprevstageInitial = IcommstageFinal;
            Integer IcommprevstageDiscovery=(IcommprevstageInitial+DCommStageFinal);
            Integer IcommprevstageAssessment=(IcommprevstageDiscovery+ACommStageFinal);
            Integer IcommprevstageRecommendation=(IcommprevstageAssessment+RCommStageFinal);
            Integer IcommprevstageDecision=(IcommprevstageRecommendation+DEommStageFinal);
            
            
            Integer totalInStageInitial = Math.round(IcommstageInitial);
            Integer totalInStageDiscovery = Math.round(IcommstageDiscovery + DCommStageDiscovery);
            Integer totalInStageAssessment = Math.round(IcommstageAssessment + DCommStageAssessment + ACommStageAssessment);
            Integer totalInStageRecommendation = Math.round(IcommstageRecommendation+DCommStageRecommendation+ACommStageRecommendation+RCommStageRecommendation);
            Integer totalInStageDecision = Math.round(IcommstageDecision+DCommStageDecision+ACommStageDecision+RCommStageDecision+DECommStageDecision);
        
            
            
            ac.PROBABILITY_Inital__c=((decimal)IcommprevstageInitial /(totalInStageInitial>0?totalInStageInitial:1))*100;
            ac.PROBABILITY_Discovery__c=((decimal)IcommprevstageDiscovery/(totalInStageDiscovery>0?totalInStageDiscovery:1))*100;
            ac.PROBABILITY_Assessment__c=((decimal)IcommprevstageAssessment/(totalInStageAssessment>0?totalInStageAssessment:1))*100;
            ac.PROBABILITY_Recommendation__c=((decimal)IcommprevstageRecommendation/(totalInStageRecommendation>0?totalInStageRecommendation:1))*100;
            ac.PROBABILITY_Decision__c=((decimal)IcommprevstageDecision/(totalInStageDecision>0?totalInStageDecision:1))*100;
        
        }  
    }
}