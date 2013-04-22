require "test/unit"

require_relative "../model/schematic.rb"
require_relative "../model/product.rb"

class TestCaseSchematic < Test::Unit::TestCase
  # Run once.
  def self.startup
	@@snip = Product.find_or_create("Snip", 0)
	@@snail = Product.find_or_create("Snail", 0)
	@@puppy_dog_tail = Product.find_or_create("Puppy Dog Tail", 0)
	@@boy = Product.find_or_create("Boy", 1)
	
	@@sugar = Product.find_or_create("Sugar", 0)
	@@spice = Product.find_or_create("Spice", 0)
	@@everything_nice = Product.find_or_create("Everything Nice", 0)
	@@girl = Product.find_or_create("Girl", 1)
	
	@@boy_schematic = Schematic.new(@@boy, 1, {@@snip => 100, @@snail => 100, @@puppy_dog_tail => 100})
	@@girl_schematic = Schematic.new(@@girl, 1, {@@sugar => 100, @@spice => 100, @@everything_nice => 100})
  end
  
  # Run once after all tests.
  def self.shutdown
  end
  
  # Run before every test.
  def setup
  end
  
  # Run once after every test.
  def teardown
  end
  
  def test_creating_a_schematic_only_adds_one_schematic_to_instances
	# Should have all the objects we created during self.setup.
	assert_true(Schematic.all.include?(@@boy_schematic))
	assert_true(Schematic.all.include?(@@girl_schematic))
	
	# Should have no more than the objects we created during self.setup.
	assert_equal(2, Schematic.all.count)
  end
  
  def test_can_delete_schematic
	# At this point we should have no more than the objects we created during self.setup.
	assert_equal(2, Schematic.all.count)
	
	# Create the products for our new schematic.
	stick = Product.find_or_create("Stick", 0)
	stone = Product.find_or_create("Stone", 0)
	bonebreaker = Product.find_or_create("Bonebreaker", 1)
	
	bonebreaker_schematic = Schematic.new(bonebreaker, 1, {stick => 100, stone => 100})
	
	# At this point we should have one extra product.
	assert_equal(3, Schematic.all.count)
	assert_true(Schematic.all.include?(bonebreaker_schematic))
	
	# Delete the product.
	Schematic.delete(bonebreaker_schematic)
	
	assert_false(Schematic.all.include?(bonebreaker_schematic))
	assert_equal(2, Schematic.all.count)
	
	# Clean up our temporary products.
	Product.delete(stick)
	Product.delete(stone)
	Product.delete(bonebreaker)
  end
  
  def test_can_search_for_schematics_by_name
	found_boy_schematic = Schematic.find_schematic_by_name("Boy")
	found_girl_schematic = Schematic.find_schematic_by_name("Girl")
	
	# Should return @@snip.
	assert_equal(@@boy_schematic, found_boy_schematic)
	assert_equal(@@girl_schematic, found_girl_schematic)
  end
  
  def test_can_search_for_schematics_by_p_level
	# P1
	schematics_that_produce_p_ones = Schematic.find_schematics_by_p_level(1)
	
	# Should have all the objects we created during self.setup.
	assert_true(schematics_that_produce_p_ones.include?(@@boy_schematic))
	assert_true(schematics_that_produce_p_ones.include?(@@girl_schematic))
	
	# Should have no more than the objects we created during self.setup.
	assert_equal(2, schematics_that_produce_p_ones.count)
  end
  
  def test_p_level_matches_output_product_p_level
	assert_equal(@@boy_schematic.p_level, @@boy.p_level)
  end
  
  def test_can_add_input
	# Make sure it is what we expect.
	boy_inputs_hash = {@@snip => 100, @@snail => 100, @@puppy_dog_tail => 100}
	assert_equal(@@boy_schematic.inputs, boy_inputs_hash)
	
	@@boy_schematic.add_input({@@everything_nice => 100})
	
	boy_inputs_hash_with_everything_nice = {@@snip => 100, @@snail => 100, @@puppy_dog_tail => 100, @@everything_nice => 100}
	assert_equal(@@boy_schematic.inputs, boy_inputs_hash_with_everything_nice)
	
	# Reset for other parallelized tests.
	@@boy_schematic.remove_input(@@everything_nice)
	assert_equal(@@boy_schematic.inputs, boy_inputs_hash)
  end
  
  def test_error_if_input_is_wrong_format
	# Fail if not a hash.
	assert_raise ArgumentError do
	  @@boy_schematic.add_input("faaaail")
	end
	
	# Fail if key isn't a product.
	assert_raise ArgumentError do
	  @@boy_schematic.add_input("faaaail" => 100)
	end
	
	# Fail if value isn't a number.
	assert_raise ArgumentError do
	  @@boy_schematic.add_input(@@snip => "faaaail")
	end
	
	# Fail if input already exists.
	assert_raise ArgumentError do
	  @@boy_schematic.add_input(@@snip => 100)
	end
	
	# Make sure inputs haven't changed.
	boy_inputs_hash = {@@snip => 100, @@snail => 100, @@puppy_dog_tail => 100}
	assert_equal(@@boy_schematic.inputs, boy_inputs_hash)
  end
  
  def test_can_remove_input
	boy_inputs_hash_with_snip = {@@snip => 100, @@snail => 100, @@puppy_dog_tail => 100}
	assert_equal(@@boy_schematic.inputs, boy_inputs_hash_with_snip)
	
	@@boy_schematic.remove_input(@@snip)
	
	boy_inputs_hash_without_snip = {@@snail => 100, @@puppy_dog_tail => 100}
	assert_equal(@@boy_schematic.inputs, boy_inputs_hash_without_snip)
	
	# Reset for other parallelized tests.
	@@boy_schematic.add_input(@@snip => 100)
	assert_equal(@@boy_schematic.inputs, boy_inputs_hash_with_snip)
  end
end