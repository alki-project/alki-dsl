Alki do
  require_dsl 'alki/dsls/class_dsl'

  helper :value= do |v|
    ctx[:value] = v
  end

  helper :value do
    ctx[:value]
  end

  finish do
    create_as_module
    value = ctx[:value]
    add_class_method :new do
      value
    end
  end
end