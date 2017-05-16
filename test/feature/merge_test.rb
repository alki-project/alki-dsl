require 'alki/feature_test'

describe 'Merging Dsls' do
  before do
    @dsl1 = build_dsl do
      init do
        ctx[:result] << :init1
      end
      helper :do_one do
        ctx[:result] << :one
      end
      dsl_method :one do
        do_one
      end
      finish do
        ctx[:result] << :finish1
      end
    end
    @dsl2 = build_dsl do
      init do
        ctx[:result] << :init2
      end
      helper :do_two do
        ctx[:result] << :two
      end
      dsl_method :two do
        do_two
      end
      finish do
        ctx[:result] << :finish2
      end
    end
    @merged = Alki::Dsl.merge(@dsl1,@dsl2)
  end

  def build(dsl = @merged,&blk)
    dsl.build result: [], &(blk || ->{})
  end

  it 'should run init and finish blocks of both dsls in order' do
    build.must_equal %i(init1 init2 finish2 finish1)
  end

  it 'should expose dsl methods of both dsls' do
    result = build { one; two }
    result.must_include :one
    result.must_include :two
  end

  it 'should provide helpers from both dsls when required by another dsl' do
    merged = @merged
    dsl = build_dsl do
      require_dsl merged

      finish do
        do_one
        do_two
      end
    end
    result = build(dsl)

    result.must_include :one
    result.must_include :two
  end
end
