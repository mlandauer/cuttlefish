# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# If an anchor is used forces the corresponding tab to be opened on loading of the page
$(document).ready ->
  if location.hash != ''
      $('a[href="'+location.hash+'"]').tab('show')
