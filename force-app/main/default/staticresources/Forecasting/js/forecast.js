(function() {
angular.module('forecastingApp', ['ngAnimate', 'ngStorage'])
     .controller('forecastingCtrl', function($scope, $q, $timeout, $localStorage, $sessionStorage, $rootScope) {
        $scope.currentWeek = currentWeek;
        $scope.weeks = weeks;
        $scope.fiscalQtr = fiscalQtr;
        $scope.path = userPath;
        $scope.forecastEnabled = forecastEnabled;
        $scope.forecastEditable = forecastEditable;
        $scope.currentUser = currentViewingUserId;
        $scope.forecastLevel = forecastLevel;
        $scope.directSubUsers = [];
        $scope.isManager = (forecastLevel != 'Level 1');

        $scope.$storage = $localStorage.$default({
                                                 teamSection1Collapsed: false,
                                                 teamSection2Collapsed: false,
                                                 teamSection3Collapsed: false,
                                                 oppSectionCollapsed: false,
                                                 oppFilter: {
                                                    pageIndex: 1,
                                                    pageSize: 50,
                                                    stage: 'All',
                                                    probability: '',
                                                    closeDate: 'This Quarter',
                                                    status: 'All',
                                                    salesRegion: 'All',
                                                    forecastCategory: 'All',
                                                    sortField: 'CloseDate',
                                                    isAscendingOrder: true,
                                                    enableRedFlag: true,
                                                    excludeFromBookings: false
                                                 }
                                                });

        $scope.$storage.oppFilter.pageIndex = 1;
        $scope.calloutErrorOccured = false;
        $scope.userCancel = false;
        $scope.requestInProgress = 0;
        $scope.errorMessage = null;
        $scope.displayFormat = "W";
        $scope.showQuota = false;

        $scope.forecastSummary = { isLoading: false, isEditing: false, data: {}, collapsed: false };
        $scope.teamRepTotal = { isLoading: false };
        $scope.teamForecasts = { isLoading: false, data: [], total: {}, collapsed: false };
        $scope.opportunityListing = {
                                        isLoading: false,
                                        data: [],
                                        collapsed: false,
                                        pageIndex: 1,
                                        pageCount: 1,
                                        recordCount: 0,
                                        totalAmount: 0,
                                        hasPrevious: false,
                                        hasNext: false,
                                        filter: $scope.$storage.oppFilter
                                    };


        $scope.promiseDirectSubUsers = function(userId) {
            var deferred = $q.defer();
            var serviceIdentifier = "DirectSubUsers" + userId;
            $scope.callRemoteServiceWithCache(ForecastingController.GetDirectSubordinateUsers, [userId], serviceIdentifier, function(result) {
                deferred.resolve({userId: userId, subUsers: result});
            });
            return deferred.promise;
        };

        $scope.getCacheValue = function(key, defaultValue) {
            if(typeof(Storage)!=="undefined") {
                key = "SNAPF." + key;
                var value = sessionStorage.getItem(key);
                if(value == null) {
                    return defaultValue;
                }
                return JSON.parse(value);
            } else {
                return defaultValue;
            }
        }

        $scope.setCacheValue = function(key, value) {
            if(typeof(Storage)!=="undefined") {
                key = "SNAPF." + key;
                try {
                    return sessionStorage.setItem(key, JSON.stringify(value));
                } catch(err) {
                    sessionStorage.removeItem(key);
                }
            }
        }

        $scope.callRemoteServiceWithCache = function(serviceName, parameters, identifier, callback, config) {
            $scope.requestInProgress++;
            //console.log($scope.requestInProgress);
            var cachedValue = $scope.getCacheValue(identifier, null);
            if(cachedValue != null) {
                callback.call($scope, cachedValue);
            }
            if(parameters == null) {
                parameters = [];
            }
            var callbackWrap = function(result, event) {
                $scope.requestInProgress--;
                //console.log($scope.requestInProgress);
                if($scope.isCalloutSucceeded(event)) {
                    $scope.setCacheValue(identifier, result);
                    callback.call($scope, result);
                }
                if($scope.requestInProgress == 0) {
                  $rootScope.$broadcast('ForecastInitialized');
                }
            };
            parameters.push(callbackWrap);
            if(config) {
                parameters.push(config);
            }
            try {
                serviceName.apply($scope, parameters);
            } catch(e) {
                callbackWrap(null, {status: false});
            }
        };

        $scope.isCalloutSucceeded = function(event) {
            if(event.status == true) {
                return true;
            }
            else  {
                if($scope.calloutErrorOccured == false && $scope.userCancel == false)  {
                    $scope.errorMessage = "Error occured. Please try refreshing the page.";
                    $scope.$apply($scope.errorMessage);
                }
                $scope.calloutErrorOccured = true;
                return false;
            }
        };

        $scope.openChart = function(srcTag){
            window.open('/apex/ForecastingChart?userId=' + $scope.currentUser + '&quarter='+ $scope.fiscalQtr+'&userName=' + window.encodeURIComponent($scope.forecastSummary.data.UserName), 'ForecastChart','left=100,top=100,scrollbars=yes,toolbar=no');
        };
        $scope.toggleQuota = function() {
            $scope.showQuota = !$scope.showQuota;
            if($scope.showQuota) {
              $(".quota").css("display", "");
              $("#quotaToggleBtn").addClass("on");
              //$.freeze();
            }
            else {
              $(".quota").css("display", "none");
              $("#quotaToggleBtn").removeClass("on");
            }
        }
        $scope.loadForecastSummary = function() {
            $scope.forecastSummary.isLoading = true;
            var serviceIdentifier = "Summary" + $scope.fiscalQtr + $scope.currentUser;
            $scope.callRemoteServiceWithCache(ForecastingStatsService.GetForecastSummary, [$scope.currentUser, $scope.fiscalQtr, true], serviceIdentifier, function(result) {
                $scope.forecastSummary.isLoading = false;
                $scope.forecastSummary.data = result;
                setTimeout(function(){ $scope.$apply($scope.forecastSummary); });
            }, { buffer: false, timeout: 60000 });
        }

        $scope.loadTeamForecasts = function() {
            for(var i = 0; i < $scope.directSubUsers.length; i++) {
                $scope.teamForecasts.isLoading = true;
                var uid = $scope.directSubUsers[i].UserId;
                var serviceIdentifier = "Summary" + $scope.fiscalQtr + uid;
                $scope.callRemoteServiceWithCache(ForecastingStatsService.GetForecastSummary, [uid, $scope.fiscalQtr, true], serviceIdentifier, function(result) {
                    var isExisted = false;
                    for(var i = 0; i < $scope.teamForecasts.data.length; i++)  {
                        if($scope.teamForecasts.data[i].UserId == result.UserId) {
                            $scope.teamForecasts.data[i] = angular.copy(result);
                            isExisted = true;
                            break;
                        }
                    }
                    if(!isExisted) {
                        $scope.teamForecasts.data.push(angular.copy(result));
                    }

                    $scope.teamForecasts.total = {};
                    for(var i = 0; i < $scope.teamForecasts.data.length; i++) {
                        var member = $scope.teamForecasts.data[i];
                        var total = $scope.teamForecasts.total;
                        for(var field in member) {
                            if(typeof(member[field]) == "number") {
                                if(!total[field]) {
                                    total[field] = member[field];
                                }
                                else {
                                    total[field] += member[field];
                                }
                            }
                        }
                    }
                    $scope.teamForecasts.isLoading = false;
                    setTimeout(function(){ $scope.$apply($scope.teamForecasts); });
                }, { buffer: false, timeout: 60000 });
            }
        }

        $scope.loadTeamRepTotal = function() {
            $scope.teamRepTotal.isLoading = true;
            var serviceIdentifier = "RepTotal" + $scope.fiscalQtr + $scope.currentUser;
            $scope.callRemoteServiceWithCache(ForecastingStatsService.GetTeamRepTotal, [$scope.currentUser, $scope.fiscalQtr], serviceIdentifier, function(result) {
                $scope.teamRepTotal.isLoading = false;
                $scope.teamForecasts.repTotal = result;
                setTimeout(function(){ $scope.$apply($scope.teamForecasts); });
            }, { buffer: false, timeout: 60000 });
        }

        $scope.loadOpportunityListing = function() {
            $scope.opportunityListing.isLoading = true;
            var request = { UserId: $scope.currentUser,
                            FiscalQtr: $scope.fiscalQtr,
                            PageIndex: $scope.$storage.oppFilter.pageIndex,
                            Stage: $scope.$storage.oppFilter.stage,
                            Probability: $scope.$storage.oppFilter.probability,
                            CloseDate: $scope.$storage.oppFilter.closeDate,
                            Status: $scope.$storage.oppFilter.status,
                            SalesRegion: $scope.$storage.oppFilter.salesRegion,
                            ForecastCategory: $scope.$storage.oppFilter.forecastCategory,
                            SortField: $scope.$storage.oppFilter.sortField,
                            IsAscendingOrder: $scope.$storage.oppFilter.isAscendingOrder,
                            PageSize: $scope.$storage.oppFilter.pageSize,
                        };

                ForecastingStatsService.GetOpportunityListing(request, function(result, event) {
                    $scope.opportunityListing.isLoading = false;
                    if($scope.isCalloutSucceeded(event)) {
                        $scope.opportunityListing.data = result.Opportunities;
                        $scope.opportunityListing.hasPrevious = result.HasPrevious;
                        $scope.opportunityListing.hasNext = result.HasNext;
                        $scope.opportunityListing.pageCount = result.PageCount;
                        $scope.opportunityListing.pageIndex = result.PageIndex;
                        $scope.opportunityListing.pagers = $scope.buildArray(result.PageCount);
                        $scope.opportunityListing.recordCount = result.RecordCount;
                        $scope.opportunityListing.totalAmount = result.TotalAmount;
                        $scope.$apply($scope.opportunityListing);
                    }
                });
        }
        $scope.turnPageOppList = function(pageIndex) {
            $scope.opportunityListing.filter.pageIndex = pageIndex;
            $scope.loadOpportunityListing();
        };
        $scope.sortOppList = function(sortField) {
            if($scope.opportunityListing.filter.sortField === sortField) {
                $scope.opportunityListing.filter.isAscendingOrder = !$scope.opportunityListing.filter.isAscendingOrder;
            }
            $scope.opportunityListing.filter.sortField = sortField;
            $scope.loadOpportunityListing();
        };
        $scope.editForecast = function() {
            $scope.cancelForecast();
            $scope.forecastSummary.isEditing = true;
            $scope.forecastSummary.editingModal = {
                QtrCommit: $scope.forecastSummary.data.QtrCommit,
                QtrGut: $scope.forecastSummary.data.QtrGut,
                QtrUpside: $scope.forecastSummary.data.QtrUpside,
                Month1Commit: $scope.forecastSummary.data.Month1,
                Month2Commit: $scope.forecastSummary.data.Month2,
                Month3Commit: $scope.forecastSummary.data.Month3,
                UpcomingWeekCommit: $scope.forecastSummary.data.UpcomingWeekCommit,
                FollowingWeekCommit: $scope.forecastSummary.data.FollowingWeekCommit,
                Quota: $scope.forecastSummary.data.Quota,
                C9Projection: $scope.forecastSummary.data.C9Projection

            };
            if($scope.forecastSummary.data.CurrentMonthIndex > 1) {
              $scope.forecastSummary.editingModal.Month2Commit = $scope.forecastSummary.data.Month2Commit;
              $scope.forecastSummary.editingModal.Month3Commit = $scope.forecastSummary.data.Month3Commit;
            }
            else if($scope.forecastSummary.data.CurrentMonthIndex > 2) {
              $scope.forecastSummary.editingModal.Month3Commit = $scope.forecastSummary.data.Month3Commit;
            }
        };

        $scope.cancelForecast = function() {
            $scope.errorMessage = "";
            $scope.forecastSummary.isEditing = false;
        };

        $scope.saveForecast = function() {
            $scope.forecastSummary.editingModal.QtrCommit = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.QtrCommit);
            $scope.forecastSummary.editingModal.QtrGut = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.QtrGut);
            $scope.forecastSummary.editingModal.QtrUpside = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.QtrUpside);
            $scope.forecastSummary.editingModal.Month1Commit = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.Month1Commit);
            $scope.forecastSummary.editingModal.Month2Commit = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.Month2Commit);
            $scope.forecastSummary.editingModal.Month3Commit = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.Month3Commit);
            $scope.forecastSummary.editingModal.UpcomingWeekCommit = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.UpcomingWeekCommit);
            $scope.forecastSummary.editingModal.FollowingWeekCommit = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.FollowingWeekCommit);
            $scope.forecastSummary.editingModal.Quota = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.Quota);
            $scope.forecastSummary.editingModal.C9Projection = $scope.enforceNumberValidated($scope.forecastSummary.editingModal.C9Projection);

            if($scope.forecastSummary.editingModal.QtrUpside >= $scope.forecastSummary.editingModal.QtrGut &&
               $scope.forecastSummary.editingModal.QtrGut >= $scope.forecastSummary.editingModal.QtrCommit &&
               $scope.forecastSummary.editingModal.QtrCommit >= $scope.forecastSummary.data.QTDBooking)
            {
                ForecastingStatsService.SaveForecast(currentViewingUserId, $scope.forecastSummary.editingModal, function(result, event) {
                    if($scope.isCalloutSucceeded(event)) {
                        if(event.status) {
                            var scope = angular.element(jQuery("#ngContainer")).scope();
                            scope.$apply(function() {
                                $scope.forecastSummary.data.QtrCommit = $scope.forecastSummary.editingModal.QtrCommit;
                                $scope.forecastSummary.data.QtrGut = $scope.forecastSummary.editingModal.QtrGut;
                                $scope.forecastSummary.data.QtrUpside = $scope.forecastSummary.editingModal.QtrUpside;
                                $scope.forecastSummary.data.Month1Commit = $scope.forecastSummary.editingModal.Month1Commit;
                                $scope.forecastSummary.data.Month2Commit = $scope.forecastSummary.editingModal.Month2Commit;
                                $scope.forecastSummary.data.Month3Commit = $scope.forecastSummary.editingModal.Month3Commit;
                                $scope.forecastSummary.data.UpcomingWeekCommit = $scope.forecastSummary.editingModal.UpcomingWeekCommit;
                                $scope.forecastSummary.data.FollowingWeekCommit = $scope.forecastSummary.editingModal.FollowingWeekCommit;
                                $scope.forecastSummary.data.Quota = $scope.forecastSummary.editingModal.Quota;
                                $scope.forecastSummary.data.C9Projection = $scope.forecastSummary.editingModal.C9Projection;
                                if($scope.forecastSummary.data.CurrentMonthIndex > 1) {
                                  $scope.forecastSummary.data.Month2 = $scope.forecastSummary.data.Month2Commit;
                                  $scope.forecastSummary.data.Month3 = $scope.forecastSummary.data.Month3Commit;
                                }
                                else if($scope.forecastSummary.data.CurrentMonthIndex > 2) {
                                  $scope.forecastSummary.data.Month3 = $scope.forecastSummary.data.Month3Commit;
                                }
                                var serviceIdentifier = "Summary" + $scope.fiscalQtr + $scope.currentUser;
                                $scope.setCacheValue(serviceIdentifier, $scope.forecastSummary.data);
                                $scope.errorMessage = "";
                            });
                        }
                        else {
                            scope.$apply(function() {
                                $scope.errorMessage = "Failed to save forecast. Please try again.";
                            });
                        }
                    }
                    scope.$apply(function() {
                        $scope.forecastSummary.isEditing = false;
                    });
                });
            } else {
                $scope.errorMessage = "Error: Failed to save forecast. Please make sure Upside >= Gut >= Commit >= Bookings.";
            }
        };

        $scope.viewEditHistory = function(weekInfo, field) {
            var target = event.target;
            var userId = weekInfo.UserId;
            var week = weekInfo.YYWW;
            var quarter = $scope.fiscalQtr;

            ForecastingStatsService.GetEditHistory(userId, quarter, week, field, function(result, event) {
                if(!weekInfo.Histories) {
                    weekInfo.Histories = {};
                }
                weekInfo.Histories[field] = result;
                setTimeout(function(){
                    $scope.$apply($scope.forecastSummary);
                    jQuery(target).find('.history-tooltip').show();
                });
            });
        }

        $scope.enforceNumberValidated = function(value) {
            if(typeof(value) == "string")
            {
                var newValue = value.replace(/\$/g, '').replace(/,/g, '').replace(/[KkMm]$/i, '');
                newValue = parseFloat(newValue);
                if(value.substr(-1) == 'K' || value.substr(-1) == 'k')
                {
                    newValue *= 1000;
                }
                if(value.substr(-1) == 'M' || value.substr(-1) == 'm')
                {
                    newValue *= 1000000;
                }
                return newValue;
            }
            return value;
        };

        $scope.formatDecimal = function(value, format) {
            if(value == null) {
                return null;
            } else if(value == 0) {
                return "0";
            } else if(format == "E") {
                //exact value, 2 decimals
                return "$" + $scope.commaFormatted(((value)/1).toFixed(2));
            } else if(format == "W") {
                //whole values, 0 decimals
                return "$" + $scope.commaFormatted(((value)/1).toFixed(0));
            } else if(format == "K") {
                //thousand, with 2 decimals
                var result = "$" + $scope.commaFormatted(((value)/1000).toFixed(2)) + "K";
                return result.replace(".00K", "K");
            } else if(format == "M") {
                //million, with 2 decimals
                var result = "$" + $scope.commaFormatted(((value)/1000/1000).toFixed(2)) + "M";
                return result.replace(".00M", "M");
            }
            return "";
        };

        $scope.commaFormatted = function(amount) {
            var delimiter = ","; // replace comma if desired
            var a = amount.split('.',2)
            var d = (a.length > 1)?a[1]:'';
            var i = parseInt(a[0]);
            if(isNaN(i)) { return ''; }
            var minus = '';
            if(i < 0) { minus = '-'; }
            i = Math.abs(i);
            var n = new String(i);
            var a = [];
            while(n.length > 3)
            {
                var nn = n.substr(n.length-3);
                a.unshift(nn);
                n = n.substr(0,n.length-3);
            }
            if(n.length > 0) { a.unshift(n); }
            n = a.join(delimiter);
            if(d.length < 1) { amount = n; }
            else { amount = n + '.' + d; }
            amount = minus + amount;
            return amount;
        };

        $scope.formatPercentage = function(value) {
            if(isNaN(value)) {
                return "";
            }
            var result = value.toFixed(1) + "%";
            //var result = (value * 100).toFixed(1) + "%";
            return result.replace(".0%", "%");
        };
        $scope.unescape = function(str) {
            if(str) {
                return str.replace("&lt;", "<").replace("&gt;", ">").replace("&quote;", "\"").replace("&amp;", "&").replace("&apos;", "'").replace("&#39;", "'");
            }
            return "";
        };
        $scope.formatDate = function(dateValue) {
            var myDate = new Date(dateValue);
            return myDate.toLocaleDateString();
        }
        $scope.buildArray = function(count) {
            var result = [];
            for(var i = 0; i < count; i++)
            {
                result.push(i+1);
            }
            return result;
        };
        $rootScope.$on('ForecastInitialized', function () {
          //client choose not to use frozen table column for now.
          /*$timeout(function() {
          if($.freeze) {
            $.freeze();
          }}, 1000);*/
        })
        if($scope.forecastEnabled) {
            var directsubUserPromise = $scope.promiseDirectSubUsers($scope.currentUser);
            directsubUserPromise.then(function(subUserResult) {
                $scope.directSubUsers = subUserResult.subUsers;
                $scope.loadTeamForecasts();
                $scope.loadTeamRepTotal();
            });

            $scope.loadForecastSummary();
            $scope.loadOpportunityListing();
        }
        else {
            $scope.errorMessage = "Forecast isn't enabled.";
        }
    });
})();
