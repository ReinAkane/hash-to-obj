require "hash-to-obj/version"

##
# We extend this to objectify our hashes. It will generate some methods on the
# hash to access the various keys.
class HashToObj
  ##
  # Anything that you want to objectify needs to respond to these methods like a
  # Hash would. If it doesn't at least respond_to? these methods, an error will
  # be thrown when objectifying.
  DUCK_TYPE_API = [:[], :[]=]

  ##
  # Throws an error if hash doesn't have all messages defined in DUCK_TYPE_API.
  # Generates the accessors for all keys on the passed hash. Unless
  # override_warnings is true-y, this will throw errors if we're gonna screw
  # anything up. If you pass something that responds to :puts in
  # override_warnings then warnings will just be puts'd to that, and things will
  # continue.
  def self.objectify(hash, override_warnings=false)
    # Make sure it looks SOMEWHAT familiar.
    DUCK_TYPE_API.each do |method_sym|
      unless hash.respond_to?(method_sym) then
        raise(ArgumentException,
              "Cannot objectify something that doesn't look like a hash.")
      end
    end
    
    # Now lets actually add those methods.
    hash.each_key do |key|
      generate_accessors(hash, key, override_warnings)
    end
  end
  
  private
  
  ##
  # Generates the accessors for the passed key on the passed hash. Unless
  # override_warnings is true-y, this will throw errors if we're gonna screw
  # anything up. If you pass something that responds to :puts in
  # override_warnings then warnings will just be puts'd to that, and things will
  # continue.
  def self.generate_accessors(hash, key, override_warnings=false)
    unless override_warnings || warn(hash, key) then
      if override_warnings.respond_to?(:puts) then
        override_warnings.puts(warn(hash, key))
      else
        raise ArgumentException, warn(hash, key)
      end
    end
    
    valid_key = valid_key?(key)
    hash.define_singleton_method(valid_key) do
      self[key]
    end
    hash.define_singleton_method("#{valid_key}=") do |value|
      self[key] = value
    end
  end
  
  ##
  # Returns a valid method name for the passed key if there is one, otherwise
  # returns false.
  def self.valid_key?(key)
    regex_match = key.match(/\A[a-z_]+\Z/)
    if regex_match.nil? then
      return false
    else
      return key.to_s
    end
  end
  
  ##
  # If there should be a warning, returns the warning message. Otherwise returns
  # false.
  def self.should_warn?(hash, key)
    valid_key = valid_key?(key)
  
    # Make sure its a valid key...
    unless valid_key then
      return "#{key} is not a valid key."
    end
    # And make sure they don't have this method...
    if hash.respond_to?(valid_key) then
      return "#{hash} already has a #{valid_key} method defined."
    end
    if hash.respond_to?("#{valid_key}=") then
      return "#{hash} already has a #{valid_key}= method defined."
    end
    
    return false
  end
end

if respond_to?(:objectify) then
  unless HashToObj.const_defined(:SQUELCH_GLOBAL_WARNINGS) then
    puts "Global already has an objectify method. "\
         "Call HashToObj.objectify instead."
  end
else
  def self.objectify(hash, override_warnings=false)
    HashToObj.objectify(hash, override_warnings)
  end
end