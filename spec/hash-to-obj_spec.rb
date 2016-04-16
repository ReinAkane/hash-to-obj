require 'spec_helper'

module TestDefaultModule
  def b
    nil
  end
end

describe HashToObj do
  it 'has a version number' do
    expect(HashToObj::VERSION).not_to be nil
  end

  it 'adds hash reader methods' do
    hash = { a: nil, b: 1, c3: 'c' }
    objectify hash

    expect(hash).to respond_to(:a)
    expect(hash).to respond_to(:b)
    expect(hash).to respond_to(:c3)
  end

  it 'adds hash writer methods' do
    hash = { :a => nil, 'b' => 1, :c3 => 'c' }
    objectify hash

    expect(hash).to respond_to(:a=)
    expect(hash).to respond_to(:b=)
    expect(hash).to respond_to(:c3=)
  end

  it 'errors on weird keys' do
    stupid_hash = { "I'm a very stupid key." => nil }
    expect { objectify stupid_hash }.to raise_error(ArgumentError)

    less_stupid_hash = { IM_A_CONSTANT: nil }
    expect { objectify less_stupid_hash }.to raise_error(ArgumentError)

    number_hash = { 1 => nil }
    expect { objectify number_hash }.to raise_error(ArgumentError)
  end

  it 'adds functional hash reader methods' do
    hash = { my_key: 'value', another_key: 'another_value' }
    objectify hash

    expect(hash.my_key).to eq('value')
    expect(hash.another_key).to eq('another_value')

    expect(hash.my_key).to eq(hash[:my_key])
    expect(hash.another_key).to eq(hash[:another_key])
  end

  it 'adds functional hash writer methods' do
    hash = { my_key: 'value', another_key: 'another_value' }
    objectify hash

    hash.my_key = 1
    hash.another_key = 2

    expect(hash.my_key).to eq(1)
    expect(hash.another_key).to eq(2)

    expect(hash.my_key).to eq(hash[:my_key])
    expect(hash.another_key).to eq(hash[:another_key])
  end

  it 'can still be edited like a normal hash' do
    hash = { my_key: 'value', another_key: 'another_value' }
    objectify hash

    hash[:my_key] = 1
    hash[:another_key] = 2

    expect(hash.my_key).to eq(1)
    expect(hash.another_key).to eq(2)

    expect(hash.my_key).to eq(hash[:my_key])
    expect(hash.another_key).to eq(hash[:another_key])
  end

  it 'references the same objects as the hash' do
    hash = { a: Object.new, b: Object.new }
    objectify hash

    expect(hash.a.object_id).to eq(hash[:a].object_id)
    expect(hash.b.object_id).to eq(hash[:b].object_id)

    hash.a = Object.new
    hash[:b] = Object.new

    expect(hash.a.object_id).to eq(hash[:a].object_id)
    expect(hash.b.object_id).to eq(hash[:b].object_id)
  end

  it 'returns the same hash' do
    hash = { a: 'b' }
    expect(objectify(hash)).to eq(hash)
  end

  it 'can use a default module' do
    hash = { a: 'b' }

    objectify hash, default_module: TestDefaultModule

    expect(hash).to respond_to(:b)

    expect(hash.b).to be nil
    expect(hash.a).to eq('b')
  end

  it 'will override default module methods' do
    hash = { b: 'b' }

    objectify hash, default_module: TestDefaultModule

    expect(hash).to respond_to(:b)
    expect(hash).to respond_to(:b=)

    expect(hash.b).to eq('b')
  end

  it 'errors with a bad duck type' do
    expect { objectify 'yarr' }.to raise_error(ArgumentError)
  end
end
