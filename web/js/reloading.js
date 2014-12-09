//http://net.tutsplus.com/tutorials/javascript-ajax/submit-a-form-without-page-refresh-using-jquery/
//http://ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js


$(function() {
  $('.error').hide();
  $(".button0").click(function() {
		// validate and process form
		// first hide any error messages
    $('.error').hide();
		
    var file = $("input#file").val();
    if (file == "") {
      $("label#file_error").show();
      $("input#file").focus();
      return false;
    }
	
    var dataString = 'file='+ file;
    //alert (dataString);return false;

    $.ajax({
      type: "POST",
      url: "mainApp.jsp",
      data: dataString,
      success: function() {
        $('#textOut').html("<div id='message'></div>");
        $('#message').html("<h2>Dáta boli spracované!</h2>")
        .append("<p>spracovaný súbor: "+ file +"</p>")
        .hide()
        .fadeIn(1500, function() {
        });
      }
     });
    return false;
	});
  
});