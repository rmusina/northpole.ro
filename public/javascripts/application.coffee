notify = (text, label) ->
  $("#signup-info")
    .text(text)
    .removeClass()
    .addClass(label)

$(document).ready ->
  if Math.random() > 0.5
    $(".bear").addClass('flipit')

  $("#signup").focus ->
    notify("press enter to submit", "label label-info")

  $("#signup").keypress (event) ->
    if event.which is 13
      event.preventDefault()
      
      json = {
        'api_key': $('#signup').val(),
        'secret': ''
      }
      $.ajax
        type: "POST"
        url: "/user.json"
        data: JSON.stringify(json)
        success: (data, textStatus, jqXHR) ->
          notify("done. check your email", "label label-success")
          $("#signup")
            .blur()
            .fadeOut()

        error: (jqXHR, textStatus, errorThrown) ->
          result = JSON.parse(jqXHR.responseText)
          notify(result['error'], "label label-important")
