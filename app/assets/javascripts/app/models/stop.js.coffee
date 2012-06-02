class App.Stop extends Spine.Model
  @configure 'Stop', 'name', 'code', 'latitude', 'longitude', 'direction'
  
  # @extend Spine.Model.Ajax
  # @url '/stop'

  @extend Spine.Model.Local

  @filter: (query) ->
  	return @all() unless query
    query = query.toLowerCase()
    @select (item) ->
      item.name?.toLowerCase().indexOf(query) isnt -1 or
        item.code?.toLowerCase().indexOf(query) isnt -1
