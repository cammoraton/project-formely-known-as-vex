class EmbeddedConfiguration
  include MongoMapper::EmbeddedDocument

  key :name, String, :required => true
  key :data, Hash
end
