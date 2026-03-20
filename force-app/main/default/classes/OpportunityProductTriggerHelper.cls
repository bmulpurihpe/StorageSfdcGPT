/**************************************************************************************************************************************

Created By          :        Unnat Shrestha
Created Date        :        March 23, 2016
Purpose             :        Helper class for OpportunityProductTrigger
                            

**************************************************************************************************************************************/

public class OpportunityProductTriggerHelper {
	set<id> oppIds;


	public OpportunityProductTriggerHelper() {
		oppIds = new set<id>();
	}

	//update the field Opportunity Deal Type on Opportunity based on the products in Opportunity Line Items
	public void updateOpportunityDealType (Map<id, opportunityLineItem> oldOLI, Map<id, opportunityLineItem> newOli, boolean isNewList) {
		string temp = '';
		boolean containsAFA = false;
		boolean containsCS = false;
		Set<id> oppIds = new set<id>();
		string productName;

		System.debug('### OpportunityProductTrigger => OpportunityProductTriggerHandler => OpportunityProductTriggerHelper => updateOpportunityDealType :: Reached here');
		if(isNewList) {
			for(opportunityLineItem oli: (List<opportunityLineItem>) trigger.new) {
			 	oppIds.add(oli.OpportunityId);
			 	System.debug('### 1.0 New Opportunity Line Item Id :: '+ oli.id);
			}
		}
		else {
			for(opportunityLineItem oli: (List<opportunityLineItem>) trigger.old) {
				oppIds.add(oli.OpportunityId);
				System.debug('### 2.0 old opp line id :: '+ oli.id);
			}
		}

		//retrieving the values
		List<Opportunity> oppList = [Select id, Opportunity_deal_type__c from Opportunity WHERE id IN: oppIds];
		//here condition also checks if the quote is primary or not as oli's will only carry the line items from primary quote
		List<opportunityLineItem> oliList = [SELECT id, product2.name, productcode, opportunityId 
											   FROM opportunityLineItem where OpportunityId IN: oppIds 
												AND SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c=true];
		
		//loop through opportunity and olis to properly populate the value in opportunity deal type
		for(opportunity opp: oppList ) {
			productName = '';
			for (opportunityLineItem oli: oliList) {
				if (oli.opportunityId == opp.id) {
					productName = oli.productCode;

					System.debug('### Product name is :: '+ productName +' and OLI id is :: '+ oli.id);
					if (productName =='AFA') {
						containsAFA = true;
						break;
					}
					else if (productName.startsWith('CS')) {
						containsCS = true;
					}
				}
			}
			//set opportunity deal type to AFA
			if (containsAFA) {
				System.debug('### OpportunityProductTrigger => OpportunityProductTriggerHandler => OpportunityProductTriggerHelper => updateOpportunityDealType :: contains AFA Product');
				opp.Opportunity_deal_type__c = 'Includes All Flash Array(s)';
				break;
			}
			//set opportunity deal type to Hybrid only
			else if (containsCS){
				System.debug('### OpportunityProductTrigger => OpportunityProductTriggerHandler => OpportunityProductTriggerHelper => updateOpportunityDealType :: contains CS Product');
				opp.Opportunity_deal_type__c = 'Hybrid Only';
				break;
			}
			//set opportunity deal type to other
			else {
				System.debug('### OpportunityProductTrigger => OpportunityProductTriggerHandler => OpportunityProductTriggerHelper => updateOpportunityDealType :: No AFA or CS products exist.');
				opp.Opportunity_deal_type__c = 'Other (parts, spares, renewals, SoD, etc)';
			}
		}
		//update the list
		update oppList;
	}
}