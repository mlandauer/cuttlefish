// If an anchor is used forces the corresponding tab to be opened on loading of the page
$(document).ready(function() {
  if (location.hash !== '') {
      $(`a[href="${location.hash}"]`).tab('show');
    }
});
