$(document).ready(function(){ 
  $('#locations').change(function(){
    var url = $('#locations').val();
    if(url){
      window.location = url;
    }
  });
});
