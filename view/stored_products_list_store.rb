require 'gtk3'

# Holds a lists of products stored in the building.
# Uses "stored_products" accessor from UnrestrictedStorage and IndustrialFacilityStorage modules.
class StoredProductsListStore < Gtk::ListStore
  def initialize(building_model = nil)
	
	@building_model = building_model
	
	# Set up columns.
	super(Gdk::Pixbuf,	# Icon
	      String,		# Name
	      Integer,		# Quantity
	      Integer		# Volume
	      )
	
	# Update self from @building_model.
	self.update
	
	return self
  end
  
  def start_observing_model
	if (@building_model != nil)
	  @building_model.add_observer(self)
	end
  end
  
  def stop_observing_model
	if (building_model != nil)
	  @building_model.delete_observer(self)
	end
  end
  
  def building_model
	return @building_model
  end
  
  def building_model=(new_building_model)
	# Destroy observer on current building model.
	self.stop_observing_model
	
	@building_model = new_building_model
	self.update
	
	self.start_observing_model
  end
  
  # Called when the building says it changes.
  def update
	# Don't update the Gtk/Glib C object if it's in the process of being destroyed.
	unless (self.destroyed?)
	  self.clear
	  
	  if (@building_model != nil)
		# Update planet building list from model.
		@building_model.stored_products.each_pair do |product_name, quantity_stored|
		  new_row = self.append
		  # new_row.set_value(0, ProductImage.new(product_name, [32, 32]).pixbuf)
		  new_row.set_value(1, product_name)
		  new_row.set_value(2, quantity_stored)
		  
		  # Product volume
		  product_volume = Product.find_by_name(product_name).volume
		  new_row.set_value(3, product_volume)
		  
		end
	  end
	end
  end
  
  def destroy
	self.stop_observing_model
  end
end