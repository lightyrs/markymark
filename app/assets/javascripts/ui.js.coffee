Application.UI =

  initialize: ->
    @initResponsivePaginate()
    @initSelect2()

  initResponsivePaginate: ->
    $('.pagination').rPage()

  initSelect2: ->
    @initLocalSelect2()
    @initAjaxSelect2()

  initLocalSelect2: ->
    $('select.select2').select2
      allowClear: true

  initAjaxSelect2: ->
    $('input.select2-ajax').select2
      tags: true
      allowClear: true
      minimumInputLength: 2
      tokenSeparators: [',']
      multiple: ->
        $(this).data('multiple')?
      formatResult: (result) ->
        result.name
      formatSelection: (result) ->
        result.name 
      ajax:
        url: ->
          $(this).data 'url'
        dataType: 'json'
        data: (term, page) ->
          q: term
        results: (data, page) ->
          results: data
      createSearchChoice: (term, data) ->
        unless _.filter(data, (result) -> result.name is term).length
          id: term
          name: term