$(document).ready(function() {
  // IE hack to display alternating row colors
  $("table:not(.no-alt-colors) tr:even").css("background-color", "#ebebeb");

  // IE hack to force align second table columns right
  $("table td:nth-child(2)").css("text-align", "right");

  // IE hack to set edit-container table column widths
  $(".edit-container table tr td:nth-child(1)").css("width", "300px");
  $(".edit-container table tr td:nth-child(2)").css("width", "120px");
  $(".edit-container table tr td:nth-child(3)").css("color", "#888888");
  $(".edit-container table tr td:nth-child(4)").css("width", "120px");

  $(".edit-container tr").click(function() {
    $(this).delay(500).children("input").css("width", "110px");
  });

  $(".edit-container table#customer-info-table tr td:nth-child(1)").css("width", "140px");
  $(".edit-container table#customer-info-table tr td:nth-child(2)").css("width", "280px");
});
