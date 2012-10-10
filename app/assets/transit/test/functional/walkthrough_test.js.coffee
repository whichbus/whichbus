casper.test.comment 'A typical trip planning walkthrough.'

url = 'http://localhost:9292/'
destination = 
  from: 'capitol hill'
  to: 'university district'

casper.start url, ->
  @test.assertHttpStatus 200, 'WhichBus is up!'
  @test.assertVisible '#splash form', 'I can see a splash screen search form.'

casper.then ->
  @echo "I put '#{destination.from}' in the from field."
  @echo "And '#{destination.to}' in the to field."
  @fill '#splash form', destination

casper.then ->
  @echo 'Then press a submit button.'
  @click '#splash form button[type=submit]'

casper.then ->
  @waitUntilVisible '#navigation', ->
    @test.assertUrlMatch /plan\/capitol\+hill\/university\+district/

casper.then ->
  @waitUntilVisible '#navigation li.itinerary', ->
    @test.assertEval ->
      document.querySelectorAll('#navigation li.itinerary').length == 3
    , 'I see three itineraries.'

casper.then ->
  @echo 'I click on the trip options header.'
  @click '#navigation header.options'

casper.then ->
  @waitUntilVisible '#navigation form.options', ->
    @test.assertVisible('#navigation form.options input[name=trip_time]',
                        'I can see the time selector.')

    @echo 'I set the time for the current plan to 7:00pm'
    @fill '#navigation form.options',
      trip_time: '7:00pm'

casper.then ->
  @echo 'Then press a submit button.'
  @click '#navigation form.options button[type=submit]'

casper.then ->
  @waitUntilVisible '#navigation li.itinerary', ->
    @test.assertVisible '#navigation li.itinerary', 'I see itineraries again!'

casper.run ->
  @test.done()
