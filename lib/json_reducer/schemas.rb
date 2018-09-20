require 'singleton'
require 'json'

module JsonReducer
  class Schemas
    include Singleton

    attr_accessor :base_path

    def initialize
      @schemas = {}
      @base_path = nil
    end

    def get(key)
      @schemas[key]
    end

    def set(key, schema, file)
      value = file ? File.read("#{@base_path}/#{schema}") : schema
      @schemas[key] = value.is_a?(String) ? JSON.parse(value) : value
    end
  end
end
