public class rmaDispatcherViewController{

   private RMAV2__c rma {get;set;}

    public rmaDispatcherViewController(ApexPages.StandardController controller) {
        this.controller = controller;
       
    }

    public PageReference getRedir() {

        PageReference viewPage;
        rma = (RMAV2__c)controller.getRecord();

        if(rma.rmaSelection__c != null )
        {
            viewPage = Page.rmaV2DetailPageV2;
        }
        else if(rma.rmaShipmentAddressSelector__c == null || rma.rmaShipmentAddressSelector__c =='')
        {
            viewPage = Page.rmaV2DetailPage;
        }
        else
        {
            viewPage = new PageReference('/' + rma.id);
            viewPage.getParameters().put('nooverride', '1');
        }

        viewPage.getParameters().put('id', rma.Id);
        return viewPage.setRedirect(true);

    }

    private final ApexPages.StandardController controller;

}