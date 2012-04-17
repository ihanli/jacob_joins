$ = jQuery

handleFieldValidation = (target) ->
  container = target.closest ".dirtyform"
  data = $(container).data "dirtyValidation"

  $.fn.dirtyValidation "markAsValid", target

  if target.val().length > 0 and target.val() isnt " "
    if target.attr("data-type") and not validateType(target)
      switch target.attr "data-type"
        when "email"
          error_message = "It has to be a email address."
        when "numerical"
          error_message = "It has to be a number."

      $.fn.dirtyValidation "markAsInvalid", target, error_message
    else if target.attr("data-valid") and not fieldIsValid(target)
      error_message = target.attr("data-error-message")
      error_message ||= "Field is invalid."
      $.fn.dirtyValidation "markAsInvalid", target, error_message

  else
    markIfRequired target

validateType = (input) ->
  switch input.attr "data-type"
    when "email"
      regex = /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]/
      return regex.test input.val()
    when "numerical"
      return not isNaN input.val()

fieldIsValid = (input) ->
  console.log input.attr("data-valid") == "true"
  input.attr("data-valid") == "true"

markIfRequired = (field) ->
  $.fn.dirtyValidation "markAsInvalid", field, "This field is required." if field.attr("data-required") and not field.hasClass("error")

publicMethods =
  init: (options) ->
    this.each ->
      data = $(this).data "dirtyValidation"

      if not data
        settings = $.extend
          errorClass: "error"
          monitorEvent: "change"
        , options
        $(this).data "dirtyValidation", settings

        $.DirtyForm.monitorEvent = settings.monitorEvent
        $(this).dirty_form({dynamic:true}).dirty (event, event_data) ->
          handleFieldValidation event_data.target

          $(event_data.target).qtip "show"

  markAsInvalid: (field, error_message) ->
    data = field.closest(".dirtyform").data "dirtyValidation"

    if field.css("visibility") is "hidden"
      field.parent().addClass data.errorClass
    else
      field.addClass data.errorClass

    field.qtip
      overwrite: false
      content:
        text: error_message
      position:
        my: "bottom left"
        at: "top center"
        target: field
      hide:
        event: false
      show:
        event: false
    .qtip('option', 'content.text', error_message)

  markAsValid: (field) ->
    data = field.closest(".dirtyform").data "dirtyValidation"

    if field.css("visibility") is "hidden"
      field.parent().removeClass data.errorClass
    else
      field.removeClass data.errorClass

    field.removeClass data.errorClass
    field.qtip "destroy"

  destroy: ->
    this.each ->
      data = $(this).data "dirtyValidation"

      $(":input", $(this)).qtip "destroy"

      $(window).unbind ".dirtyValidation"
      $(this).removeData "dirtyValidation"

  validate: (fields, trigger_event = true) ->
    this.each ->
      data = $(this).data "dirtyValidation"

      unless data
        console.error "Can't validate form. Plugin not initialized."
        return false

      fields.each ->
        handleFieldValidation $(this)

      if trigger_event
        $(this).trigger "validated.dirtyValidation",
          valid: $(".error", $(this)).size() is 0

$.fn.dirtyValidation = (method) ->
  if publicMethods[method]
    publicMethods[method].apply this, Array.prototype.slice.call arguments, 1
  else if typeof method is "object" or not method
    publicMethods.init.apply this, arguments
  else
    $.error "Method #{method} does not exist on jQuery.dirtyValidation"