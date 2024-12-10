ready = ->
  $("#user_organisation").select2(
    {
      theme: "bootstrap",
      placeholder: 'Start typing organisation',
      width: '300px',
      minimumInputLength: 3,
      tags: true,
      allowClear: true,
      data: $("#user_organisation").data("tags"),
    }
  )

$(document).ready(ready)
$(document).on('page:load', ready)