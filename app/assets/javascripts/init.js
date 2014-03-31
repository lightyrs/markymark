var Application = {
  UI: {},
  Links: {}
}

$(document).on('ready page:load', function() {
  Application.UI.initialize();
  Application.Links.initialize();
});
