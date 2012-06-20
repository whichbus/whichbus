class App.Agency extends Spine.Model
  @configure 'Agency', 'oba_id', 'code', 'name', 'url', 'phone,', 'timezone', 'disclaimer'
  @extend Spine.Model.Ajax