// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


$(function document() {
  $('.scroller').click(function() {
    var target = $(this).attr("href");
    var position = $(target).offset().top - 60;

    $('html, body').animate({
      scrollTop: position
    }, 500);

    return false;
  });
});

$(function document() {
  $("#sample-data").click(function(e) {
    $("#record_currency").val("USD");
    $("#record_events").val("60");
    $("#record_stations").val("12");
    $("#record_maintenance_budget").val("2500000");
    $("#record_population").val("320000");
    $("#record_treatment_vehicles").val("22");
    $("#record_treatment_miles").val("530");
    $("#record_routes").val("19");
    $("#record_cleanup_miles").val("250");
    $("#record_dry_material_use").val("100");
    $("#record_wet_material_use").val("5000");
    $("#record_assumptions_setting_attributes_tolls_per_vehicle").val("5");

    e.preventDefault();
  });
});

$(function document() {
  function changeUnits() {
    var currency = $("#record_currency").val();
    $(".ccy-label").html(currency);
    if (currency == "USD" || currency == "GBP") {
      $(".dist-label").html("Miles");
      $(".vol-label").html("Gals");
    }
    if (currency == "EUR" || currency == "CAD") {
      $(".dist-label").html("Km");
      $(".vol-label").html("Liters");
    }
  }
  $("select").change(function() {
    changeUnits();
  });
});

$(function document() {
  $('a.current').click(function(e) {
    e.preventDefault();
  }).hover().css({
    'cursor': 'default'
  });
});

$(document).ready(function() {
  $(".rest_in_place").rest_in_place();
});

$(document).ready(function() {
  $(".edit-container tr td:nth-child(1)").click(function() {
    $(this).parent("tr").children("td:nth-child(2)").click();
  });
  $(".edit-container tr td:nth-child(3)").click(function() {
    $(this).parent("tr").children("td:nth-child(2)").click();
  });
  $(".edit-container tr td:nth-child(4)").click(function() {
    $(this).parent("tr").children("td:nth-child(2)").click();
  });
});

$(function document() {
  $(".record-link").mouseover(function() {
    $(this).children(".target").addClass("hidden");
    $(this).children("#page-url").removeClass("hidden");
  });
  $(".record-link").mouseout(function() {
    $(this).children(".target").removeClass("hidden");
    $(this).children("#page-url").addClass("hidden");
  });
  $(".record-link").click(function(e) {
    SelectText("page-url");
    e.preventDefault();
  });
});

$(function document() {
  $(".export .save").click(function() {
    $(this).html("<span>Creating PDF…</span>");
    $(this).closest("li").css({
      'width': 'auto'
    });

    $("#lightbox, #lightbox-container-pdf").delay(300).fadeIn(800);
  });
  $(".export .email").click(function() {
    $(this).html("<span>Sending…</span>");
    $(this).closest("li").css({
      'width': 'auto'
    });
    
    $("#lightbox, #lightbox-container-email").delay(300).fadeIn(800);
  });
});

$(document).ready(function() {
  $("#print-link").click(function(e) {
    window.print();
    return false;
    e.preventDefault();
  });
});

function SelectText(element) {
  var text = document.getElementById(element);
  if ($.browser.msie) {
    var range = document.body.createTextRange();
    range.moveToElementText(text);
    range.select();
  } else if ($.browser.mozilla || $.browser.opera) {
    var selection = window.getSelection();
    var range = document.createRange();
    range.selectNodeContents(text);
    selection.removeAllRanges();
    selection.addRange(range);
  } else if ($.browser.safari) {
    var selection = window.getSelection();
    selection.setBaseAndExtent(text, 0, text, 1);
  }
}


$(function document() {
  $("nav.secondary").sap();
});

