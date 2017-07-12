global class OpportunitySetApproverPlugin implements Process.Plugin {
    global Process.PluginResult invoke(Process.PluginRequest request) {
		String OpptyId = (String) request.inputParameters.get('Id');
        Map<String, String> result = new Map<String, String>();
        try
        {
            OpportunityApproval.setAllApprovers(opptyID);
            result.put('Message', 'Success');
        }
        catch (Exception err)
        {
            System.debug('@@@' + err.getMessage());
            System.debug('@@@' + err.getStackTraceString());
            result.put('Message', 'EXCEPTION: ' + err.getMessage());
        }
        return new Process.PluginResult(result);
    }
    
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.Name = 'Set All Approvers';
		result.Tag = 'Approver';
		result.inputParameters = new
		List<Process.PluginDescribeResult.InputParameter> {
			new Process.PluginDescribeResult.InputParameter('Id',
			Process.PluginDescribeResult.ParameterType.STRING, true)
			};
        result.outputParameters = new
		List<Process.PluginDescribeResult.OutputParameter> {
			new Process.PluginDescribeResult.OutputParameter('Message', 
                Process.PluginDescribeResult.ParameterType.STRING)
            };
        return result;
    }
}