trigger UpdateOpportunitySPIFF_Claim on Opportunity (after update) {	
	if(Utility.runDupRecTrigger==true)
	{
    if(trigger.isAfter && trigger.isUpdate) SPIFFClaim.updateSPIFFClaim(trigger.new);
	}
}