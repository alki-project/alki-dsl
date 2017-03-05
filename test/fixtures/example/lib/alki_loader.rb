number_dsl = Alki::Dsl.merge 'alki_test/dsls/number', 'alki_test/dsls/simple'
Alki::Loader.register '../numbers', builder: number_dsl, name: 'alki_test/numbers'
Alki::Loader.register 'alki_test/dsls', builder: 'alki/dsls/dsl'
