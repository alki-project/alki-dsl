Alki do
  require_dsl 'alki_test/dsls/value'

  init do
    self.value = 0
  end

  dsl_method :succ do
    self.value += 1
  end
end