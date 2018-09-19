require 'json_reducer/version'
require 'json_reducer/mask'

module JsonReducer
  def self.new(*args)
    Mask.new(*args)
  end
end
