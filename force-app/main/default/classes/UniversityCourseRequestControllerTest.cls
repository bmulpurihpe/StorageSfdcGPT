/**
 * #8195: 28/09/15 Vanroth
 */
@isTest
private class UniversityCourseRequestControllerTest {

    static testMethod void testView() {
        
        User usr = [select id,CommunityNickname from user where id =:UserInfo.getUserId()];
        // usr.Certified_Instructor__c=true;
        // usr.Certified_Instructor_Username__c = usr.CommunityNickname;
        update usr;
        
        PageReference pageRef = Page.UniversityCourseRequest;
        Test.setCurrentPage(pageRef);
        University_Course_Request__c ucr=new University_Course_Request__c();
        ucr.Desired_Course_Start_Date__c = system.today();
        ucr.Desired_Course_Start_Time_p__c='08:00 AM';
        ucr.Requester_City__c = 'PP';
        ucr.Requester_Country__c='cambodia';
        ucr.Requested_Instructor__c = UserInfo.getUserId();
        ucr.Course_Requested__c='NTS-2001-I: Nimble Introduction and Administration';
        ucr.Class_Type__c = 'Public';
        ucr.Expected_course_size__c = 15;
        ucr.AE_Name__c = UserInfo.getUserId() ;
        ucr.SE_Name__c = userinfo.getuserid();
        ucr.Assistance_with_Venue_Required__c = 'Yes';
        ucr.Assistance_with_Catering_Required__c = 'No';
        ucr.Projector_Required__c = 'No';
        ucr.Student_Manuals_Required__c ='No';
        insert ucr;
        ucr = [select Name,Desired_Course_Start_Date__c,Requested_Instructor__c,Requester_City__c,
                    OwnerId,  Desired_Course_Start_Time_p__c, Request_Status__c,Duplicate_UCR_Record__c,
                    Requester_State__c, Requester_Country__c, Course_Requested__c, Second_Instructor__c,
                    Instructor_in_Training__c,Class_Type__c, Expected_course_size__c, Large_Course_Warning__c,
                    AE_Name__c, SE_Name__c,Assistance_with_Venue_Required__c,Preferred_Locations__c,
                    Assistance_with_Catering_Required__c, Catering_Notes__c,Projector_Required__c,
                    Venue_Name__c, Venue_Detail__c,Venue_City__c,Venue_Street__c,Venue_State__c,Venue_Zip__c,Venue_Country__c,
                    Room_Capacity__c, Student_Manuals_Required__c, Name_of_Person_Picking_Up__c, Phone_of_Person_Picking_Up__c,
                    Pickup_Location_Name__c, Pickup_Street__c, Pickup_City__c, Pickup_State__c, Pickup_Zip__c,Pickup_Country__c,
                    Special_Requests_and_notes__c, Large_Course__c,Requested_by__c,AE_Phone__c,AE_Mobile_Phone__c, SE_Phone__c,
                    SE_Mobile_Phone__c,CreatedById ,LastModifiedByID 
                    from  University_Course_Request__c where id =: ucr.id]; 
                    
        Popup_Dimension_Setting__c setting = new Popup_Dimension_Setting__c();
        setting.Name = 'Airport Pop Up';
        setting.Height__c = 1000;
        setting.Width__c = 1000;
        insert setting;
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ucr);
        ApexPages.currentPage().getParameters().put('id',ucr.id);
        ApexPages.currentPage().getParameters().put('action','view');
        UniversityCourseRequestController uc =new UniversityCourseRequestController(sc);
        
        
    }
    static testMethod void testEdit() {
        User usr = [select id,CommunityNickname from user where id =:UserInfo.getUserId()];
        // usr.Certified_Instructor__c=true;
        // usr.Certified_Instructor_Username__c = usr.CommunityNickname;
        update usr;
        
        PageReference pageRef = Page.UniversityCourseRequest;
        Test.setCurrentPage(pageRef);
        University_Course_Request__c ucr=new University_Course_Request__c();
        ucr.Desired_Course_Start_Date__c = system.today();
        ucr.Desired_Course_Start_Time_p__c='08:00 AM';
        ucr.Requester_City__c = 'PP';
        ucr.Requester_Country__c='cambodia';
        ucr.Requested_Instructor__c = UserInfo.getUserId();
        ucr.Course_Requested__c='NTS-2001-I: Nimble Introduction and Administration';
        ucr.Class_Type__c = 'Public';
        ucr.Expected_course_size__c = 15;
        ucr.AE_Name__c = UserInfo.getUserId() ;
        ucr.SE_Name__c = userinfo.getuserid();
        ucr.Assistance_with_Venue_Required__c = 'Yes';
        ucr.Assistance_with_Catering_Required__c = 'No';
        ucr.Projector_Required__c = 'No';
        ucr.Student_Manuals_Required__c ='No';
        insert ucr;
        ucr = [select Name,Desired_Course_Start_Date__c,Requested_Instructor__c,Requester_City__c,
                    OwnerId,  Desired_Course_Start_Time_p__c, Request_Status__c,Duplicate_UCR_Record__c,
                    Requester_State__c, Requester_Country__c, Course_Requested__c, Second_Instructor__c,
                    Instructor_in_Training__c,Class_Type__c, Expected_course_size__c, Large_Course_Warning__c,
                    AE_Name__c, SE_Name__c,Assistance_with_Venue_Required__c,Preferred_Locations__c,
                    Assistance_with_Catering_Required__c, Catering_Notes__c,Projector_Required__c,
                    Venue_Name__c, Venue_Detail__c,Venue_City__c,Venue_Street__c,Venue_State__c,Venue_Zip__c,Venue_Country__c,
                    Room_Capacity__c, Student_Manuals_Required__c, Name_of_Person_Picking_Up__c, Phone_of_Person_Picking_Up__c,
                    Pickup_Location_Name__c, Pickup_Street__c, Pickup_City__c, Pickup_State__c, Pickup_Zip__c,Pickup_Country__c,
                    Special_Requests_and_notes__c, Large_Course__c,Requested_by__c,AE_Phone__c,AE_Mobile_Phone__c, SE_Phone__c,
                    SE_Mobile_Phone__c,CreatedById ,LastModifiedByID 
                    from  University_Course_Request__c where id =: ucr.id]; 
                    
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ucr);
        ApexPages.currentPage().getParameters().put('id',ucr.id);
        ApexPages.currentPage().getParameters().put('action','edit');
        ApexPages.currentPage().getParameters().put('retURL','/a3G');
        ApexPages.currentPage().getParameters().put('ru','t');
        UniversityCourseRequestController uc =new UniversityCourseRequestController(sc);
        uc.ucr = ucr;
        //cover extra coverage
        uc.getClassTypes();
        uc.getAstVenue();
        uc.getYesNo();
        uc.ucr.Pickup_Country__c = 'UK';
        uc.astVenueSelected();
        uc.astCateringSelected();
        uc.astStudentManualSelected();
        uc.doSave();
        //uc.SaveNew();
        uc.Cancel();
        uc.roomCapacity = '12';
        uc.doEdit();
        uc.deleteObj();
        //uc.checkOverride();
        //uc.CloneObj();
        //uc.Sharing();
    }
    static testMethod void testNew() {
        User usr = [select id,CommunityNickname from user where id =:UserInfo.getUserId()];
        // usr.Certified_Instructor__c=true;
        // usr.Certified_Instructor_Username__c = usr.CommunityNickname;
        update usr;
        PageReference pageRef = Page.UniversityCourseRequest;
        Test.setCurrentPage(pageRef);
        University_Course_Request__c ucr=new University_Course_Request__c();
        ucr.Desired_Course_Start_Date__c = system.today();
        ucr.Desired_Course_Start_Time_p__c='08:00 AM';
        ucr.Requester_City__c = 'PP';
        ucr.Requester_Country__c='cambodia';
        ucr.Requested_Instructor__c = UserInfo.getUserId();
        ucr.Course_Requested__c='NTS-2001-I: Nimble Introduction and Administration';
        ucr.Class_Type__c = 'Public';
        ucr.Expected_course_size__c = 15;
        ucr.AE_Name__c = UserInfo.getUserId() ;
        ucr.SE_Name__c = userinfo.getuserid();
        ucr.Assistance_with_Venue_Required__c = 'Yes';
        ucr.Assistance_with_Catering_Required__c = 'No';
        ucr.Projector_Required__c = 'No';
        ucr.Student_Manuals_Required__c ='No';
        insert ucr;
        ucr = [select Name,Desired_Course_Start_Date__c,Requested_Instructor__c,Requester_City__c,
                    OwnerId,  Desired_Course_Start_Time_p__c, Request_Status__c,Duplicate_UCR_Record__c,
                    Requester_State__c, Requester_Country__c, Course_Requested__c, Second_Instructor__c,
                    Instructor_in_Training__c,Class_Type__c, Expected_course_size__c, Large_Course_Warning__c,
                    AE_Name__c, SE_Name__c,Assistance_with_Venue_Required__c,Preferred_Locations__c,
                    Assistance_with_Catering_Required__c, Catering_Notes__c,Projector_Required__c,
                    Venue_Name__c, Venue_Detail__c,Venue_City__c,Venue_Street__c,Venue_State__c,Venue_Zip__c,Venue_Country__c,
                    Room_Capacity__c, Student_Manuals_Required__c, Name_of_Person_Picking_Up__c, Phone_of_Person_Picking_Up__c,
                    Pickup_Location_Name__c, Pickup_Street__c, Pickup_City__c, Pickup_State__c, Pickup_Zip__c,Pickup_Country__c,
                    Special_Requests_and_notes__c, Large_Course__c,Requested_by__c,AE_Phone__c,AE_Mobile_Phone__c, SE_Phone__c,
                    SE_Mobile_Phone__c,CreatedById ,LastModifiedByID 
                    from  University_Course_Request__c where id =: ucr.id]; 
                    
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ucr);
        ApexPages.currentPage().getParameters().put('id',ucr.id);
        ApexPages.currentPage().getParameters().put('action','new');
        ApexPages.currentPage().getParameters().put('retURL','/a3G');
        UniversityCourseRequestController uc =new UniversityCourseRequestController(sc);
        uc.expectedSize = 'test';
        uc.expectedCauseSizeChange();
        
        uc.roomCapacity = 'test';
        uc.roomCapacityChange();
        uc.expectedSize = '10';
        uc.roomCapacity = '5';
        uc.ucr.Assistance_with_Venue_Required__c = 'No';
        uc.expectedCauseSizeChange();
        uc.roomCapacityChange();
        
        uc.ucr.Assistance_with_Venue_Required__c = 'Yes';
        uc.roomCapacityChange();
        
        //uc.ucr.CreatedDate = System.today();
        uc.ucr.Desired_Course_Start_Date__c = System.today()-1;
        uc.desiredDateChange();
        
        uc.ucr.Desired_Course_Start_Date__c = System.today()+2;
        uc.desiredDateChange();
        
        uc.ucr.Student_Manuals_Required__c = 'Yes';
        uc.ucr.Pickup_Country__c = 'UK';
        uc.pickupCountryChange();
        uc.astProjectRquired();
        
        uc.ucr.Assistance_with_Venue_Required__c = 'No';
        uc.astVenueSelected();
        
        uc.ucr.Assistance_with_Catering_Required__c = 'Yes';
        uc.ucr.Venue_Country__c = 'UK';
        uc.ucr.Assistance_with_Venue_Required__c = 'No';
        uc.astCateringSelected();
        
        uc.ucr.Assistance_with_Venue_Required__c = 'No';
        uc.ucr.Venue_Country__c = 'UK';
        uc.ucr.Assistance_with_Catering_Required__c = 'Yes';
        uc.venueCountryChange();
        
        uc.ucr.Student_Manuals_Required__c = 'Yes';
        uc.ucr.Pickup_Country__c = 'UK';
        uc.ucr.Assistance_with_Venue_Required__c = 'No';
        uc.astStudentManualSelected();
        
    }
    static testMethod void testValidate() {
        system.debug('>>>>> testValidate');
        User usr = [select id,CommunityNickname from user where id =:UserInfo.getUserId()];
        // usr.Certified_Instructor__c=true;
        // usr.Certified_Instructor_Username__c = usr.CommunityNickname;
        update usr;
        
        PageReference pageRef = Page.UniversityCourseRequest;
        Test.setCurrentPage(pageRef);
        University_Course_Request__c ucr=new University_Course_Request__c();
        
        //insert ucr;

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ucr);
       
        UniversityCourseRequestController uc =new UniversityCourseRequestController(sc);
        uc.ucr = new University_Course_Request__c();
        system.debug('>>>>> uc.ucr  '+uc.ucr );
        uc.getCourseRequested();
        uc.validateAirport3Letters();
        uc.roomCapacity = '12';
        uc.renderedCatering='T';
        uc.renderedVenue ='T';
        uc.renderedStudentManual='T';
        
        uc.ucr.Assistance_with_Venue_Required__c = 'No';
        uc.ucr.Venue_Country__c = 'US';
        uc.ucr.Assistance_with_Catering_Required__c = 'Yes';
        uc.validate();
        uc.doSave();
        
        uc.renderedVenue='F';
        uc.validate();
        
        insert new Popup_Dimension_Setting__c(Name='Test Setting',Width__c=12.0,Height__c=30.0);
        /*
        uc.ucr.Assistance_with_Catering_Required__c='Yes';
        uc.ucr.Preferred_Locations__c ='abc';
        uc.ucr.Venue_Name__c='aaa';
        uc.ucr.Venue_Street__c='aaa';
        uc.ucr.Venue_City__c='aaa';
        uc.ucr.Venue_State__c='aaa';
        uc.ucr.Venue_Zip__c='aaa';
        uc.ucr.Venue_Country__c='aaa';
        uc.ucr.Room_Capacity__c=10;
        uc.ucr.Pickup_Location_Name__c ='aaa';
        uc.ucr.Name_of_Person_Picking_Up__c='aaa';
        uc.ucr.Phone_of_Person_Picking_Up__c='aaa';
        uc.ucr.Pickup_Street__c='aaa';
        uc.ucr.Pickup_City__c='aaa';
        uc.ucr.Pickup_State__c='aaa';
        uc.ucr.Pickup_Zip__c='aaa';
        uc.ucr.Pickup_Country__c='aaa';
        uc.width = '14';
        uc.height = '67';
        */
    }
    
    static testmethod void testValidate2(){
    	User usr = [select id,CommunityNickname from user where id =:UserInfo.getUserId()];
        // usr.Certified_Instructor__c=true;
        // usr.Certified_Instructor_Username__c = usr.CommunityNickname;
        update usr;
        PageReference pageRef = Page.UniversityCourseRequest;
        Test.setCurrentPage(pageRef);
        University_Course_Request__c ucr=new University_Course_Request__c();
        ucr.Desired_Course_Start_Date__c = system.today();
        ucr.Desired_Course_Start_Time_p__c='08:00 AM';
        ucr.Requester_City__c = 'PP';
        ucr.Requester_Country__c='cambodia';
        ucr.Requested_Instructor__c = UserInfo.getUserId();
        ucr.Course_Requested__c='NTS-2001-I: Nimble Introduction and Administration';
        ucr.Class_Type__c = 'Public';
        ucr.Expected_course_size__c = 15;
        ucr.AE_Name__c = UserInfo.getUserId() ;
        ucr.SE_Name__c = userinfo.getuserid();
        ucr.Assistance_with_Venue_Required__c = 'Yes';
        ucr.Assistance_with_Catering_Required__c = 'No';
        ucr.Projector_Required__c = 'No';
        ucr.Student_Manuals_Required__c ='No';
        insert ucr;
        ucr = [select Name,Desired_Course_Start_Date__c,Requested_Instructor__c,Requester_City__c,
                    OwnerId,  Desired_Course_Start_Time_p__c, Request_Status__c,Duplicate_UCR_Record__c,
                    Requester_State__c, Requester_Country__c, Course_Requested__c, Second_Instructor__c,
                    Instructor_in_Training__c,Class_Type__c, Expected_course_size__c, Large_Course_Warning__c,
                    AE_Name__c, SE_Name__c,Assistance_with_Venue_Required__c,Preferred_Locations__c,
                    Assistance_with_Catering_Required__c, Catering_Notes__c,Projector_Required__c,
                    Venue_Name__c, Venue_Detail__c,Venue_City__c,Venue_Street__c,Venue_State__c,Venue_Zip__c,Venue_Country__c,
                    Room_Capacity__c, Student_Manuals_Required__c, Name_of_Person_Picking_Up__c, Phone_of_Person_Picking_Up__c,
                    Pickup_Location_Name__c, Pickup_Street__c, Pickup_City__c, Pickup_State__c, Pickup_Zip__c,Pickup_Country__c,
                    Special_Requests_and_notes__c, Large_Course__c,Requested_by__c,AE_Phone__c,AE_Mobile_Phone__c, SE_Phone__c,
                    SE_Mobile_Phone__c,CreatedById ,LastModifiedByID 
                    from  University_Course_Request__c where id =: ucr.id]; 
                    
        
        ApexPages.currentPage().getParameters().put('id',ucr.id);
        ApexPages.currentPage().getParameters().put('action',null);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(ucr);
       
        UniversityCourseRequestController uc =new UniversityCourseRequestController(sc);
        uc.venueCityChange();
        uc.ucr.Desired_Course_Start_Date__c = system.today()-2;
        uc.desiredDateChange();
        
        uc.ucr = new University_Course_Request__c();
    	uc.ucr.Desired_Course_Start_Date__c = null;
        uc.ucr.Desired_Course_Start_Time_p__c = null;
        uc.ucr.Requested_Instructor__c = null;
        uc.ucr.Class_Type__c = null;
        uc.ucr.AE_Name__c = null;
        
        uc.ucr.SE_Name__c = null;
        uc.ucr.Assistance_with_Catering_Required__c = 'Yes';
        uc.ucr.Pickup_Country__c = 'US';
        uc.renderedCatering = 'T';
        uc.ucr.Catering_Notes__c = null;
        
        uc.renderedVenue = 'F';
        uc.ucr.Venue_Airport_Code_Manual__c = '12';
        uc.ucr.Venue_Country__c = null;
        uc.roomCapacity = null;
        uc.ucr.Student_Manuals_Required__c = 'Yes';
        uc.ucr.Pickup_Country__c = 'USA';
        
        uc.renderedStudentManual = 'T';
        uc.ucr.Name_of_Person_Picking_Up__c = null;
        uc.ucr.Phone_of_Person_Picking_Up__c = null;
        uc.expectedSize = '123';
        uc.ucr.Course_Requested__c = null;
        uc.ucr.Assistance_with_Venue_Required__c = null;
        uc.validate();
        
    }
}