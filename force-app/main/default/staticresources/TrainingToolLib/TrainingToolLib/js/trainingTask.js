(function() {         
    currentUser = jQuery.parseJSON(currentUser);
    userPath = jQuery.parseJSON(userPath);      
    var taskApp = angular.module('taskApp', []);
    taskApp.controller('taskController', ['$scope', function($scope) {
        function loadHiearchyPath() {
            if(userPath.length > 0) {
                userPathDiv = jQuery('#userPath');
                var breadcrumb = jQuery('<ol class="breadcrumb"></ol>');
                userPathDiv.append(breadcrumb);
                breadcrumb.append(jQuery('<li><a href="' + pageUrl + '">Home</a></li>'));

                var path = '';
                var nodeUrl;             
                angular.forEach(userPath, function(user, key) {                    
                    path += '/' + user.Id;
                    nodeUrl = pageUrl + '?uid=' + user.Id + '&path=' + path;
                    breadcrumb.append(jQuery('<li><span>/</span><a href="' + nodeUrl + '">' + user.Name + '</a></li>'));
                });
            }
        }
        function loadMessage() {
            var division = currentUser.TrainingDivision__c;
            console.log(division);
            if(division === undefined) {
                $scope.message = [];
            }
            else {
                TrainingTaskController.getMessageByDivision(division, function(result, event) {
                    if(event.status) {
                        $scope.messages = result;
                        $scope.$apply($scope.messages);                            
                    }
                },
                {escape: false});
            }
        }
        function loadTask() {
            var userId = currentUser.Id;
            TrainingTaskController.getTasksByUser(userId, function(result, event) {
                if(event.status) {
                    $scope.taskWrapper = result;               
                    $scope.$apply($scope.taskWrapper);    
                    jQuery('.bootstrap-link:first').tab('show');                       
                }
            },
            {escape: false});
        }
        function loadTeamTaskSummary() {
            var userRoleId = currentUser.UserRoleId;
            if(userRoleId === undefined) {
                $scope.teamTaskSummaries = [];
            }
            else {                        
                TrainingTaskController.getTeamTaskSummary(userRoleId, function(result, event) {
                    if(event.status) {
                        $scope.teamTaskSummaries = result;                        
                        $scope.$apply($scope.teamTaskSummaries);                     
                    }
                },
                {escape: false});
            }
        }
        function updateTasksProgress(wrapper) {
            if(wrapper.TotalOpened == 0) {
                wrapper.Progress = 100;
            }
            else {
                wrapper.Progress = Math.round(100 * wrapper.TotalCompleted / (wrapper.TotalOpened + wrapper.TotalCompleted));
            }     
            if(wrapper.ClassName != 'status-gray') {
                if(wrapper.TotalOpened == 0) {
                    wrapper.ClassName = 'status-success';
                }          
                else {
                    wrapper.ClassName = 'status-warning';
                    angular.forEach(wrapper.Tasks, function(task, key) {
                        if(task.IsDue) {
                            wrapper.ClassName = 'status-danger';
                        }
                    });
                } 
            }                
        }
        $scope.init = function() {                    
            loadHiearchyPath();
            loadMessage();
            loadTask();
            loadTeamTaskSummary();                    
        }; 

        $scope.closeTask = function(wrapper, task) {   
            var recordId = task.RecordId;
            TrainingTaskController.closeTask(recordId, function(result, event) {
                if(event.status) {
                    task.Status = 'Complete';
                    task.Filter = 'Completed';
                    task.IsDue = false;                            
                    wrapper.TotalOpened--;
                    wrapper.TotalCompleted++;
                    updateTasksProgress(wrapper);                         
                    $scope.$apply($scope.taskWrapper);
                }
            });
        };

        $scope.drillDown = function(userId) {
            var path = '';
            var search = window.location.search;
            var index = search.indexOf('&path=');
            if(index > -1) {
                path = search.substring(index+6);
            }
            window.location.href = pageUrl + '?uid=' + userId + '&path=' + path + '/' + userId;
            return false;
        }

        $scope.init();
    }]);
})();