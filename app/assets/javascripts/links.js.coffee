Application.Links =

  initialize: ->
    @attachListeners()

  attachListeners: ->
    $('.media-trigger').on 'click', @onMediaTriggerClick

  onMediaTriggerClick: (event) =>
    $(event.target).parents('.media-body').find('a.embed').oembed()
