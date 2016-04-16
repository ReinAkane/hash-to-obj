module HashToObj
  ##
  # Extend this for a small DSL around creating default methods.
  module DefaultModule
    ##
    # Defines a method that simulates a defaulted key in the hash. If the key is
    # added to the hash later, this will correctly pick up on that. You can
    # specify a default value as well. This value is NOT copied.
    def default_key(key, value=nil)
      define_method(key) { self.has_key?(key) ? self[key] : value }
      define_method("#{key}=") { |new_value| self[key] = new_value}
    end
  end
end