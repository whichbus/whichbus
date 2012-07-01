Transit.format_time = (input) ->
  date = if input not instanceof Date then new Date(input) else input
  hours = date.getHours() % 12 || 12
  minutes = date.getMinutes()
  padded_minutes = "#{if minutes < 10 then '0' else ''}#{minutes}"
  period = if date.getHours() < 12 then 'am' else 'pm'
  "#{hours}:#{padded_minutes} #{period}"

Transit.format_duration = (seconds, minimize=false) ->
	mins = Math.floor(seconds / 60)
	if mins > 59
		hrs = Math.floor(mins / 60)
		mins = mins % 60
	else hrs = 0

	if hrs > 0 then "#{hrs}#{if minimize then 'h' else ' hours'}, #{mins}#{if minimize then 'm' else ' minutes'}"
	else "#{mins}#{if minimize then 'm' else ' minutes'}"

Transit.pad = (num, zeroes) -> (1e10+num+"").slice(-zeroes)