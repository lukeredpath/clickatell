class Hash
  # Returns a new hash containing only the keys specified
  # that exist in the current hash.
  #
  #  {:a => '1', :b => '2', :c => '3'}.only(:a, :c)
  #  # => {:a => '1', :c => '3'}
  #
  # Keys that do not exist in the original hash are ignored.
  def only(*keys)
    self.inject({}) do |new_hash, (key, value)|
      new_hash[key] = value if keys.include?(key)
      new_hash
    end
  end
end