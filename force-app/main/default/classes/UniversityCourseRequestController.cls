/*
Date: 23/09/15
Author: Vanroth
Business: # 8195, a custom page for Object University Course Request
*/
public with sharing class UniversityCourseRequestController {
    
    public University_Course_Request__c ucr {get;set;}
    public string renderedVenue {get;set;}
    public string renderedCatering{get;set;}
    public string renderedStudentManual {get;set;}
    public boolean isViewRecord{get;set;}
    public boolean isEditRecord{get;set;}
    
    public string errStartDate{get;set;}
    public string errStartTime{get;set;}
    //public string errRequesterCity{get;set;}
    //public string errRequesterCountry{get;set;}
    public string errRequestedInstructor{get;set;}
     
    public string errClassType{get;set;}
    public string errAEName{get;set;}
    public string errSEName{get;set;}
    public string errAstVenue{get;set;}
    public string errAstCatering{get;set;}
    public string errProjector{get;set;}
    //public string errCateringNote{get;set;}
    public string errVenueName{get;set;}
    public string errVenueAirport{get;set;}
    public string errPreferredLocation{get;set;}
    public string errVenueStreet{get;set;}
    public string errVenueCity{get;set;}
    public string errVenueState{get;set;}
    public string errVenueZip{get;set;}
    public string errVenueCountry{get;set;}
    public string errRoomCapacity{get;set;}
    public string errStudentManual{get;set;}
    public string errPickupPerson{get;set;}
    public string errPickupPhone{get;set;}
    public string errPickupZip{get;set;}
    public String errPickupCountry{get;set;}
    public String errPickupState {get;set;}
    public String errPickupCity {get;set;}
    public String errPickupStreet {get;set;}
    public String errPickupLocation {get;set;}
    public string errPreferredLocation2{get;set;}
    public string errPreferredLocation3{get;set;}
    //public string errSecondInstructor{get;set;}
    public String err2ndUniverInstructor {get;set;}
    public string errExpectedCourseSize {get;set;}
    public string errCourseRequested{get;set;}
    public Boolean isValidate{get;set;}
    public Boolean isEditable{get;set;}
    public Boolean isDeletable{get;set;}
    public ID userProfile {get;set;}
    public String width{get;set;}
    public String height{get;set;}
    public Boolean refreshPage{get;set;}
    public Set<String> countrySet ;
    public String roomCapacity{get;set;}
    public String expectedSize{get;set;}
    
    public final String ERR_STUDENT_MANUAL = 'Student manuals for delivery can be ordered only for delivery location in North America.';
    public final String ERR_ROOM_CAPACITY = 'The room capacity is too small for the expected course size.';
    public final String ERR_PICKUP_COUNTRY = 'Student manuals for delivery can be ordered only for delivery location in North America.';
    public final String ERR_CATERING = 'Assistance with catering can be provided only in north America.';
    public final String ERR_DESIREDATE = 'Desired Course Start Date cannot be in the past.';
    public final String ERR_SELECTOPTION = 'Error: You must select an option.';
    private final String ERR_EXPECTED_COURSE_SIZE_GT_20 = 'Courses with 21+ participants require special approval. It is recommended that you request an additional course. If you still want to proceed then check the “Large Course” checkbox in the “Special Requests and Notes” section below.';
    private final String ERR_EXPECTED_COURSE_SIZE_LT_6 = 'The minimum class size is 6.';
    private String largeCourseWarning = null;
    private String courseReqRes;
    private String conWarning;
    
    public UniversityCourseRequestController(Apexpages.standardController c)
    {   
        refreshPage = false;
        countrySet = new Set<String>{'US', 'USA', 'United States', 'UNITED STATES', 'United States of America','CA', 'CANADA', 'Canada'};
        List<Popup_Dimension_Setting__c> setting = Popup_Dimension_Setting__c.getall().values();
        if(!setting.isEmpty())
        {
            width = String.valueOf(setting[0].Width__c);
            height = String.valueOf(setting[0].Height__c);
        }
        userProfile = userinfo.getProfileId();
        checkPermission();
        isValidate =true;
        ucr = (University_Course_Request__c) c.getRecord();
        renderedVenue = '';
        renderedCatering = '';
        renderedStudentManual = '';
        ucr = new University_Course_Request__c();
        ucr.ownerid = UserInfo.getUserId();
        ucr.Request_Status__c ='Submitted';
        string action = ApexPages.currentPage().getParameters().get('action');
        string id = ApexPages.currentPage().getParameters().get('id');
        expectedSize = '15';
        if(id!=null)
        {
            ucr = [select Name,Desired_Course_Start_Date__c,Requested_Instructor__c,Requester_City__c, Course_Request_Response_SLA__c,
                    OwnerId,  Desired_Course_Start_Time_p__c, Request_Status__c,Duplicate_UCR_Record__c, Connectivity_Warning__c,
                    Requester_State__c, Requester_Country__c, Course_Requested__c, Second_Instructor__c, Requested_University_Instructor1__c,
                    Instructor_in_Training__c,Class_Type__c, Expected_course_size__c, Large_Course_Warning__c,Second_University_Instructor1__c,
                    AE_Name__c, SE_Name__c,Assistance_with_Venue_Required__c,Preferred_Locations__c,
                    Assistance_with_Catering_Required__c, Catering_Notes__c,Projector_Required__c,
                    Venue_Name__c, Venue_Detail__c,Venue_City__c,Venue_Street__c,Venue_State__c,Venue_Zip__c,Venue_Country__c,
                    Room_Capacity__c, Student_Manuals_Required__c, Name_of_Person_Picking_Up__c, Phone_of_Person_Picking_Up__c,
                    Pickup_Location_Name__c, Pickup_Street__c, Pickup_City__c, Pickup_State__c, Pickup_Zip__c,Pickup_Country__c,
                    Special_Requests_and_notes__c, Large_Course__c,Requested_by__c,AE_Phone__c,AE_Mobile_Phone__c, SE_Phone__c,
                    SE_Mobile_Phone__c,CreatedById ,LastModifiedByID,Preferred_Location_2__c,Preferred_Location_3__c,
                    Venue_Airport_Code_Manual__c,CreatedDate,Venue_In_NA__c
                    from  University_Course_Request__c where id =: id];
            roomCapacity = String.valueOf(ucr.Room_Capacity__c);
            expectedSize = String.valueOf(ucr.Expected_course_size__c);
            astVenueSelected(); 
            astCateringSelected();
            astStudentManualSelected();
        }
        if(action!=null){
            if(action.equalsIgnoreCase('view') )
            {   
                //https://c.cs40.visual.force.com/apex/UniversityCourseRequest?action=view&id=a3G54000000001Y
                isViewRecord = true;        
            }
            else if(action.equalsIgnoreCase('edit'))
            {
                //https://c.cs40.visual.force.com/apex/UniversityCourseRequest?action=edit&id=a3G54000000001Y
                isViewRecord = false;
                isEditRecord = true;
                astVenueSelected();
                astCateringSelected();
                astStudentManualSelected();
            }
            else if(action.equalsIgnoreCase('new'))
            {
                //https://c.cs40.visual.force.com/apex/UniversityCourseRequest?action=new
                isViewRecord = false;
                if(id!=null)//it mean that this is a clone record
                {
                    University_Course_Request__c oldUcr = ucr.clone(false,false,false,false);
                    ucr= oldUcr;
                }
            }
        }
        else //action =null && id!=null-> mean viewing the page
        {
            if(id!=null){
                isViewRecord=true;
                isEditRecord = false;
            }
        }
    }
    
    public void checkPermission()
    {
        Profile p = [select Id from profile where id = :userinfo.getProfileId()];
        
        /*
        ** Parent.IsOwnedByProfile = TRUE => Permission was owned by profile
        ** Parent.IsOwnedByProfile = FALSE => Permission was not owned by profile(All users)
        */
        ObjectPermissions[] obj = [Select PermissionsEdit,PermissionsDelete,ParentId,Parent.IsOwnedByProfile,Parent.ProfileId From ObjectPermissions 
                                    WHERE ((Parent.IsOwnedByProfile = TRUE AND  Parent.ProfileId=:p.Id) OR Parent.IsOwnedByProfile = FALSE)
                                    AND SobjectType = 'University_Course_Request__c'];
        isEditable = false;
        isDeletable = false;
        Set<Id> permissionSetIds = new Set<Id>();
        Map<Id,ObjectPermissions> mPermissionset_ObjectPermission = new Map<Id,ObjectPermissions>();
        for(ObjectPermissions o : obj)
        {
            //profile permission
            if(o.Parent.ProfileId != null && o.Parent.ProfileId==p.Id){   
                if(o.PermissionsEdit) isEditable = o.PermissionsEdit;
                if(o.PermissionsDelete) isDeletable = o.PermissionsDelete;
            }else{//permission set
                permissionSetIds.add(o.ParentId);
                mPermissionset_ObjectPermission.put(o.ParentId,o);
            }
        }
        for(PermissionSetAssignment pAssignment : [Select p.PermissionSetId, p.AssigneeId From PermissionSetAssignment p 
                                                    where PermissionSetId in: permissionSetIds AND AssigneeId=:userinfo.getUserId()]){
            ObjectPermissions o = mPermissionset_ObjectPermission.get(pAssignment.PermissionSetId);
            if(o.PermissionsEdit) isEditable = o.PermissionsEdit;
            if(o.PermissionsDelete) isDeletable = o.PermissionsDelete;
        }
        //check custom setting for the profile was forced to be admin permission
        //List<ForceProfileAdmin__c> customSetting = [Select Name from ForceProfileAdmin__c where Name=:String.valueOf(p.Id).subString(0,15)];
        //if(customSetting.size() > 0)isEditable = true;
    }
    
    public list<SelectOption>getClassTypes()
    {
        return pickListToRadioBtn('Class_Type__c'); 
    }
    public list<SelectOption>getAstVenue()
    {
         return pickListToRadioBtn('Assistance_with_Venue_Required__c');
    }
    public List<SelectOption> getYesNo() {
        List<SelectOption> options = new List<SelectOption>();
         options.add(new SelectOption('Yes', 'Yes'));
         options.add(new SelectOption('No', 'No'));
        return options;
    }
    public list<SelectOption>pickListToRadioBtn(string fieldName)
    {
        Schema.sObjectType sobject_type = University_Course_Request__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
          
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();

        for (Schema.PicklistEntry a : pick_list_values) {
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public void venueCityChange()
    {
        system.debug('>>>>> venueCityChange ');
    }
    public void roomCapacityChange()
    {
        errRoomCapacity = '';
        if (!String.valueOf(roomCapacity.trim()).isNumeric())
        {
            isValidate = false;
            errRoomCapacity ='Error: Invalid number';
        }
        else if ('No'.equals(ucr.Assistance_with_Venue_Required__c) && Integer.valueOf(roomCapacity.trim()) < Integer.valueOf(expectedSize.trim()))
        {
            errRoomCapacity = ERR_ROOM_CAPACITY;
        }
        else 
        {
            ucr.Room_Capacity__c = Integer.valueOf(roomCapacity.trim());   
            errExpectedCourseSize = '';
        }
    }
    
    public void desiredDateChange()
    {
        errStartDate ='';
        if((ucr.CreatedDate !=null) && (Date.newInstance(ucr.Desired_Course_Start_Date__c.year(),ucr.Desired_Course_Start_Date__c.month(), ucr.Desired_Course_Start_Date__c.day() ) 
                < Date.newInstance(ucr.CreatedDate.year(), ucr.CreatedDate.month(), ucr.CreatedDate.day())))
        {
            isValidate = false;
            errStartDate = ERR_DESIREDATE;
        }
        else if ((ucr.CreatedDate ==null) && (ucr.Desired_Course_Start_Date__c < system.TODAY()))
        {
            isValidate = false;
            errStartDate = ERR_DESIREDATE;
        }
    }
    
    public void pickupCountryChange()
    {
        errStudentManual ='';
        if('Yes'.equals(ucr.Student_Manuals_Required__c) && !countrySet.contains(ucr.Pickup_Country__c))
        {
            isValidate = false;
            errStudentManual = ERR_STUDENT_MANUAL;
        }
    }
    public void astProjectRquired()
    {
        errProjector = '';
    }
    public void astVenueSelected()
    {
        errAstVenue='';
        if ('Yes'.equals(ucr.Assistance_with_Venue_Required__c)) 
        {
            renderedVenue='T';
            ucr.Venue_Name__c='';
            ucr.Venue_Detail__c='';
            ucr.Venue_Street__c='';
            ucr.Venue_City__c='';
            ucr.Venue_State__c='';
            ucr.Venue_Zip__c='';
            ucr.Venue_Country__c='';
            ucr.Venue_Airport_Code_Manual__c ='';
            //ucr.Room_Capacity__c=null;
            roomCapacity ='';
            if(String.isNotBlank(ucr.Pickup_Country__c) && !countrySet.contains(ucr.Pickup_Country__c)) {
                errAstVenue = 'Assistance with venue can be given only for north America.';
                isValidate = false;
            }
        }
        else if('No'.equals(ucr.Assistance_with_Venue_Required__c))
        {
            renderedVenue ='F';
            ucr.Preferred_Locations__c='';
            ucr.Preferred_Location_2__c='';
            ucr.Preferred_Location_3__c='';
        }
    }
    
    public void venueCountryChange()
    {
        errAstCatering = '';
        if('No'.equals(ucr.Assistance_with_Venue_Required__c) && !countrySet.contains(ucr.Venue_Country__c) && String.isNotBlank(ucr.Venue_Country__c) && 'Yes'.equals(ucr.Assistance_with_Catering_Required__c))
        {
            errAstCatering = ERR_CATERING;
            //errStudentManual = ERR_STUDENT_MANUAL;
        }
    }
    public void astCateringSelected()
    {
        errAstCatering='';
        if ('Yes'.equals(ucr.Assistance_with_Catering_Required__c)) 
        {
            if(String.isNotBlank(ucr.Venue_Country__c) && !countrySet.contains(ucr.Venue_Country__c) && 'No'.equals(ucr.Assistance_with_Venue_Required__c) ) {
                errAstCatering = ERR_CATERING;//'Assistance with catering can be provided only in north America.';
                isValidate = false;
            }
            renderedCatering='T';
        }
        else 
        {
            ucr.Catering_Notes__c ='';
            renderedCatering ='F';
        }
    }
    
    public void astStudentManualSelected()
    {
        errStudentManual='';
        if ('Yes'.equals(ucr.Student_Manuals_Required__c))
        {
            if(String.isNotBlank(ucr.Pickup_Country__c) && !countrySet.contains(ucr.Pickup_Country__c) &&  'No'.equals(ucr.Assistance_with_Venue_Required__c)) {
                errStudentManual = ERR_STUDENT_MANUAL;
                isValidate = false;
            }
            renderedStudentManual='T';
        }
        else if('No'.equals(ucr.Student_Manuals_Required__c))
        {
            renderedStudentManual ='F';
            ucr.Pickup_Location_Name__c='';
            ucr.Name_of_Person_Picking_Up__c='';
            ucr.Phone_of_Person_Picking_Up__c='';
            ucr.Pickup_Street__c='';
            ucr.Pickup_City__c='';
            ucr.Pickup_State__c='';
            ucr.Pickup_Zip__c='';
            ucr.Pickup_Country__c='';
        }
    }
    
    public PageReference doSave()
    {
        isValidate = true;
        if(validate()){
            try{
                ucr.Expected_course_size__c = Integer.valueOf(expectedSize);
                upsert ucr;
                refreshPage=true;
                return null;
            }
            catch(Exception e){
                isValidate = false;
                String errorMessage = e.getMessage();
                system.debug('>>>>> errorMessage'+errorMessage);
            }
        }
        return null;
    }
    
    public PageReference Cancel()
    {
        String retURL = ApexPages.currentPage().getParameters().get('ru');
        if(retURL != null )
        {
            if(retURL =='t'){
                PageReference uc = Page.UniversityCourseRequest;
                uc.getParameters().put('action', 'view');
                uc.getParameters().put('id', ucr.id);
                uc.setRedirect(true);
                system.debug('');
                return uc;
            }
            else return new PageReference(retURL);
        }
        
        //navigate to object listview
        return new PageReference('/a3G');
    }
    
    public PageReference doEdit()
    {
        PageReference uc = Page.UniversityCourseRequest;
        uc.getParameters().put('action', 'edit');
        uc.getParameters().put('id', ucr.id);
        uc.getParameters().put('ru', 't');
        uc.setRedirect(true);
        return uc;
    }
    
    public PageReference DeleteObj()
    {
        delete ucr;
        return new PageReference('/a3G');
    }
    
    public Boolean validate()
    {
        isValidate=true;
        String errorMessage = 'Error: You must enter a value';
        if(ucr.Desired_Course_Start_Date__c==null )
        {   
            isValidate = false;
            errStartDate =errorMessage;
        }else errStartDate ='';
        System.debug('>>>>>errStartDate: '+isValidate);
        desiredDateChange();
        if(ucr.Desired_Course_Start_Date__c == null){
            isValidate = false;
            errStartDate = errorMessage;
        }
        
        astVenueSelected();
        if(String.isNotBlank(errAstVenue))isValidate = false;
        /*
        if(ucr.CreatedDate!=null)
        {
            if(Date.newInstance(ucr.Desired_Course_Start_Date__c.year(),ucr.Desired_Course_Start_Date__c.month(), ucr.Desired_Course_Start_Date__c.day() ) 
                < Date.newInstance(ucr.CreatedDate.year(), ucr.CreatedDate.month(), ucr.CreatedDate.day()))//system.TODAY())
            {
                isValidate = false;
                errStartDate = ERR_DESIREDATE;//'Desired Course Start Date cannot be in the past.';
            }
            else errStartDate ='';
        }
        */
        
        errStartTime ='';
        if(ucr.Desired_Course_Start_Time_p__c==null || ucr.Desired_Course_Start_Time_p__c=='')
        {
            isValidate = false;
            errStartTime =errorMessage;
        }
        
        /*errRequestedInstructor ='';
        if(ucr.Requested_Instructor__c == null)
        {   
            isValidate = false;
            errRequestedInstructor =errorMessage;
        } 
        errSecondInstructor ='';
        if((ucr.Requested_Instructor__c != null) && (ucr.Requested_Instructor__c == ucr.Second_Instructor__c))
        {
            isValidate = false;
            errSecondInstructor ='The Requested Instructor and the Second Instructor cannot be the same person.';
        }
        */
        errRequestedInstructor ='';
        if(ucr.Requested_University_Instructor1__c == null)
        {   
            isValidate = false;
            errRequestedInstructor =errorMessage;
        } 
        //check to not allow Requested University Instructor = Second University Instructor.
        err2ndUniverInstructor = '';
        if(ucr.Requested_University_Instructor1__c != null && ucr.Second_University_Instructor1__c != null && ucr.Requested_University_Instructor1__c == ucr.Second_University_Instructor1__c){
            isValidate = false;
            err2ndUniverInstructor ='The Requested University Instructor and the Second University Instructor cannot be the same person.';
        }
        errClassType ='';
        if(String.isBlank(ucr.Class_Type__c))
        {
            isValidate = false;
            errClassType = ERR_SELECTOPTION;
        }
        errAEName ='';
        if(String.isBlank(ucr.AE_Name__c))
        {
            isValidate = false;
            errAEName =errorMessage;
        } 
        errSEName ='';
        if(String.isBlank(ucr.SE_Name__c))
        {   
            isValidate = false;
            errSEName =errorMessage;
        } 
        errAstCatering ='';
        if(String.isBlank(ucr.Assistance_with_Catering_Required__c))
        {
            isValidate = false;
            errAstCatering = ERR_SELECTOPTION;
        }
        else if(String.isNotBlank(ucr.Pickup_Country__c) && ucr.Assistance_with_Catering_Required__c =='Yes' && !countrySet.contains(ucr.Pickup_Country__c) )
        {
            isValidate = false;
            errAstCatering = ERR_CATERING;
        }
        /*if(renderedCatering=='T'){
            errCateringNote ='';
            if(ucr.Catering_Notes__c ==null || ucr.Catering_Notes__c =='')
            {
                isValidate = false;
                errCateringNote =errorMessage;
            } 
        }*/
        errAstVenue ='';
        if(String.isBlank(ucr.Assistance_with_Venue_Required__c))
        {
            isValidate = false;
            errAstVenue = ERR_SELECTOPTION;
        } 
        if('T'.equals(renderedVenue)){
            errPreferredLocation ='';
            if(String.isBlank(ucr.Preferred_Locations__c))
            {
                isValidate = false;
                errPreferredLocation =errorMessage;
            } 
            errPreferredLocation2 ='';
            if(String.isBlank(ucr.Preferred_Location_2__c))
            {
                isValidate = false;
                errPreferredLocation2 =errorMessage;
            } 
            errPreferredLocation3 ='';
            if(String.isBlank(ucr.Preferred_Location_3__c))
            {
                isValidate = false;
                errPreferredLocation3 =errorMessage;
            } 
        }
        if('F'.equals(renderedVenue)){
            errVenueName ='';
            if(String.isBlank(ucr.Venue_Name__c))
            {
                isValidate = false;
                errVenueName = errorMessage;
            } 
            errVenueAirport ='';
            if(String.isBlank(ucr.Venue_Airport_Code_Manual__c))
            {
                isValidate = false;
                errVenueAirport = errorMessage;
            }
            else if (ucr.Venue_Airport_Code_Manual__c!=null && !Pattern.matches('[A-Z]{3}',ucr.Venue_Airport_Code_Manual__c))
            {   
                isValidate = false;
                errVenueAirport ='Airport Code must be 3 capital letters.';
            }
            errVenueStreet ='';
            if(String.isBlank(ucr.Venue_Street__c))
            {
                isValidate = false;
                errVenueStreet =errorMessage;
            } 
            errVenueCity = '';
            if(String.isBlank(ucr.Venue_City__c))
            {   
                isValidate = false;
                errVenueCity =errorMessage;
            } 
            errVenueState = '';
            if(String.isBlank(ucr.Venue_State__c))
            {   
                isValidate = false;
                errVenueState =errorMessage;
            } 
            errVenueZip = '';
            if(String.isBlank(ucr.Venue_Zip__c))
            {
                isValidate = false;
                errVenueZip =errorMessage;
            } 
            errVenueCountry = '';
            if(String.isBlank(ucr.Venue_Country__c))
            {
                isValidate = false;
                errVenueCountry =errorMessage;
            } 
            errRoomCapacity = '';
            if(String.isBlank(roomCapacity))
            {
                isValidate = false;
                errRoomCapacity =errorMessage;
            }
            else if (!String.valueOf(roomCapacity.trim()).isNumeric())
            {   
                isValidate = false;
                errRoomCapacity ='Error: Invalid number';
            }
        }
        errProjector = '';
        if(String.isBlank(ucr.Projector_Required__c))
        {   
            isValidate = false;
            errProjector = ERR_SELECTOPTION;
        } 
        system.debug('Student_Manuals_Required__c '+ucr.Student_Manuals_Required__c);
        errStudentManual ='';
        if(String.isBlank(ucr.Student_Manuals_Required__c))
        {
            isValidate = false;
            errStudentManual = 'Error: You must select an option.';
            system.debug('errStudentManual '+errStudentManual);
        }
        else if(String.isNotBlank(ucr.Pickup_Country__c) && !countrySet.contains(ucr.Pickup_Country__c) && 'Yes'.equals(ucr.Student_Manuals_Required__c))
        {
            isValidate = false;
            errStudentManual =ERR_PICKUP_COUNTRY;
        }
         
        if('T'.equals(renderedStudentManual)){
            errPickupPerson = '';
            if(String.isBlank(ucr.Name_of_Person_Picking_Up__c))
            {
                isValidate = false;
                errPickupPerson =errorMessage;
            } 
            errPickupPhone = '';
            if(String.isBlank(ucr.Phone_of_Person_Picking_Up__c))
            {
                isValidate = false;
                errPickupPhone =errorMessage;
            } 
            errPickupZip = '';
            if(String.isBlank(ucr.Pickup_Zip__c))
            {
                isValidate = false;
                errPickupZip =errorMessage;
            } 
            errPickupCountry ='';    
            if(String.isBlank(ucr.Pickup_Country__c)){
                
                isValidate = false;
                errPickupCountry = errorMessage;
            } 
            errPickupState = '';
            if(String.isBlank(ucr.Pickup_State__c)){
                isValidate = false;
                errPickupState = errorMessage;
            }
            errPickupCity = '';
            if(String.isBlank(ucr.Pickup_City__c)){
                isValidate = false;
                errPickupCity = errorMessage;
            }
            errPickupStreet = '';
            if(String.isBlank(ucr.Pickup_Street__c)){
                isValidate = false;
                errPickupStreet = errorMessage;
            }
            errPickupLocation = '';
            if(String.isBlank(ucr.Pickup_Location_Name__c)){
                isValidate = false;
                errPickupLocation = errorMessage;
            }
        }
        /*
        System.debug('>>>>>renderedStudentManualT: '+isValidate);
        if(ucr.Room_Capacity__c != null && ucr.Expected_course_size__c != null && ucr.Room_Capacity__c<ucr.Expected_course_size__c){
            isValidate = false;
            errRoomCapacity = ERR_ROOM_CAPACITY;
        }
        else errRoomCapacity ='';
        */
        errExpectedCourseSize = '';
        if(String.isBlank(expectedSize))//(ucr.Expected_course_size__c == null )
        {
            isValidate = false;
            errExpectedCourseSize = 'Error: You must enter a value';
        }
        else if ((!String.valueOf(expectedSize.trim()).isNumeric()))
        {
            isValidate = false;
            errExpectedCourseSize = 'Error: You must enter a number';
        }
        if(ucr.Course_Requested__c == null){
            isValidate = false;
            errCourseRequested = 'Error: You must enter a number';
        }else{
            errCourseRequested = '';
        }
        errExpectedCourseSize = '';
        expectedCauseSizeChange();
        if(String.isNotBlank(errExpectedCourseSize))isValidate = false;
        
        venueCountryChange();
        if(String.isNotBlank(errAstCatering))isValidate = false;
        if(String.isBlank(ucr.Assistance_with_Venue_Required__c)){
            isValidate = false;
            errAstCatering = ERR_SELECTOPTION;
        }
        
        return isValidate;
    }
    public List<SelectOption> getCourseRequested(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = University_Course_Request__c.Course_Requested__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(),f.getLabel()));
        }       
        return options;
    }
    public void validateAirport3Letters(){
        if (ucr.Venue_Airport_Code_Manual__c!=null && !Pattern.matches('[A-Z]{3}',ucr.Venue_Airport_Code_Manual__c))
        {   
                isValidate = false;
                errVenueAirport ='Airport Code must be 3 capital letters.';
         }
         else errVenueAirport ='';
    }
    public void expectedCauseSizeChange(){
        errExpectedCourseSize = '';
        if(!expectedSize.trim().isNumeric()){
            errExpectedCourseSize = 'Error: Invalid number';
        }else{
            Integer expectSizeTmp = Integer.valueOf(expectedSize.trim());
            // check the “Expected Course Size” field, that if the number entered is >20, display error
            if(!ucr.Large_Course__c && expectSizeTmp > 20){
                errExpectedCourseSize = ERR_EXPECTED_COURSE_SIZE_GT_20 + ' <br/><br/>';
            }
            
            //check minimun
            if(expectSizeTmp < 6){
                errExpectedCourseSize = ERR_EXPECTED_COURSE_SIZE_LT_6 + ' <br/>';
            }
            
            if('No'.equals(ucr.Assistance_with_Venue_Required__c) && String.isNotBlank(roomCapacity)){
                Integer roomCapacityTmp = Integer.valueOf(roomCapacity.trim());
                if(expectSizeTmp > roomCapacityTmp){
                    errExpectedCourseSize += 'The room capacity is too small for the expected course size.';
                }else{
                    errRoomCapacity = '';
                }
            }
        }
    }
    public String getLargeCourseWarning(){
        if(largeCourseWarning == null){
            Schema.DescribeFieldResult dfr = University_Course_Request__c.Large_Course_Warning__c.getDescribe();
            largeCourseWarning = dfr.getDefaultValueFormula()+'';
            largeCourseWarning = largeCourseWarning.subString(1,largeCourseWarning.length()-1); 
        }
        return largeCourseWarning;
    }
    
    public String getCourseReqRes(){
        if(courseReqRes == null){
            Schema.DescribeFieldResult dfr = University_Course_Request__c.Course_Request_Response_SLA__c.getDescribe();
            courseReqRes = dfr.getDefaultValueFormula()+'';
            courseReqRes = courseReqRes.subString(1,courseReqRes.length()-1);   
        }
        return courseReqRes;
    }
    
    public String getConWarning(){
        if(conWarning == null){
            Schema.DescribeFieldResult dfr = University_Course_Request__c.Connectivity_Warning__c.getDescribe();
            conWarning = dfr.getDefaultValueFormula()+'';
            conWarning = conWarning.subString(1, conWarning.length()-1);
        }
        return conWarning;
    }
}