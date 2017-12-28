public class MnStagesSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return MnStage__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			MnStage__c.Id,
			MnStage__c.CreatedDate,
			MnStage__c.Name,
			MnStage__c.Addr_Design_Cust_City__c,
			MnStage__c.Addr_Design_Cust_Country__c,
			MnStage__c.Addr_Design_Cust_OID__c,
			MnStage__c.Addr_Design_Cust_State__c,
			MnStage__c.Addr_Design_Cust_Zip__c,
			MnStage__c.Addr_End_Cust_City__c,
			MnStage__c.Addr_End_Cust_Country__c,
			MnStage__c.Addr_End_Cust_OID__c,
			MnStage__c.Addr_End_Cust_State__c,
			MnStage__c.Addr_End_Cust_Zip__c,
			MnStage__c.Assembly_Name__c,
			MnStage__c.Assembly_OID__c,
			MnStage__c.Competitor_Name__c,
			MnStage__c.Competitor_OID__c,
			MnStage__c.Currency_Code__c,
			MnStage__c.Currency_OID__c,
			MnStage__c.Design_Confidence__c,
			MnStage__c.Design_Confidence_OID__c,
			MnStage__c.Design_Cust_GID__c,
			MnStage__c.Design_Cust_Loc__c,
			MnStage__c.Design_Cust_Name__c,
			MnStage__c.Design_Cust_OID__c,
			MnStage__c.Disti_Name__c,
			MnStage__c.Disti_OID__c,
			MnStage__c.End_Cust_GID__c,
			MnStage__c.End_Cust_Loc__c,
			MnStage__c.End_Cust_Name__c,
			MnStage__c.End_Cust_OID__c,
			MnStage__c.Func_Name__c,
			MnStage__c.Func_OID__c,
			MnStage__c.Geo_Design_Cust_OID__c,
			MnStage__c.Geo_Design_Cust_Region__c,
			MnStage__c.Geo_End_Cust_OID__c,
			MnStage__c.Geo_End_Cust_Region__c,
			MnStage__c.Message__c,
			MnStage__c.Opportunity__c,
			MnStage__c.Org_Disti_Branch__c,
			MnStage__c.Org_Disti_OID__c,
			MnStage__c.Part_12NC__c,
			MnStage__c.Part_Is_Root__c,
			MnStage__c.Part_Name__c,
			MnStage__c.Part_OID__c,
			MnStage__c.Part_Root__c,
			MnStage__c.Prod_Family__c,
			MnStage__c.Prod_Family_OID__c,
			MnStage__c.Prog_Name__c,
			MnStage__c.Prog_OID__c,
			MnStage__c.Reg_Action_Date__c,
			MnStage__c.Reg_Created_Date__c,
			MnStage__c.Reg_Disti_Tracking_Num__c,
			MnStage__c.Reg_Exchange_Rate__c,
			MnStage__c.Reg_Expiration_Date__c,
			MnStage__c.Reg_Is_Created_By_B2B__c,
			MnStage__c.Reg_Is_Duplicated__c,
			MnStage__c.Reg_Lead_Id__c,
			MnStage__c.Reg_Modified_Date__c,
			MnStage__c.Reg_Num__c,
			MnStage__c.Reg_OID__c,
			MnStage__c.Reg_Oppty_Num__c,
			MnStage__c.Reg_Part_ASP__c,
			MnStage__c.Reg_Part_Created_Date__c,
			MnStage__c.Reg_Part_Disti_Tracking_Num__c,
			MnStage__c.Reg_Part_Effort_Desc__c,
			MnStage__c.Reg_Part_Effort_Pct__c,
			MnStage__c.Reg_Part_Final_Phase__c,
			MnStage__c.Reg_Part_Is_Active__c,
			MnStage__c.Reg_Part_Is_Expert_Certified__c,
			MnStage__c.Reg_Part_Is_Obsolete__c,
			MnStage__c.Reg_Part_Margin_Qualification__c,
			MnStage__c.Reg_Part_Modified_Date__c,
			MnStage__c.Reg_Part_OID__c,
			MnStage__c.Reg_Part_One_Year_Value__c,
			MnStage__c.Reg_Part_POS_Qty_Shipped__c,
			MnStage__c.Reg_Part_POS_Resale_Value__c,
			MnStage__c.Reg_Part_Qty_Per_Sys__c,
			MnStage__c.Reg_Part_Status__c,
			MnStage__c.Reg_Part_Win_Date__c,
			MnStage__c.Reg_Part_Win_Status__c,
			MnStage__c.Reg_Production_Date__c,
			MnStage__c.Reg_Project_Units__c,
			MnStage__c.Reg_Reject_Reason__c,
			MnStage__c.Reg_Status__c,
			MnStage__c.Reg_Win_Date__c,
			MnStage__c.Reg_Win_Status__c,
			MnStage__c.Status__c,
			MnStage__c.User_Email__c,
			MnStage__c.User_First_Name__c,
			MnStage__c.User_Last_Name__c,
			MnStage__c.User_OID__c
		};
	}
	
	public override String getOrderBy() {
		return 'Name, CreatedDate';
	}
	
	public List<MnStage__c> selectById(Set<Id> ids) {
		p('selectById');
		return (List<MnStage__c>)selectSObjectsById(ids);
	}
	
	public List<MnStage__c> selectByStatus(Set<String> statuses) {
		p('selectByStatus');
		return (List<MnStage__c>)Database.query(newQueryFactory().setCondition('Status__c in :statuses').toSOQL());
	}
	
	public Database.QueryLocator selectByStatusQueryLocator(Set<String> statuses) {
		p('selectByStatusQueryLocator');
		return Database.getQueryLocator(newQueryFactory().setCondition('Status__c in :statuses').toSOQL());
	}
    
}