require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class ValidatedConfig < SVUtil::Config
  validator do |c|
    err("Output dir must be provided") unless c.output_dir
  end
end

class TestValidations < Test::Unit::TestCase
  include SVUtil

  def setup
  end
  
  def test_custom_validation_error
    ValidatedConfig.expects(:err).times(1)
    ValidatedConfig.output_dir = nil
    ValidatedConfig.validate
  end
  
  def test_custom_validation
    ValidatedConfig.expects(:err).never
    ValidatedConfig.output_dir = "foo"
    assert ValidatedConfig.validate
  end
end
