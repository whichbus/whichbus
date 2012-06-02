class App.Stop extends Spine.Model
  @configure 'Stop', 'name', 'code', 'latitude', 'longitude', 'direction'
  @extend Spine.Model.Ajax

  @url '/stop'