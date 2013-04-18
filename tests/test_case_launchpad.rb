require "test/unit"

require_relative "../model/launchpad.rb"

class TestCaseLaunchpad < Test::Unit::TestCase
  def setup
	@building = Launchpad.new
  end
  
  def teardown
	# nada
  end
  
  def test_powergrid_usage_value
	assert_equal(700, @building.powergrid_usage)
  end
  
  def test_cpu_usage_value
	assert_equal(3600, @building.cpu_usage)
  end
  
  def test_powergrid_provided_value
	assert_equal(0, @building.powergrid_provided)
  end
  
  def test_cpu_provided_value
	assert_equal(0, @building.cpu_provided)
  end
  
  def test_isk_cost_value
	assert_equal(900000.00, @building.isk_cost)
  end
  
  def test_name
	assert_equal("Launchpad", @building.name)
  end
end