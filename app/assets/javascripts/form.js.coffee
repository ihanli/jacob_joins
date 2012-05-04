showWizardLoader = () ->
  $('#wizard-loader').stop().fadeIn 500

hideWizardLoader = () ->
  $('#wizard-loader').stop().fadeOut 500

window.reinitialize_tooltips = (context) ->
  $("[data-tooltip]", context).each ->
    $(this).qtip
      overwrite: false
      content:
        text: $(this).attr "data-tooltip"
      position:
        my: "bottom left"
        at: "top center"
        target: $(this)
    .qtip('option', 'content.text', $(this).attr("data-tooltip"))

$ ->
  $(".scroll").click ->
    newsbar = $("#newsbar")
    newsbar.visibleAfter "destroy"
    $.scrollTo $('#story_1'), 800,
      onAfter: ->
        newsbar.visibleAfter $("#start")
        newsbar.fadeIn 500

  $("#gotoform").click ->
    $.scrollTo $('#skipstory'), 800

  $("#wizard").on 'click', "#send", (event) ->
    event.preventDefault()

    if $(this).hasClass("disabled")
      return false

    showWizardLoader()

    $("#preview_tab").fadeOut 200

    unless window.user?
      if $('#aboutyou').parent().hasClass('form_valid')
        empty_user_form = publish_user()
        
        window.user = 
          id: $('#user_tab form').attr('action').split('/')[2]
          location:
            longitude: $('#longitude').val()
            latitude: $('#latitude').val()
            city: $('#city_hidden').val()
            country: $('#country_hidden').val()
            
    if window.user
      empty_recipe_form = publish_recipe(window.user.id, window.user.location) if $('#yourrecipe').parent().hasClass('form_valid')
      empty_csi_form = publish_csi(window.user.id, window.user.location) if $('#aboutyourcountry').parent().hasClass('form_valid')

      if empty_recipe_form or empty_csi_form
        $.ajax
          url: "/pages/drafts_saved"
          async: false
          success: (data, textStatus, jqXHR) ->
            if empty_recipe_form?
              $('#recipe_tab').html(empty_recipe_form)
              $('#yourrecipe').parent().removeClass('form_valid')

            if empty_csi_form?
              $('#country_specific_information_tab').html(empty_csi_form)
              $('#aboutyourcountry').parent().removeClass('form_valid')

            if empty_user_form?
              $('#user_tab').html(empty_user_form)
              $('#aboutyou').parent().removeClass('form_valid')
              window.user = undefined

            $('#preview_tab').html(data)
            $.scrollTo "#wizard", 800
              offset:
                top: -70

          error: (jqXHR, textStatus, errorThrown) ->
            alert "Failed to save the draft(s)!"

      else
        alert "Failed to save the draft(s)!"
    else
      alert "Unable to save user information (maybe not provided)."

    $("#preview_tab").fadeIn 200

    hideWizardLoader()

  $("#wizard").bind "validated.dirtyValidation", (event, data) ->
    tabs = $(".dirtyform", "#wizard")

    index = tabs.index $(event.target)
    referring_link = $($(".ui-state-default", ".ui-tabs-nav")[index])

    if data.valid
      referring_link.removeClass("form_not_valid").addClass("form_valid")
    else
      referring_link.removeClass("form_valid").addClass("form_not_valid")

  $('#wizard').tabs()

  $('#wizard').bind 'tabsshow', (event, ui) ->
    $(".error", ui.panel).qtip "show"
    $(":input", ui.panel).filter (index) ->
      return $(this).attr("visibility") isnt "hidden"
    .parent().qtip "show"

  $('#wizard').bind 'tabsselect', (event, ui) ->
    newHash = "#!/form/#{ui.tab.hash.slice 1}"
    window.location.hash = newHash if window.location.hash isnt newHash

    oldTabIndex = $('#wizard').tabs 'option', 'selected'
    oldTab = $('.ui-tabs-panel:not(.ui-tabs-hide)')

    $("[aria-describedby]", oldTab).qtip "hide"

    if oldTabIndex < $('#wizard').tabs('length') and oldTab.find(":input").hasClass("changed")
      url = oldTab.attr('id').replace '_tab', 's/sync_wizard'
      params = oldTab.children('form').serializeArray()

      actual_form = oldTab.find("form")
      actual_nav_link = $('.ui-state-active')

      $.ajax
        url: url
        type: 'POST'
        async: false
        data: params
        success: (data, textStatus, jqXHR) ->
          oldTab.html data
          $(".dirtyform", oldTab).dirtyValidation "validate", $(":input", oldTab).not("[type='hidden']")

          reinitialize_tooltips oldTab

          oldTab.css
            display: "block"
          oldTab.attr "style", ""     
        statusCode:
          400: ->
            console.log "Unable to save changes"

    if ui.index is $('#wizard').tabs('length') - 1
      showWizardLoader()

      $('#preview_tab').css('opacity', '0').load "pages/preview", (data, textStatus) ->
        $(this).animate
          opacity: 1
        , 200

        hideWizardLoader()

        if $('#aboutyou').parent().hasClass('form_valid') and ( $('#yourrecipe').parent().hasClass('form_valid') or $('#aboutyourcountry').parent().hasClass('form_valid') )
          $('#send').removeClass('disabled')
