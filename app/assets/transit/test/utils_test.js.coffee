module 'Utilities'

test 'parse dates', ->
  expected_date = new Date(2012, 6, 13, 17, 30)
  notDeepEqual Transit.parse_date '2012-07-13 05:30 pm', expected_date
  notDeepEqual Transit.parse_date '2012-7-13 5:30 pm', expected_date
  notDeepEqual Transit.parse_date '2012-07-13 5:30pm', expected_date
  notDeepEqual Transit.parse_date '2012-07-13 5:30 PM', expected_date
  notDeepEqual Transit.parse_date '2012-07-13 17:30', expected_date


test 'format time', ->
  equal Transit.format_time(new Date(2012, 6, 13, 17, 30)), '5:30 pm'


test 'format date for the OTP', ->
  actual_date = new Date(2012, 6, 13, 17, 30)
  equal Transit.format_otp_date(actual_date), '2012-07-13'


test 'format time for the OTP', ->
  actual_date = new Date(2012, 6, 13, 17, 3)
  equal Transit.format_otp_time(actual_date), '5:03 pm'
