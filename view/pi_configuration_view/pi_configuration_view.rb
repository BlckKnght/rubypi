require 'gtk3'

require_relative 'planet_tool_palette.rb'
require_relative 'planet_list.rb'
require_relative 'save_to_yaml_dialog.rb'
require_relative 'load_from_yaml_dialog.rb'

class PIConfigurationView < Gtk::Box
  def initialize(controller)
	# Set up base GTK+ requirements.
	super(:vertical)
	
	# Store the controller whose actions this view can use.
	@controller = controller
	
	# Description and up button row widgets.
	description_label = Gtk::Label.new("PI Configuration View")
	
	import_from_yaml_button = Gtk::Button.new(:stock_id => Gtk::Stock::OPEN)
	import_from_yaml_button.signal_connect("clicked") do |button|
	  self.load_from_yaml
	end
	
	export_to_yaml_button = Gtk::Button.new(:stock_id => Gtk::Stock::SAVE)
	export_to_yaml_button.signal_connect("clicked") do |button|
	  self.save_to_yaml
	end
	
	# Pack the description and up button row widgets.
	top_row = Gtk::Box.new(:horizontal)
	top_row.pack_start(description_label, :expand => true)
	top_row.pack_start(import_from_yaml_button, :expand => false)
	top_row.pack_start(export_to_yaml_button, :expand => false)
	self.pack_start(top_row, :expand => false)
	
	
	# Create the Bottom Row
	bottom_row = Gtk::Box.new(:horizontal)
	
	# Set up all the widgets unique to this view. Delegate to subclasses where necessary.
	# Left column.
	left_column_frame = Gtk::Frame.new
	left_column_vbox = Gtk::Box.new(:vertical)
	@planet_tool_palette = PlanetToolPalette.new(@controller)
	left_column_vbox.pack_start(@planet_tool_palette, :expand => false)
	left_column_frame.add(left_column_vbox)
	
	
	# Center column.
	center_column_frame = Gtk::Frame.new
	center_column = Gtk::Box.new(:vertical)
	
	planet_list_scrolled_window = Gtk::ScrolledWindow.new
	planet_list_scrolled_window.set_policy(Gtk::PolicyType::AUTOMATIC, Gtk::PolicyType::AUTOMATIC)
	
	@planet_list = PlanetList.new(@controller)
	planet_list_scrolled_window.add(@planet_list)
	
	
	button_box = Gtk::Box.new(:horizontal)
	edit_selected_button = Gtk::Button.new(:stock_id => Gtk::Stock::EDIT)
	edit_selected_button.signal_connect("clicked") do |button|
	  unless (@planet_list.selected_planet_instance == nil)
		@controller.edit_selected_planet(@planet_list.selected_planet_instance)
	  end
	end
	button_box.pack_end(edit_selected_button, :expand => false)
	
	center_column.pack_start(planet_list_scrolled_window, :expand => true)
	center_column.pack_start(button_box, :expand => false)
	center_column_frame.add(center_column)
	
	# Right column.
	right_column_frame = Gtk::Frame.new
	right_column = Gtk::Box.new(:vertical)
	eve_gate_image = Gtk::Image.new(:file => "view/images/eve_gate_128x128.png")
	@num_colonized_planets_label = Gtk::Label.new("Colonized Planets: 0")
	
	right_column.pack_start(eve_gate_image, :expand => false)
	right_column.pack_start(@num_colonized_planets_label, :expand => false)
	right_column_frame.add(right_column)
	
	bottom_row.pack_start(left_column_frame, :expand => false)
	bottom_row.pack_start(center_column_frame, :expand => true, :fill => true)
	bottom_row.pack_start(right_column_frame, :expand => false)
	
	self.pack_start(bottom_row, :expand => true)
	
	self.show_all
	
	return self
  end
  
  def save_to_yaml
	dialog = SaveToYamlDialog.new($ruby_pi_main_gtk_window)
	
	# Run the dialog.
	if dialog.run == Gtk::ResponseType::ACCEPT
	  # Get the filename the user gave us.
	  user_set_filename = dialog.filename
	  
	  # Append .yml to it, if necessary.
	  unless (user_set_filename.end_with?(".yml"))
		user_set_filename += ".yml"
	  end
	  
	  @controller.export_to_file(user_set_filename)
	end
	
	dialog.destroy
  end
  
  def load_from_yaml
	dialog = LoadFromYamlDialog.new($ruby_pi_main_gtk_window)
	
	# Run the dialog.
	if dialog.run == Gtk::ResponseType::ACCEPT
	  @controller.import_from_file(dialog.filename)
	end
	
	dialog.destroy
  end
  
  def pi_configuration_model=(new_model)
	# Update the view using the new model for values.
	@planet_list.pi_configuration_model = new_model
	
	@num_colonized_planets_label.text = "Colonized Planets: #{new_model.num_planets}"
  end
end