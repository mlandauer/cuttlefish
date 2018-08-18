$(function() {
  $("#status-counts").load("/status_counts", () => $('tbody').rowlink());
});

$(() => $("#reputation").load("/reputation"));
