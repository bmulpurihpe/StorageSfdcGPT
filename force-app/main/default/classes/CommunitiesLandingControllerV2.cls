/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingControllerV2 {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        if(UserInfo.getUserId() == '0058000000761OZ') {
//            PageReference pageRet=new PageReference('http://www.veltigconsulting.com/now/?page_id=17');  // for sandbox
            PageReference pageRet=new PageReference('http://www.nimblestorage.com/partners/partner-login/');  // for production
            return pageret;
        }
        else {
            PageReference pageRet=new PageReference('/partner2/s'); 
            return pageret;
            //return Network.CommunitiesLanding();
        }
    }
    
    public CommunitiesLandingControllerV2() {}
}