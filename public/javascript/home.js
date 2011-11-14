$(document).ready(function(){ 
  $('#locations').change(function(){
    var url = $('#locations').val();
    if(url){
      window.location = url;
    }
  });

  $('.elsewhere-toggle').click(function(e){
    e.preventDefault();
    $(e.target).closest('.book').find('.elsewhere').toggle()

  });
});
