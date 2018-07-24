global class OpportunityApproverPlugin implements Process.Plugin {
    @TestVisible
    private static final Map<ApproverLabel, String> APPROVER_LABELS = new Map<ApproverLabel, String>();
        
    static {
        APPROVER_LABELS.put(ApproverLabel.SALES_DIRECTOR_APPROVER, Opportunity.Sales_Director_Approver__c.getDescribe().getLabel());    
        APPROVER_LABELS.put(ApproverLabel.REGIONAL_VP_APPROVER, Opportunity.Regional_VP_Approver__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.VP_APPROVER_2, Opportunity.VP_Approver_2__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.GLOBAL_KEY_ACCOUNT_MANAGER, Opportunity.Global_Key_Account_Manager__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_1, Opportunity.MAG_Approver_1__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_2, Opportunity.MAG_Approver_2__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_3, Opportunity.MAG_Approver_3__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_4, Opportunity.MAG_Approver_4__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_5, Opportunity.MAG_Approver_5__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_6, Opportunity.MAG_Approver_6__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_7, Opportunity.MAG_Approver_7__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_8, Opportunity.MAG_Approver_8__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_9, Opportunity.MAG_Approver_9__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_10, Opportunity.MAG_Approver_10__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_1, Opportunity.BL_Approver_1__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_2, Opportunity.BL_Approver_2__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_3, Opportunity.BL_Approver_3__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_4, Opportunity.BL_Approver_4__c.getDescribe().getLabel());
        APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_5, Opportunity.BL_Approver_5__c.getDescribe().getLabel());
    }

    @TestVisible
    enum ApproverLabel {SALES_DIRECTOR_APPROVER,
                        REGIONAL_VP_APPROVER, VP_APPROVER_2, 
                        MAG_APPROVER_1, MAG_APPROVER_2, MAG_APPROVER_3, MAG_APPROVER_4, MAG_APPROVER_5, 
                        MAG_APPROVER_6, MAG_APPROVER_7, MAG_APPROVER_8, MAG_APPROVER_9, MAG_APPROVER_10,
                        BL_APPROVER_1, BL_APPROVER_2, BL_APPROVER_3, BL_APPROVER_4, BL_APPROVER_5, GLOBAL_KEY_ACCOUNT_MANAGER}
    
    global Process.PluginResult invoke(Process.PluginRequest request) {
        String opptyId = (String) request.inputParameters.get('Id');
        Map<String,String> result = new Map<String,String>();
        try
        {
            List<OpportunityService.DesignWinApprover> allApprovers = OpportunityService.getDesignWinApprovers(new Set<Id>{opptyId}).get(opptyId);
            
            for(OpportunityService.DesignWinApprover dwa : allApprovers)
            {
                result.put(dwa.label, dwa.name);
                System.debug('@@@' + dwa.label + ',' + dwa.name);
            }
            
            result.put('Message', 'Success');
        } catch (Exception err)
        {
            System.debug('@@@' + err.getMessage());
            System.debug('@@@' + err.getStackTraceString());
          //  result.put('Message', 'EXCEPTION: ' + err.getMessage()); //commented as part of SFDC-1754
        }
        return new Process.PluginResult(result);
    }
    
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'Look Up Approver Name';
        result.Tag = 'Approver';
        result.inputParameters = new
        List<Process.PluginDescribeResult.InputParameter> {
            new Process.PluginDescribeResult.InputParameter('Id',
            Process.PluginDescribeResult.ParameterType.STRING, true)
            };

        result.outputParameters = new
        List<Process.PluginDescribeResult.OutputParameter> {
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.SALES_DIRECTOR_APPROVER),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.REGIONAL_VP_APPROVER), 
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.VP_APPROVER_2),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.GLOBAL_KEY_ACCOUNT_MANAGER),
                Process.PluginDescribeResult.ParameterType.STRING),    
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_1),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_2),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_3),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_4),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_5),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_6),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_7),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_8),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_9),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.MAG_APPROVER_10),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.BL_APPROVER_1),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.BL_APPROVER_2),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.BL_APPROVER_3),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.BL_APPROVER_4),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter(APPROVER_LABELS.get(ApproverLabel.BL_APPROVER_5),
                Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('Message',
                Process.PluginDescribeResult.ParameterType.STRING)                
            };
        return result;
    }
}