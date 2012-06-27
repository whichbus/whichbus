Transit.format_time = (input) ->
  date = if input not instanceof Date then new Date(input) else input
  hours = date.getHours() % 12 || 12
  minutes = date.getMinutes()
  padded_minutes = "#{if minutes < 10 then '0' else ''}#{minutes}"
  period = if date.getHours() < 12 then 'am' else 'pm'
  "#{hours}:#{padded_minutes} #{period}"
