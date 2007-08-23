class Hash
  def only(*keys)
    self.inject({}) do |new_hash, (key, value)|
      new_hash[key] = value if keys.include?(key)
      new_hash
    end
  end
end