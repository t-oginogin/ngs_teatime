# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#reference_genome').hide()

window.update_reference_genome = ->
  if /bowtie/.test($('#job_tool option:selected').text())
    $('#reference_genome').show()
  else
    $('#job_reference_genome').val('')
    $('#reference_genome').hide()
