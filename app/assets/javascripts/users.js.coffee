# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
//= require private_pub
//= require bootstrap
$(document).ready ->
  $('#myModal').modal 'show'
  return

# maxCharacters = 140
# $("#count").text maxCharacters
# $("textarea").bind "keyup keydown", ->
#   count = $("#count")
#   characters = $(this).val().length
#   if characters > maxCharacters
#     count.addClass "over"
#   else
#     count.removeClass "over"
#   count.text maxCharacters - characters
#   return