jQuery(function($) {

  $(".title").click(function() {
    $(this).parent().children(".example").toggle();
  });

})
