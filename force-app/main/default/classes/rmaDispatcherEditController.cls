public class rmaDispatcherEditController{

   private RMAV2__c rma {get;set;}

    public rmaDispatcherEditController(ApexPages.StandardController controller) {
        this.controller = controller;
       
    }

    public PageReference getRedir() {

        PageReference viewPage;
        rma = (RMAV2__c)controller.getRecord();

        if(rma.rmaSelection__c != null )
        {
            viewPage = Page.rmaV2NewPageV2;
        }
        else if(rma.rmaShipmentAddressSelector__c == null || rma.rmaShipmentAddressSelector__c =='')
        {
            viewPage = Page.rmaV2NewPage;
        }
        else
        {
            viewPage = new PageReference('/' + rma.id + '/e');
            viewPage.getParameters().put('nooverride', '1');
            viewPage.getParameters().put('retURL', rma.Id);
        }

        viewPage.getParameters().put('id', rma.Id);
       
        return viewPage.setRedirect(true);

    }

    private final ApexPages.StandardController controller;

}