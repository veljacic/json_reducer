module JsonReducer
  class Mask
    def initialize(key)
      @schema = JsonReducer::Schemas.instance.get(key)
    end

    def apply(payload)
      payload = parse_record(payload).dup
      apply!(payload, @schema)

      payload
    end

    private

    def apply!(payload, schema)
      return if schema.dig('properties').nil?

      sliced = slice!(payload, schema['properties'].keys)
      handle(schema['properties'], sliced)
    end

    def handle(properties, payload)
      properties.each do |key, property|
        case property['type']
        when 'array'
          payload[key].each { |hash| apply!(hash, property) }
        when 'object'
          apply!(payload[key], property)
        end
      end
    end

    def parse_record(schema)
      schema.is_a?(String) ? JSON.parse(schema) : schema
    end

    def slice!(hash, keys)
      sliced = hash.slice(*keys)
      sliced.default      = hash.default
      sliced.default_proc = hash.default_proc if hash.default_proc
      hash.replace(sliced)
    end
  end
end
