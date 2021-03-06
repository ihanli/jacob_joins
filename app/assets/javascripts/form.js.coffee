window.formHashChangeHandler = ->
  Path.routes.current = null
  if window.location.hash and window.location.hash != '#skipstory'
    $("li#story").removeClass("selected simple-navigation-active-leaf");
    $('li#story a').removeClass('selected')
    $("li#form").addClass("selected simple-navigation-active-leaf");
    $("li#form a").addClass("selected");

    $('#wizard').tabs 'select', window.location.hash + "_tab"
    $.scrollTo '#skipstory', 800

window.wizardNavClickHandler = (e) ->
  window.location.hash = $(e.target).attr('href').replace('_tab', '')
  false


deactivatePlaceholders = (parent) ->
  parent.find('.placeholder').each ->
    $(this).val("") if $(this).val() is $(this).attr("placeholder")

activatePlaceholders = (parent) ->
  parent.find('.placeholder').each ->
    $(this).val($(this).attr("placeholder")) if $(this).val() is ""

showWizardLoader = (callback) ->
  $('#wizard-loader').stop(true, true).fadeIn 500, callback

hideWizardLoader = (callback) ->
  $('#wizard-loader').stop(true, true).fadeOut 500, callback

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
      style:
        classes: "validation"
    .qtip('option', 'content.text', $(this).attr("data-tooltip"))

loaderMsg = '<img alt="Ajax-loader" src="/assets/ajax-loader.gif"><h1>Loading...</h1>'

$ ->
  $(".scroll").click ->
    newsbar = $("#newsbar_new")
    newsbar.executeAt "destroy"
    $('.stories').fancyStoryEffect 'scrollTo', $('#story_1'), 800
    false

  $("#gotoform").click ->
    $.scrollTo $('#skipstory'), 800

  $("#send").live 'click', (event) ->
    if $(this).hasClass("disabled")
      return false

    $("#send").addClass "disabled"
    $('.disabled-send-button-text').show()

    $.scrollTo "#wizard", 800
      offset:
        top: -70

    showWizardLoader ->
      $("#preview_tab").stop(true, true).fadeOut 200, ->
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

          if (empty_recipe_form? and empty_recipe_form) or (empty_csi_form? and empty_csi_form) or (empty_csi_form and empty_recipe_form)
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

              error: (jqXHR, textStatus, errorThrown) ->
                alert "Failed to save the draft(s)!"

          else
            alert "Failed to save the draft(s)!"
        else
          alert "Unable to save user information (maybe not provided)."

        $("#preview_tab").stop(true, true).fadeIn 200, hideWizardLoader
        newsbar.get_latest_recipe()

    false

  $("#wizard").bind "validated.dirtyValidation", (event, data) ->
    tabs = $(".dirtyform", "#wizard")

    index = tabs.index $(event.target)
    referring_link = $($(".ui-state-default", ".ui-tabs-nav")[index])

    if data.valid
      referring_link.removeClass("form_not_valid").addClass("form_valid")

      qapi = referring_link.qtip('api')
      unless qapi == undefined
        tooltip = $(qapi.elements.tooltip)
        referring_link.removeData('qtip')
        tooltip.remove()

    else
      referring_link.removeClass("form_valid").addClass("form_not_valid")
      referring_link.qtip
        overwrite: false
        content:
          text: "Check your entries!"
        position:
          my: "bottom left"
          at: "top right"
          target: referring_link
          adjust:
            x: -20
            y: 0
        hide:
          event: false
        show:
          event: false
        style:
          classes: "tip-brown rufezeichen"
      .qtip('show')

  $('#wizard').tabs()
  $('#wizard').data('activeRequests', 0)

  $('#wizard').bind 'tabsshow', (event, ui) ->
    $(".error", ui.panel).qtip "show"
    $(":input", ui.panel).filter (index) ->
      return $(this).attr("visibility") isnt "hidden"
    .parent().qtip "show"

  $('#wizard').bind 'tabsselect', (event, ui) ->
    oldTabIndex = $('#wizard').tabs 'option', 'selected'
    oldTab = $('.ui-tabs-panel:not(.ui-tabs-hide)')

    $(ui.tab).parent().qtip 'hide'

    $("[aria-describedby]", oldTab).qtip "hide"

    if oldTabIndex < $('#wizard').tabs('length') and oldTab.find(":input").hasClass("changed")
      url = "/#{oldTab.attr('id').replace('_tab', 's/sync_wizard')}"
      deactivatePlaceholders(oldTab)
      params = oldTab.children('form').serializeArray()
      activatePlaceholders(oldTab)

      actual_form = oldTab.find("form")
      actual_nav_link = $('.ui-state-active')

      $.ajax
        url: url
        type: 'POST'
        async: true
        data: params
        beforeSend: ->
          activeRequests = $('#wizard').data('activeRequests')
          $('#wizard').data('activeRequests', ++activeRequests)
          oldTab.mask(loaderMsg)
        complete: ->
          activeRequests = $('#wizard').data('activeRequests')
          $('#wizard').data('activeRequests', --activeRequests)
          oldTab.unmask()
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
      $(ui.panel).mask(loaderMsg)

      loadPreview = ->
        if $('#wizard').data('activeRequests') is 0
          $('#preview_tab').css('opacity', '0').load "preview", (data, textStatus) ->
            $(this).animate
              opacity: 1
            , 200

            if $('#aboutyou').parent().hasClass('form_valid') and ( $('#yourrecipe').parent().hasClass('form_valid') or $('#aboutyourcountry').parent().hasClass('form_valid') )
              $('#send').removeClass('disabled')
              $('.disabled-send-button-text').hide()
        else
          window.setTimeout(loadPreview, 100)

      loadPreview()