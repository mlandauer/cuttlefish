$(document).ready(function() {
  // TODO This is a bit long winded. Would be nice to do this more concisely
  if (!$("#app_click_tracking_enabled").is(":checked") && !$("#app_open_tracking_enabled").is(":checked")) {
    $("#app_custom_tracking_domain_input").css("display", "none");
  }

  $("#app_click_tracking_enabled, #app_open_tracking_enabled").click(function() {
    if ($("#app_click_tracking_enabled").is(":checked") || $("#app_open_tracking_enabled").is(":checked")) {
      $("#app_custom_tracking_domain_input").show("fast");
    } else {
      $("#app_custom_tracking_domain_input").hide("fast");
    }
  });
});
