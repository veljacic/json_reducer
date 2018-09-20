require 'json_reducer/version'

require 'json_reducer/mask'
require 'json_reducer/schemas'

module JsonReducer
  def self.new(*args)
    Mask.new(*args)
  end

  def self.register(key, schema, file: true)
    JsonReducer::Schemas.instance.set(key, schema, file)
  end

  def self.base_path(path)
    JsonReducer::Schemas.instance.base_path = path
  end
end
