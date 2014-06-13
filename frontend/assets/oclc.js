$(function () {

  var $oclcSingleForm = $("#oclc_search");

  var $results = $("#results");

  var selected_oclcns = {};
  $("#import-selected").attr("disabled", "disabled");

  var query_state = "";

  var previewRecords = function(records) {
    $results.empty();
    var $nav = $('<ul class="nav nav-tabs"></ul>');
    var $panes = $('<div class="tab-content"></div>');
    
    selected_oclcns = {};

    for (var i = 0; i < records.length; i++) {
      var record = new Record(records[i]);

      var $navItem = $("<li><a data-toggle='tab' href='#" + record.oclcn + "'>" + record.oclcn + "</a></li>")

      if (i == 0) {
        $navItem.addClass('active');
        record.classes = "active in";
      }

      if (record.importable) {
        selected_oclcns[record.oclcn] = true;
      } else {
        $navItem.addClass('failure');
      }

      $result = $(AS.renderTemplate("template_oclc_result", {record: record}));

      $nav.append($navItem);
      $panes.append($result);
    }

    $results.append($nav);
    $results.append($panes);

    $('pre code', $results).each(function(i, e) {
      hljs.highlightBlock(e)
    });

    query_state = Object.keys(selected_oclcns).join('; ')

    $('.oclc-search-query').val(query_state);

    $oclcSingleForm.trigger('readyToImport');
  };
  

  $('.oclc-search-query').on('input', function() {
    if ($(this).val() != query_state) {
      $(this).trigger('previewIsStale');
    }
  }).on('blur', function() {
    if ($(this).val() == query_state && query_state.length) {
      $(this).trigger('readyToImport');
    }
  });


  $oclcSingleForm.on('readyToImport', function(e) {
    e.stopPropagation();
    $(this).find('#import-submit').removeAttr('disabled');
  });

  $oclcSingleForm.on('previewIsStale', function(e) {
    e.stopPropagation();
    $(this).find('#import-submit').attr('disabled', 'disabled');
  });


  $oclcSingleForm.ajaxForm({
    url: APP_PATH + "plugins/oclc/import",
    data: {},
    dataType: 'json',
    type: "POST",
    beforeSubmit: function() {
      $("#search-submit").attr('disabled', 'disabled');
    },
    success: function(json) {
      if (json.error) {
        error = json.error.replace(/<style>.*<\/style>/i, '');
        AS.openQuickModal("OCLC Plugin Error", error);
      } else if (json.job_uri) {
        AS.openQuickModal(AS.renderTemplate("template_oclc_import_success_title"), AS.renderTemplate("template_oclc_import_success_message"));
        setTimeout(function() {
          window.location = json.job_uri;
        }, 2000);
      } else if (json.records) {
        previewRecords(json.records);
      } else {
        alert("Something went wrong.");
      }
      $("#search-submit").removeAttr('disabled');
    },
    error: function(xhr, textStatus, errorThrows) {
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


  function Record(record) {
    this.oclcn = record.oclcn
    if (record.xml) {
      this.body = record.xml;
      this.importable = true;
    } else if (record.error) {
      this.body = record.error;
      this.importable = false;
    } else {
      this.importable = false;
    }
  }

});


