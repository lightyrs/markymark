Application.Links =

  initialize: ->
    @attachListeners()

  attachListeners: ->
    $(document).on 'click', 'li.link', @onLinkItemClick
    $(document).on 'click', '.media-trigger', @onMediaTriggerClick

  onLinkItemClick: (event) ->
    $target = $(event.target)
    parent = if $target.is('li.link') then $target else $target.parents('li.link')
    id = parent.data 'id'
    $('#main .content').load "/links/#{id} #link_#{id}"

  getContent: (id) ->


  onMediaTriggerClick: (event) =>
    $(event.target).parents('.media-body').find('a.embed').oembed()
