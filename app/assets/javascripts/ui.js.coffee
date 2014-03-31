Application.UI =

  initialize: ->
    @initResponsivePaginate()

  initResponsivePaginate: ->
    $('.pagination').rPage();
