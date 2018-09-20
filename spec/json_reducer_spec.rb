RSpec.describe JsonReducer do
  let(:payload) do
    {
      'foo' => {
        'bar' => {
          'title' => 'BAR',
          'body' => 'Body of the BAR'
        },
        'baz' => 'BAZ'
      },
      'abc' => {
        'def' => 'DEF'
      },
      'dbc' => {
        'fed' => 'FED'
      },
      'included' => [
        {
          'txt' => 'txt'
        },
        {
          'txt' => 'txt2',
          'some' => 'txt'
        }
      ]
    }
  end

  it 'works on multiple schemas' do
    abc_schema = {
      'type' => 'object',
      'properties' => {
        'abc' => { 'type' => 'object' }
      }
    }

    dbc_schema = {
      'type' => 'object',
      'properties' => {
        'dbc' => { 'type' => 'object' }
      }
    }
    JsonReducer.register(:schema, abc_schema.to_json, file: false)
    JsonReducer.register(:schema1, dbc_schema.to_json, file: false)
    actual = JsonReducer.new(:schema).apply(payload)
    actual1 = JsonReducer.new(:schema1).apply(payload)
    expect(actual).to eq('abc' => { 'def' => 'DEF' })
    expect(actual1).to eq('dbc' => { 'fed' => 'FED' })
  end

  it 'returns fieltered schema for array' do
    schema =  {
      'type' => 'object',
      'properties' => {
        'dbc' => {
          'type' => 'object',
          'properties' => {
            'fed' => { 'type' => 'string' }
          }
        },
        'included' => {
          'type' => 'array',
          'properties' => {
            'txt' => { 'type' => 'string' }
          }
        }
      }
    }
    JsonReducer.register(:schema, schema.to_json, file: false)
    actual = JsonReducer.new(:schema).apply(payload)
    expect(actual).to eq(
      'dbc' => {
        'fed' => 'FED'
      },
      'included' => [
        {
          'txt' => 'txt'
        },
        {
          'txt' => 'txt2'
        }
      ]
    )
  end

  it 'works when you pass a hash' do
    schema = {
      'type' => 'object',
      'properties' => {
        'dbc' => {
          'type' => 'object',
          'properties' => {
            'fed' => { 'type' => 'string' }
          }
        },
        'included' => {
          'type' => 'array',
          'properties' => {
            'txt' => { 'type' => 'string' }
          }
        }
      }
    }
    JsonReducer.register(:schema, schema, file: false)
    actual = JsonReducer.new(:schema).apply(payload)
    expect(actual).to eq(
      'dbc' => {
        'fed' => 'FED'
      },
      'included' => [
        {
          'txt' => 'txt'
        },
        {
          'txt' => 'txt2'
        }
      ]
    )
  end

  it 'returns filtered schema down to last node' do
    schema =  {
      'type' => 'object',
      'properties' => {
        'foo' => {
          'type' => 'object',
          'properties' => {
            'bar' => {
              'type' => 'object',
              'properties' => {
                'title' => { 'type' => 'string' }
              }
            }
          }
        }
      }
    }

    JsonReducer.register(:schema, schema.to_json, file: false)
    actual = JsonReducer.new(:schema).apply(payload)

    expect(actual).to eq(
      'foo' => {
        'bar' => {
          'title' => 'BAR'
        }
      }
    )
  end

  it 'returns filtered schema down to last node 2' do
    schema =  {
      'type' => 'object',
      'properties' => {
        'foo' => { 'type' => 'object' }
      }
    }

    JsonReducer.register(:schema, schema.to_json, file: false)
    actual = JsonReducer.new(:schema).apply(payload)

    expect(actual).to eq(
      'foo' => {
        'bar' => {
          'title' => 'BAR',
          'body' => 'Body of the BAR'
        },
        'baz' => 'BAZ'
      }
    )
  end

  it 'ignores non-existing properties' do
    schema =  {
      'type' => 'object',
      'properties' => {
        'foo' => { 'type' => 'object' },
        'xyz' => { 'type' => 'string' }
      }
    }

    JsonReducer.register(:schema, schema.to_json, file: false)
    actual = JsonReducer.new(:schema).apply(payload)

    expect(actual).to eq(
      'foo' => {
        'bar' => {
          'title' => 'BAR',
          'body' => 'Body of the BAR'
        },
        'baz' => 'BAZ'
      }
    )
  end

  it 'works for complex cases' do
    schema = {
      'type' => 'object',
      'properties' => {
        'foo' => {
          'type' => 'object',
          'properties' => {
            'bar' => { 'type' => 'object' }
          }
        },
        'abc' => {
          'type' => 'object',
          'properties' => {
            'def' => { 'type' => 'string' }
          }
        }
      }
    }

    JsonReducer.register(:schema, schema.to_json, file: false)
    actual = JsonReducer.new(:schema).apply(payload)

    expect(actual).to eq(
      'foo' => {
        'bar' => {
          'title' => 'BAR',
          'body' => 'Body of the BAR'
        }
      },
      'abc' => {
        'def' => 'DEF'
      }
    )
  end

  it 'works for nexted complex cases' do
    JsonReducer.base_path("#{Dir.pwd}/spec/support")
    JsonReducer.register(:schema, 'schema.json')
    actual = JsonReducer.new(:schema).apply(payload)

    expect(actual).to eq(
      'foo' => {
        'bar' => {
          'title' => 'BAR',
          'body' => 'Body of the BAR'
        }
      },
      'abc' => {
        'def' => 'DEF'
      },
      'dbc' => {
        'fed' => 'FED'
      }
    )
  end

  describe '#base_path' do
    it 'sets the base_path' do
      path = 'lib/schemas'
      JsonReducer.base_path(path)
      expect(JsonReducer::Schemas.instance.base_path).to eq path
    end
  end
end
