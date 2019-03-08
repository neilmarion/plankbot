var classes = [
  ".reviewer_availability",
  ".reviewer_time_available",
]

$(document).ready(function() {
  $.each(classes, function( index, value ) {
    $(value).change(function() {
      $(value).prop('checked', false);
      $(this).prop('checked', true);
    });
  });
})
