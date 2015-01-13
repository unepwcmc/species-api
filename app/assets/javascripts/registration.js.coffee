ready = ->
  $("#user_organisation").select2(
    {
      placeholder: 'Start typing organisation',
      width: '300px',
      minimumInputLength: 3,
      allowClear: true,
      initSelection: (element, callback) ->
        value = $(element).val()
        callback({id: value, text: value})
      data: $("#user_organisation").data("tags"),
      createSearchChoice: (term) ->
        return {id: term, text: term}
    }
  )

$(document).ready(ready)
$(document).on('page:load', ready)