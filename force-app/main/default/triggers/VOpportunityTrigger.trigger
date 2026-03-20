trigger VOpportunityTrigger on Opportunity (after insert, after update) {
	if(Utility.runDupRecTrigger==true)
	{
    new VOpportunityTriggerDispatcher().dispatch(); 
	}
}