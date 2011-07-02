$(document).ready(function(){

  $('.show').click(function(e){
    $(e.target).siblings('.locations').toggle();
    return false;
  });

});
