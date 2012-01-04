require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class ValidatedConfig < SVUtil::Config
  validator do |c|
    err("Output dir must be provided") unless c.output_dir
  end
end

class TestValidations < Test::Unit::TestCase
  include SVUtil

  def setup
    @validated_config = ValidatedConfig.new
  end
  
  def test_custom_validation_error
    @validated_config.expects(:err).times(1)
    @validated_config.output_dir = nil
    @validated_config.validate
  end
  
  def test_custom_validation
    @validated_config.expects(:err).never
    @validated_config.output_dir = "foo"
    assert @validated_config.validate
  end
end
