Application.UI =

  initialize: ->
    @initResponsivePaginate()
    @initSelect2()

  initResponsivePaginate: ->
    $('.pagination').rPage()

  initSelect2: ->
  	$('select.select2').select2()