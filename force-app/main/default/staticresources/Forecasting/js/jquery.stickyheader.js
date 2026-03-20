$.freeze = function(){
	$('table.report.sticky:not(.sticky-enabled)').each(function() {
		if($(this).find('thead').length > 0 && $(this).find('th').length > 0) {
			// Clone <thead>
			var $w	   = $(window),
				$t	   = $(this),
				$thead = $t.find('thead').clone(),
				$col   = $t.find('thead, tbody').clone();

			// Add class, remove margins, reset width and wrap table
			$t
			.addClass('sticky-enabled')
			.css({
				margin: 0,
				width: '100%'
			}).wrap('<div class="sticky-wrap" />');

			if($t.hasClass('overflow-y')) $t.removeClass('overflow-y').parent().addClass('overflow-y');

			// Create new sticky table head (basic)
			$t.after('<table class="sticky-thead report" />');

			// If <tbody> contains <th>, then we create sticky column and intersect (advanced)
			if($t.find('tbody td.sticky').length > 0) {
				$t.after('<table class="sticky-col report" /><table class="sticky-intersect report" />');
			}

			// Create shorthand for things
			var $stickyHead  = $(this).siblings('.sticky-thead'),
				$stickyCol   = $(this).siblings('.sticky-col'),
				$stickyInsct = $(this).siblings('.sticky-intersect'),
				$stickyWrap  = $(this).parent('.sticky-wrap');

			if($t.find('tr').length > 20) {
					//$stickyHead.append($thead);
			}

			$stickyCol
			.append($col)
				.find('thead th:not(.sticky), thead td:not(.sticky)').remove()
				.end()
				.find('tbody th:not(.sticky), tbody td:not(.sticky)').remove();

			if($t.find('tr').length > 20) {
				//$stickyInsct.html('<thead class="header"><tr><th>'+$t.find('thead th:first-child').html()+'</th></tr></thead>');
			}

			$t.find('tr').mouseover(function() {
				var selected = this;
				$t.find('tr').each(function(i, elem) {
					if(elem == selected) {
						$stickyCol.find('tr').eq(i).addClass('on');
					}
				});
			});
			$t.find('tr').mouseout(function() {
				var selected = this;
				$t.find('tr').each(function(i, elem) {
					if(elem == selected) {
						$stickyCol.find('tr').eq(i).removeClass('on');
					}
				});
			});
			$stickyCol.find('tr').mouseover(function() {
				var selected = this;
				$stickyCol.find('tr').each(function(i, elem) {
					if(elem == selected) {
						$t.find('tr').eq(i).addClass('on');
					}
				});
			});
			$stickyCol.find('tr').mouseout(function() {
				var selected = this;
				$stickyCol.find('tr').each(function(i, elem) {
					if(elem == selected) {
						$t.find('tr').eq(i).removeClass('on');
					}
				});
			});
			// Set widths
			var setWidths = function () {
					$t
					.find('thead th').each(function (i) {
						$stickyHead.find('th').eq(i).width($(this).width());
					})
					.end()
					.find('tr').each(function (i) {
						$stickyCol.find('tr').eq(i).height($(this).height());
					});

					// Set width of sticky table head
					$stickyHead.width($t.width());

					// Set width of sticky table col
					$stickyCol.find('.sticky').add($stickyInsct.find('th')).width($t.find('thead th').width())
				},
				repositionStickyHead = function () {
					// Return value of calculated allowance
					var allowance = calcAllowance();

					// Check if wrapper parent is overflowing along the y-axis
					if($t.height() > $stickyWrap.height()) {
						// If it is overflowing (advanced layout)
						// Position sticky header based on wrapper scrollTop()
						if($stickyWrap.scrollTop() > 0) {
							// When top of wrapping parent is out of view
							$stickyHead.add($stickyInsct).css({
								opacity: 1,
								top: $stickyWrap.scrollTop()
							});
						} else {
							// When top of wrapping parent is in view
							$stickyHead.add($stickyInsct).css({
								opacity: 0,
								top: 0
							});
						}
					} else {
						// If it is not overflowing (basic layout)
						// Position sticky header based on viewport scrollTop
						if($w.scrollTop() > $t.offset().top && $w.scrollTop() < $t.offset().top + $t.outerHeight() - allowance) {
							// When top of viewport is in the table itself
							$stickyHead.add($stickyInsct).css({
								opacity: 1,
								top: $w.scrollTop() - $t.offset().top
							});
						} else {
							// When top of viewport is above or below table
							$stickyHead.add($stickyInsct).css({
								opacity: 0,
								top: 0
							});
						}
					}
				},
				repositionStickyCol = function () {
					if($stickyWrap.scrollLeft() + $w.scrollLeft() - $stickyWrap.position().left > 0) {
						// When left of wrapping parent is out of view
						$stickyCol.add($stickyInsct).css({
							opacity: 1,
							visibility: 'visible',
							left: $stickyWrap.scrollLeft() + $w.scrollLeft() - $stickyWrap.position().left
						});
					} else {
						// When left of wrapping parent is in view
						$stickyCol
						.css({ opacity: 0, visibility: 'hidden' })
						.add($stickyInsct).css({ left: 0 });
					}
				},
				calcAllowance = function () {
					var a = 0;
					// Calculate allowance
					$t.find('tbody tr:lt(3)').each(function () {
						a += $(this).height();
					});

					// Set fail safe limit (last three row might be too tall)
					// Set arbitrary limit at 0.25 of viewport height, or you can use an arbitrary pixel value
					if(a > $w.height()*0.25) {
						a = $w.height()*0.25;
					}

					// Add the height of sticky header
					a += $stickyHead.height();
					return a;
				};

			setWidths();

			$t.parent('.sticky-wrap').scroll($.throttle(250, function() {
				repositionStickyHead();
				repositionStickyCol();
			}));

			$w
			.load(setWidths)
			.resize($.debounce(250, function () {
				setWidths();
				repositionStickyHead();
				repositionStickyCol();
			}))
			.scroll($.throttle(250, function() {
				repositionStickyHead();
				repositionStickyCol();
			}));
		}
	});
	$('table.report.sticky-enabled').each(function() {
			var $w	   = $(window),
				$t	   = $(this),
				$stickyHead  = $t.siblings('.sticky-thead'),
					$stickyCol   = $t.siblings('.sticky-col'),
					$stickyInsct = $t.siblings('.sticky-intersect'),
					$stickyWrap  = $t.parent('.sticky-wrap');

				var setWidths = function () {
						$t
						.find('thead th').each(function (i) {
							$stickyHead.find('th').eq(i).width($(this).width());
						})
						.end()
						.find('tr').each(function (i) {
							$stickyCol.find('tr').eq(i).height($(this).height());
						});

						// Set width of sticky table head
						$stickyHead.width($t.width());

						// Set width of sticky table col
						$stickyCol.find('.sticky').add($stickyInsct.find('th')).width($t.find('thead th').width())
					};
					setWidths();
	});
};
