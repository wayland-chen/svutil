require File.dirname(__FILE__) + '/test_helper.rb'

class TestDefaults < Test::Unit::TestCase
  include SVUtil

  def test_set
    defaults = Defaults.new
    assert !defaults.default_for('person')
    defaults.person = 'daniel'
    assert_equal 'daniel', defaults.default_for('person')
  end
end

