$(function () {

  var $oclcSearchForm = $("#oclc_search");
  var $oclcImportForm = $("#oclc_import");

  var $results = $("#results");
  var $selected = $("#selected");

  var selected_oclcns = {};
  $("#import-selected").attr("disabled", "disabled");

  $("#search-submit").removeAttr('disabled');  

  var renderResults = function(json) {
    $results.empty();
    $results.append(AS.renderTemplate("template_oclc_result_summary", json));
    $.each(json.results, function(i, item) {
      $result = $(AS.renderTemplate("template_oclc_result", {record: item}));
      if (item.summary_more) {
        $result.find('.oclc-result-record p:last').append(AS.renderTemplate("template_oclc_read_more", {overflow: item.summary_more}));
      }

      if (selected_oclcns[item.oclcn]) {
        $(".alert-success", $result).removeClass("hide");
      } else {
        $("button", $result).removeClass("hide");
      }
      $results.append($result);
    });

    $results.append(AS.renderTemplate("template_oclc_pagination", json));
  };

  var addSelected = function(oclcn, $result) {
    selected_oclcns[oclcn] = true;
    $selected.append(AS.renderTemplate("template_oclc_selected", {oclcn: oclcn}))

    $(".alert-success", $result).removeClass("hide");
    $("button", $result).addClass("hide");

    $selected.siblings(".alert-info").addClass("hide");
    $("#import-selected").removeAttr("disabled", "disabled");
  };

 var removeSelected = function(oclcn) {
    selected_oclcns[oclcn] = false;
    $("[data-oclcn="+oclcn+"]", $selected).remove();
    var $result = $("[data-oclcn="+oclcn+"]", $results);
    if ($result.length > 0) {
      $result.removeClass("hide");
      $result.siblings(".alert").addClass("hide");
    }

    if (selected_oclcns.length === 0) {
      $selected.siblings(".alert-info").removeClass("hide");
      $("#import-selected").attr("disabled", "disabled");
    }
  };


  $oclcSearchForm.ajaxForm({
    url: APP_PATH + "plugins/oclc/search",
    data: {},
    dataType: 'json',
    type: "GET",
    beforeSubmit: function() {
      $("#search-submit").attr('disabled', 'disabled');
    },
    success: function(json) {
      if (json.error) {
        error = json.error.replace(/<style>.*<\/style>/i, '');
        AS.openQuickModal("OCLC Search Error", error);
      } else {
        renderResults(json);
      }
      $("#search-submit").removeAttr('disabled');  
    },
    error: function(xhr, textStatus, errorThrows) {
      AS.openQuickModal("Server Error", errorThrows);
      $("#search-submit").removeAttr('disabled');
    },
  });


  $oclcImportForm.ajaxForm({
    dataType: "json",
    type: "POST",
    beforeSubmit: function() {
      $("#import-selected").attr("disabled", "disabled").addClass("disabled").addClass("busy");
    },
    success: function(json) {
      $("#import-selected").removeClass("busy");
      if (json.job_uri) {
        AS.openQuickModal(AS.renderTemplate("template_oclc_import_success_title"), AS.renderTemplate("template_oclc_import_success_message"));
        setTimeout(function() {
          window.location = json.job_uri;
        }, 2000);
      } else {
        $("#import-selected").removeAttr("disabled").removeClass("disabled");
        AS.openQuickModal(AS.renderTemplate("template_oclc_import_error_title", json.error), json.error);
      }
    },
    error: function(xhr, textStatus, errorThrows) {
      $("#import-selected").removeAttr("disabled").removeClass("disabled").removeClass("busy");
      AS.openQuickModal("Server Error", errorThrows);
      $("#search-submit").removeAttr('disabled');
    },
  });


  $results.on("click", ".oclc-pagination a", function(event) {
    event.preventDefault();

    $.getJSON($(this).attr("href"), function(json) {
      $results.ScrollTo();
      renderResults(json);
    });
  }).on("click", ".oclc-result button", function(event) {
    var oclcn = $(this).data("oclcn");
    if (selected_oclcns[oclcn]) {
      removeSelected(oclcn);
    } else {
      addSelected(oclcn, $(this).closest(".oclc-result"));
    }
  });

  $results.on("click", ".oclc-record-summary-toggle", function(event) {
    $(this).siblings(".oclc-record-summary-overflow").toggle();
    $(this).children(".oclc-record-summary-more").toggle();
    $(this).children(".oclc-record-summary-less").toggle();
  });

  $selected.on("click", ".remove-selected", function(event) {
    var oclcn = $(this).parent().data("oclcn");
    removeSelected(oclcn);
  });

});


