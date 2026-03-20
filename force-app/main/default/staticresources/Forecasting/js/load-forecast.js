function initTooltip(containerElem) {
    $("label[class~='trunk']").each(function(index, elem) {
        var content = $(this).attr("data-title");
        $(elem).tooltip({ html: true, title: content, container: containerElem });
    });
}

$(document).ready(function() {
    var scope = angular.element($('#ngContainer')).scope();
    scope.initPopoverDone = false;
    scope.showSplitDetails = function(splits) {
        if (scope.initPopoverDone) {
            scope.initPopoverDone = false;
        }
        var content = "";
        if (splits != null && splits.length > 0) {
            content = "<div><table class='report'><thead><tr><th colspan='3' class='none' style='background:white;border-bottom:1px solid #b6b6b6'>Split Details</th></tr></thead><tbody>";
            content += "<tr class='header'><th style='width:80px'>Rep Name</th><th>Split Amount</th><th> % </th></tr>";
            for (var i = 0; i < splits.length; i++) {
                var split = splits[i];
                content += "<tr class='line'><td class='center'><a href='/" + split.SplitOwnerId + "'>" + unescape(split.SplitOwnerName) + "</a></td><td class='number'>" + scope.formatDecimal(split.SplitAmount, scope.displayFormat) + "</td><td class='number'>" + split.SplitPercentage + '%' + "</td></tr>";
            }
            content += "</tbody></table></div>";
        }
        return content;
    };
    scope.initPopover = function() {
        if (!angular.element($('#ngContainer')).scope().initPopoverDone) {
            $("span[data-toggle='popover']").popover({
                    trigger: 'manual',
                    animation: false
                })
                .on("mouseover", function() {
                    var _this = this;
                    $(this).popover("show");
                    $(".tooltipContainer").children(".popover").on("mouseleave", function() {
                        $(_this).popover("hide");
                    });
                })
                .on("mouseleave", function() {
                    var _this = this;
                    setTimeout(function() {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide");
                        }
                    }, 100);
                });
            angular.element($('#ngContainer')).scope().initPopoverDone = true;
        }
    };
    scope.init = function(container) {
        scope.initPopover();
        window.initTooltip(container);
    };
})
