require 'hash-to-obj/version'

##
# We extend this to objectify our hashes. It will generate some methods on the
# hash to access the various keys.
#
# Define a constant HashToObj::SQUELCH_GLOBAL_WARNINGS to squelch warnings about
# objectify already being defined.
module HashToObj
  ##
  # Anything that you want to objectify needs to respond to these methods like a
  # Hash would. If it doesn't at least respond_to? these methods, an error will
  # be thrown when objectifying.
  DUCK_TYPE_API = [:[], :[]=, :each_key].freeze

  ##
  # Throws an error if hash doesn't have all messages defined in DUCK_TYPE_API.
  # Generates the accessors for all keys on the passed hash.
  #
  # Accepted options:
  # [override_warnings] Unless override_warnings is truthy, this will throw
  #                     errors if we're gonna screw anything up. If you pass
  #                     something that responds to :puts in override_warnings
  #                     then warnings will just be puts'd to that, and things
  #                     will continue.
  # [default_module] If a default_module is specified, that will be included
  #                  in the hash before adding our accessors, essentially
  #                  allowing you to define a set of methods that should be
  #                  present after objectifying regardless of the keys in the
  #                  hash.
  def self.objectify(hash, options = {})
    if options.is_a?(Hash) then
      internal_objectify(hash,
                         options[:override_warnings],
                         options[:default_module])
    else
      unless HashToObj.const_defined?(:SQUELCH_GLOBAL_WARNINGS) then
        puts "objectify(hash, override_warnings) is deprecated.\n"\
             '  please use objectify(hash, override_warnings: true) instead.'
      end
      # Looks like they're using 0.1.0 API.
      internal_objectify(hash, options)
    end
  end
  
  #-------------------------------------------------------------------------
  # :section: Internal Methods
  # Usually don't want to mess with these if you're not part of hash-to-obj.
  #-------------------------------------------------------------------------
  
  ##
  # Internal version of objectify. Uses seperated arguments instead of options
  # hash.
  def self.internal_objectify(hash,
                              override_warnings = false,
                              default_module = nil)
    # Make sure it looks SOMEWHAT familiar.
    unless quacks?(hash) then
      raise(ArgumentError,
            "Cannot objectify something that doesn't look like a hash.")
    end

    # Now lets actually add those methods.
    hash.each_key { |key| generate_accessors(hash, key, override_warnings) }

    hash.extend(default_module) if default_module

    hash
  end

  ##
  # Returns true if the passed object responds to all methods defined in
  # DUCK_TYPE_API.
  def self.quacks?(obj)
    DUCK_TYPE_API.each do |method_sym|
      unless obj.respond_to?(method_sym) then
        return false
      end
    end

    true
  end

  ##
  # Generates the accessors for the passed key on the passed hash. Unless
  # override_warnings is true-y, this will throw errors if we're gonna screw
  # anything up. If you pass something that responds to :puts in
  # override_warnings then warnings will just be puts'd to that, and things will
  # continue.
  def self.generate_accessors(hash, key, override_warnings = false)
    handle_warnings(hash, key, override_warnings)

    valid_key = valid_key?(key)
    hash.define_singleton_method(valid_key) { self[key] }
    hash.define_singleton_method("#{valid_key}=") do |value|
      self[key] = value
    end
  end

  ##
  # This will output any warnings we want to output.
  def self.handle_warnings(hash, key, override_warnings = false)
    if !override_warnings && should_warn?(hash, key) then
      if override_warnings.respond_to?(:puts) then
        override_warnings.puts(should_warn?(hash, key))
      else
        raise ArgumentError, should_warn?(hash, key)
      end
    end
  end

  ##
  # Returns a valid method name for the passed key if there is one, otherwise
  # returns false.
  def self.valid_key?(key)
    regex_match = key.to_s.match(/\A[a-z_][a-z0-9_]*\Z/)
    return false if regex_match.nil?
    return key.to_s
  end

  ##
  # If there should be a warning, returns the warning message. Otherwise returns
  # false.
  def self.should_warn?(hash, key)
    valid_key = valid_key?(key)

    # Make sure its a valid key...
    return "#{key} is not a valid key." unless valid_key
    # And make sure they don't have this method...
    if hash.respond_to?(valid_key) then
      return "#{hash} already has a #{valid_key} method defined."
    end
    if hash.respond_to?("#{valid_key}=") then
      return "#{hash} already has a #{valid_key}= method defined."
    end

    false
  end
end

# This is an ugly ugly way of checking if the objectify method is defined
# somewhere already. For whatever reason :respond_to? is simply not returning
# the correct result.
if begin
    method(:objectify)
    true
  rescue NameError
    false
  end then

  unless HashToObj.const_defined?(:SQUELCH_GLOBAL_WARNINGS) then
    puts 'Global already has an objectify method. '\
         'Call HashToObj.objectify instead.'
  end
else
  ##
  # See {HashToObj::objectify}[rdoc-ref:HashToObj::objectify]
  def objectify(*args)
    HashToObj.objectify(*args)
  end
end
