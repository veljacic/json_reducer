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
        'abc' => {'type' => 'object'}
      }
    }

    dbc_schema = {
      'type' => 'object',
      'properties' => {
        'dbc' => {'type' => 'object'}
      }
    }

    expect(JsonReducer::Mask.new(abc_schema).apply(payload)).to eq('abc' => {'def' => 'DEF'})
    expect(JsonReducer::Mask.new(dbc_schema).apply(payload)).to eq('dbc' => {'fed' => 'FED'})
  end

  it 'returns fieltered schema for array' do
    schema =  {
      'type' => 'object',
      'properties' => {
        'dbc' => {
          'type' => 'object',
          'properties' => {
            'fed' => {'type' => 'string'}
          }
        },
        'included' => {
          'type' => 'array',
          'properties' => {
            'txt' => {'type' => 'string'}
          }
        }
      }
    }
    actual = JsonReducer::Mask.new(schema).apply(payload)
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
                'title' => {'type' => 'string'}
              }
            }
          }
        }
      }
    }

    actual = JsonReducer::Mask.new(schema).apply(payload)

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
        'foo' => {'type' => 'object'}
      }
    }

    actual = JsonReducer::Mask.new(schema).apply(payload)

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
        'foo' => {'type' => 'object'},
        'xyz' => {'type' => 'string'}
      }
    }

    actual = JsonReducer::Mask.new(schema).apply(payload)

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
    schema =  {
      'type' => 'object',
      'properties' => {
        'foo' => {
          'type' => 'object',
          'properties' => {
            'bar' => {'type' => 'object'}
          }
        },
        'abc' => {
          'type' => 'object',
          'properties' => {
            'def' => {'type' => 'string'}
          }
        }
      }
    }

    actual = JsonReducer::Mask.new(schema).apply(payload)

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
    schema =  {
      'type' => 'object',
      'properties' => {
        'foo' => {
          'type' => 'object',
          'properties' => {
            'bar' => {'type' => 'object'}
          }
        },
        'abc' => {
          'type' => 'object',
          'properties' => {
            'def' => {'type' => 'string'}
          }
        },
        'dbc' => {
          'type' => 'object',
          'properties' => {
            'fed' => {'type' => 'string'}
          }
        }
      }
    }

    actual = JsonReducer::Mask.new(schema).apply(payload)

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
end
