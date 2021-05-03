require_relative '../Model/CivilModel'

module CivilController
  include CivilHelper
  @model = CivilModel
  extend self

  def create_space_from_face input_h
    puts "Create_space_from_face : #{input_h}"
    face = Sketchup.active_model.selection[0]
    unless face.is_a?(Sketchup::Face)
      puts "Selection is not a face. Please select a face for room creation"
      return false
    end

    room_name = input_h[:spaceName]
    room_names = get_room_names
    if room_names.include?(room_name)
      puts "Room name already present"
      return false
    end
    room_h = {:room_name=>room_name}

    wall_depth = input_h[:wallHeight].to_i.mm
    door_height = input_h[:doorHeight].to_i.mm
    window_height = input_h[:windowHeight].to_i.mm
    vertical_offset = input_h[:verticalOffset].to_i.mm

    if door_height > wall_depth
      puts "Door height cannot be greater than Wall"
      return false
    end

    if (window_height > wall_depth) ||
      (window_height+vertical_offset > wall_depth)
      puts "Window height cannot be greater than Wall height"
      return false
    end

    room_h[:wall_depth] = wall_depth
    room_h[:door_height] = door_height
    room_h[:window_height] = window_height
    room_h[:vertical_offset] = vertical_offset
    @model.create_room face, room_h
  end

  def select_edges_for_floor param_h
    puts "select_edges_for_floor : #{param_h}"
    seln = Sketchup.active_model.selection
    edge_list = seln.grep(Sketchup::Edge)
    edge_type = param_h[:edgeType]
    if edge_list.empty?
      return ["failure", "No Edges selected. Please select edges for marking as #{edge_type}"]
    end

    edge_list.each{ |sel_edge|
      sel_edge.set_attribute('sdk_atts', 'floor_edge_type', edge_type)
    }
    return ["success", "Edges marked as #{edge_type}"]
  end
end
