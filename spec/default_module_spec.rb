require 'spec_helper'

module TestDefaultModuleDSL
  extend HashToObj::DefaultModule
  
  default_key :a
  default_key :b, 'b'
  default_key 'c', []
end

describe HashToObj::DefaultModule do
  it 'creates the helper methods' do
    expect(TestDefaultModuleDSL.method_defined?(:a)).to be true
    expect(TestDefaultModuleDSL.method_defined?(:b)).to be true
    expect(TestDefaultModuleDSL.method_defined?(:c)).to be true
    expect(TestDefaultModuleDSL.method_defined?(:a=)).to be true
    expect(TestDefaultModuleDSL.method_defined?(:b=)).to be true
    expect(TestDefaultModuleDSL.method_defined?(:c=)).to be true
  end
  
  it 'stores the default value' do
    hash = { }
    objectify hash, default_module: TestDefaultModuleDSL
    
    expect(hash.a).to be nil
    expect(hash.b).to eq('b')
    expect(hash.c).to eq([])
  end
  
  it 'stores the same object as a default value' do
    hash = { }
    objectify hash, default_module: TestDefaultModuleDSL
    
    hash.c << 0
    expect(hash.c.empty?).to be false
    expect(hash.c.first).to eq(0)
    
    hash.c << 1
    expect(hash.c.first).to eq(0)
    expect(hash.c[1]).to eq(1)
  end
  
  it 'uses the new value if one is set' do
    hash = { }
    objectify hash, default_module: TestDefaultModuleDSL
    
    hash.a = 0
    expect(hash.a).to eq(0)
    expect(hash[:a]).to eq(0)
    
    hash['c'] = 2
    expect(hash.c).to eq(2)
    hash.c = 3
    expect(hash.c).to eq(3)
    expect(hash['c']).to eq(3)
  end
end