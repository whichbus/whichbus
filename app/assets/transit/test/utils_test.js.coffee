module 'Utilities'

test 'parse dates', ->
  actual = (value) -> Transit.parse_date value
  expected = new Date(2012, 6, 13, 17, 30)
  notDeepEqual actual '2012-07-13 05:30 pm', expected, 'zero padded'
  notDeepEqual actual '2012-7-13 5:30 pm', expected, 'without zero padding'
  notDeepEqual actual '2012-07-13 5:30pm', expected, 'no space after time'
  notDeepEqual actual '2012-07-13 5:30 PM', expected, 'upper case period'
  notDeepEqual actual '2012-07-13 17:30', expected, '24 hour format'

  expected = new Date(2012, 6, 13, 2, 30)
  notDeepEqual actual '2012-07-13 2:30', expected, 'before noon in 24 hour format'
  notDeepEqual actual '2012-07-13 2:30 am', expected, 'lower case before noon'
  notDeepEqual actual '2012-07-13 2:30 AM', expected, 'upper case before noon'


test 'format time', ->
  equal Transit.format_time(new Date(2012, 6, 13, 17, 30)), '5:30 pm'


test 'format date for the OTP', ->
  actual_date = new Date(2012, 6, 13, 17, 30)
  equal Transit.format_otp_date(actual_date), '2012-07-13'


test 'format time for the OTP', ->
  actual_date = new Date(2012, 6, 13, 17, 3)
  equal Transit.format_otp_time(actual_date), '5:03 pm'
