jQuery(function($) {
  $(".prettyprint").each(function() {
    $(this).text(JSON.stringify(JSON.parse($(this).text().trim() || "{}"), null, 2));
  })

  $('#show-params').click(function() {
    $('#create-api .params').show();
  })

  $('#show-status').click(function() {
    $('#create-api .status').show();
  })

  $('#add-params').click(function() {
    $('#create-api .params-value').append("<div class='col-md-4'>" + 
          "<input type='text' placeholder='NAME' class='form-control' name='route[params_key][]'>" +
          "</div><div class='col-md-7'><input type='text' placeholder='VALUE' " + 
          "class='form-control' name='route[params_value][]'></div>");
  })

  $(".delete").click(function(e) {
    e.preventDefault();
    $.post($(this).attr("href"), {_method: "delete"}, function(response){
      alert(response.error);
      document.location = response.url;
    })
  })

})
