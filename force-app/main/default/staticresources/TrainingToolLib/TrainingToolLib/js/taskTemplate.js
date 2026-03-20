var fileBody, fileName, fileSize;
var chunkSize = 950000;
var positionIndex;
var doneUploading;

(function() {               
    jQuery(function() {
        jQuery('#chooseFile').click(function(event) {
            document.getElementById('fileInput').click();                        
        });

        jQuery('#fileInput').change(function(event) {  
            if(this.files.length == 0) {
                document.getElementById('fileName').innerHTML = '';
            }
            else {
                document.getElementById('fileName').innerHTML = this.files[0].name;
            }
        });
    });            

    var ttApp = angular.module('ttApp', []);
    ttApp.controller('ttController', ['$scope', function($scope) {
        $scope.init = function() {
            // init page control
            $scope.control = {};                    
            $scope.control.showEditMsg = false;
            $scope.control.showEditTemplate = false;
            // init divison options
            $scope.divisionOptions = angular.fromJson(divisions);                    
            $scope.selectedDivision = $scope.divisionOptions[0];
            // init messages                    
            $scope.messages = angular.fromJson(messages);  
            $scope.taskTemplates = angular.fromJson(templates);
            console.log($scope.taskTemplates);
        };        

        $scope.filterMessage = function(message) {
            return $scope.selectedDivision.Value == 'All' || message.Division == $scope.selectedDivision.Value || message.ForAllDivisions;
        };

        $scope.cancelEditMessage = function() {
            $scope.control.showEditMsg = false;
            jQuery('.message-error').text('').hide();
        }

        $scope.newMessage = function() {                    
            $scope.message = {};
            if($scope.selectedDivision.Value == 'All') {
                $scope.message.ForAllDivisions = true;
            }
            else {
                $scope.message.Division = $scope.selectedDivision.Value;
            }                    
            $scope.control.showEditMsg = true;
        };

        $scope.editMessage = function(selectedMessage) {
            $scope.message = selectedMessage
            $scope.control.showEditMsg = true;                  
        };

        $scope.deleteMessage = function(message) {    
            jQuery('.message-status').show();                      
            var recordId = message.RecordId;
            TaskTemplateController.deleteRecord(recordId, function(result, event) {
                if(event.status) {
                    var index = jQuery.inArray(message, $scope.messages);
                    $scope.messages.splice(index, 1);
                    jQuery('.message-status').hide();
                    jQuery('.message-error').text('').hide();
                    $scope.$apply($scope.messages);
                }
                else {
                    jQuery('.message-status').hide();
                    jQuery('.message-error').text(event.message).show();
                }
            });                    
        };

        $scope.saveMessage = function() {
            jQuery('.message-status').show();
            var message = angular.copy($scope.message);  
            TaskTemplateController.saveMessage(message, function(result, event) {
                if(event.status) {
                    if($scope.message.RecordId === undefined) {
                        $scope.message.RecordId = result;
                        $scope.messages.push($scope.message);
                    }
                    else {
                        $scope.filteredMsgs[$scope.$index] = $scope.message;
                    }
                    $scope.control.showEditMsg = false;                            
                    jQuery('.message-status').hide();
                    jQuery('.message-error').text('').hide();
                    $scope.$apply($scope.control);
                }
                else {
                    jQuery('.message-status').hide();
                    jQuery('.message-error').text(event.message).show();
                }
            });
        };  

        $scope.switchMessageDivision = function() {
            if($scope.message.ForAllDivisions) {
                $scope.message.Division = '';                        
            }
            else {
                if($scope.selectedDivision.Value != 'All') {
                    $scope.message.Division = $scope.selectedDivision.Value;
                }                        
            }
        };
        $scope.switchTemplateDivision = function() {
            if($scope.template.ForAllDivisions) {
                $scope.template.Division = '';                        
            }
            else {
                if($scope.selectedDivision.Value != 'All') {
                    $scope.template.Division = $scope.selectedDivision.Value;
                }                        
            }
        };

        $scope.filterTemplate = function(template) {
            return $scope.selectedDivision.Value == 'All' || template.Division == $scope.selectedDivision.Value || template.ForAllDivisions;
        };

        $scope.cancelEditTemplate = function() {
            $scope.control.showEditTemplate = false;
            jQuery('.template-error').text('').hide();
        }

        $scope.newTemplate = function() {                    
            $scope.template = {};
            if($scope.selectedDivision.Value == 'All') {
                $scope.template.ForAllDivisions = true;
                $scope.template.Division = '';
            }
            else {
                $scope.template.ForAllDivisions = false;
                $scope.template.Division = $scope.selectedDivision.Value;
            }        
            $scope.template.ExistingUsersWillReceiveThisTask = false;            
            $scope.control.showEditTemplate = true;
        };

        $scope.editTemplate = function(template) {
            $scope.template = template;
            $scope.control.showEditTemplate = true;                  
        };        

        $scope.deleteTemplate = function(template) {     
            jQuery('.template-status').show();
            var recordId = template.RecordId;
            TaskTemplateController.deleteRecord(recordId, function(result, event) {
                if(event.status) {
                    var index = jQuery.inArray(template, $scope.taskTemplates);
                    $scope.taskTemplates.splice(index, 1);
                    jQuery('.template-status').hide();
                    jQuery('.template-error').text('').hide();                         
                    $scope.$apply($scope.taskTemplates);
                }
                else {
                    jQuery('.template-status').hide();
                    jQuery('.template-error').text(event.message).show();
                }
            });                    
        };

        $scope.changeSortOrder = function(template) {            
            var templateId = template.RecordId;
            var sortOrder = template.SortOrder;
            if(sortOrder == '') {
                sortOrder = null;
            }                
            TaskTemplateController.changeSortOrder(templateId, sortOrder, function(result, event) {
                
            });
        }

        $scope.saveTemplate = function() {
            jQuery('.template-status').show();
            if($scope.template.Division === undefined) {
                $scope.template.Division = $scope.selectedDivision.Value;
            }
            var template = angular.copy($scope.template);
            if(template.SeatTime == '') {
                template.SeatTime = null;
            }
            TaskTemplateController.saveTemplate(template, function(result, event) {
                if(event.status) {                            
                    if($scope.template.RecordId === undefined) {
                        $scope.template.RecordId = result;
                        $scope.taskTemplates.push($scope.template);
                    }
                    else {
                        $scope.filteredTemplates[$scope.$index] = $scope.template;
                    }
                    var fileInput = document.getElementById('fileInput');
                    var files = fileInput.files;
                    if(files.length > 0) {
                        uploadFile(result, files[0]);
                    }
                    else {
                        jQuery('.template-status').hide();
                        jQuery('.template-error').text('').hide();
                        $scope.control.showEditTemplate = false;
                        $scope.$apply($scope.taskTemplates); 
                    }                       
                }
                else {
                    jQuery('.template-status').hide();
                    jQuery('.template-error').text(event.message).show();
                }
            },
            {escape: false, timeout: 120000});
        };  

        $scope.deleteAttachment = function(template, attachment) {
            jQuery('.template-status').show();
            var recordId = attachment.RecordId;
            TaskTemplateController.deleteRecord(recordId, function(result, event) {
                if(event.status) {
                    var index = jQuery.inArray(attachment, template.Attachments);
                    template.Attachments.splice(index, 1);                            
                    jQuery('.template-status').hide();
                    jQuery('.template-error').text('').hide();                            
                    $scope.$apply($scope.templates);
                }
                else {
                    jQuery('.template-status').hide();
                    jQuery('.template-error').text(event.message).show();
                }
            });  
        }

        $scope.init();
        function uploadFile(parentId, file) {
            var reader = new FileReader();
            reader.onload = function(e) {
                fileBody = window.btoa(reader.result);
                fileName = file.name;
                fileSize = fileBody.length;
                positionIndex = 0;
                doneUploading = false;
                uploadAttachment(parentId, '');
            };                      
            reader.readAsBinaryString(file);
        }
        function uploadAttachment(parentId, attachmentId) {
            var attachmentBody = '';
            if(fileSize <= positionIndex + chunkSize) {
                attachmentBody = fileBody.substring(positionIndex);
                doneUploading = true;
            } else {
                attachmentBody = fileBody.substring(positionIndex, positionIndex + chunkSize);
            }
            TaskTemplateController.uploadFile(parentId, fileName, attachmentBody, attachmentId, 
            function(result, event) {
                if(event.status) {
                    if(doneUploading) {
                        var newAttachment = {};
                        newAttachment.RecordId = result;
                        newAttachment.RecordName = fileName;
                        if($scope.template.Attachments === undefined) {
                            $scope.template.Attachments = new Array();
                        }                             
                        $scope.template.Attachments.push(newAttachment);

                        jQuery('.template-status').hide();
                        jQuery('.template-error').text('').hide();
                        $scope.control.showEditTemplate = false;        
                        document.getElementById('fileInput').value = '';
                        document.getElementById('fileName').innerHTML = '';
                        $scope.$apply($scope.taskTemplates);
                    }
                    else {
                        positionIndex += chunkSize;
                        uploadAttachment(parentId, result);
                    }
                }
                else {
                    jQuery('.template-status').hide();
                    jQuery('.template-error').text(event.message).show();
                }
            },
            {timeout: 120000});
        }
    }]);
})();