require_relative '../Helper/CivilHelper'
require_relative '../Helper/GeomHelper'
# class CivilModel
#   attr_accessor :height, :width, :depth, :room_name
#
#   def initialize(p_h)
#     set_model_params(p_h)
#   end
#
#   def set_model_params(p_h)
#     @height = p_h[:height]
#     @width = p_h[:width]
#     @depth = p_h[:depth]
#   end
# end
#
# class WallModel < CivilModel
#   attr_accessor :color, :edges, :start, :end, :perp_vector, :view_name, :thickness
#
#   def initialize(p_h)
#     super
#     @color = p_h[:color]
#     @edges = p_h[:edges]
#       #create_model
#   end
# end

module CivilModel
  #attr_accessor :room_name, :room_type, :area, :views, :face, :walls, :windows, :doors, :edges, :skpclass
  include CivilHelper
  extend self

  @@edge_colors = ['#FFC312', '#F79F1F', '#12CBC4', '#ED4C67',
                   '#1289A7', '#B53471', '#EE5A24', '#009432',
                   '#F97F51', '#FD7272']

  def get_face_views face, room_name
    puts "get_face_views : #{face}"
    cw_edges = get_cw_edge_list face
    edges = find_face_corner cw_edges
    face_views = find_views edges

    face_view_h = {}
    view_number = 1
    face_views.each{|view_arr|
      view_name = room_name + '_view_' + view_number.to_s
      face_view_h[view_name] = view_arr
      view_number += 1
    }
    face_view_h
  end

  #Get clockwise or Left->right edges in a list in a face
  def create_room face, input_h
    puts "create_room : #{input_h} : #{face}"
    edges = face.outer_loop.edges
    room_name = input_h[:room_name]

    dict = 'sdk_atts'; key = 'floor_edge_type'

    #Set all empty edges as walls
    wall_edges    = edges.select {|sel_edge| sel_edge.get_attribute(dict, key).nil?}
    wall_edges.each{|sel_edge| sel_edge.set_attribute(dict, key, 'wall') }

    #Get the view list from the edges
    view_h = get_face_views face, room_name

    #settings_data = SDESK::get_settings_data
    #wall_height = settings_data[:dev_test][:wall_height].mm #Thickness
    wall_height = 50.mm
    wall_depth = input_h[:wall_depth]
    door_height = input_h[:door_height]
    window_height = input_h[:window_height]
    vertical_offset = input_h[:vertical_offset]

    dict = 'sdk_atts'
    key = 'floor_edge_type'
    door_edges    = edges.select{|edge| edge.get_attribute(dict, key)=='door'}
    door_include_flag = true #if door_edges.length > 1
    window_edges  = edges.select{|edge| edge.get_attribute(dict, key)=='window'}
    window_include_flag = true #if window_edges.length > 1

    Sketchup.active_model.selection.clear
    room_color = @@edge_colors[(rand*100000)%9]
    puts room_color
    view_h.each_pair { |view_name, edge_arr|
      sort_pts =[];  clockwise_flag = nil;
      first_edge = nil; last_edge = nil;
      first_edge = edge_arr.first
      edge_arr.each {|input_edge|
        clockwise_flag = check_clockwise_edge input_edge, face
        pt1,pt2 = (clockwise_flag == 'clockwise') ? [input_edge.start, input_edge.end] : [input_edge.end, input_edge.start]
        #pt = clockwise_flag == 'clockwise' ? input_edge.start : input_edge.end
        sort_pts << pt1
        sort_pts << pt2
        puts "Pt 1 & 2 : #{pt1.position} : #{pt2.position}: #{clockwise_flag}"
        last_edge = input_edge
      }
      #sort_pts << [last_edge.end, last_edge.start]
      puts "sort_pts before : #{sort_pts.each{|x| puts " x : #{x.position}" }} +++++++"
      sort_pts.flatten!
      sort_pts.uniq!
      puts "sort_pts : #{sort_pts.each{|x| puts " x : #{x.position}" }} +++++++"
      pt = sort_pts.first.position
      start_point = Geom::Point3d.new(pt.x, pt.y, pt.z)
      pt = sort_pts.last.position
      end_point   = Geom::Point3d.new(pt.x, pt.y, pt.z)
      center_pt = Geom.linear_combination(0.5, start_point, 0.5, end_point)
      det = (start_point.x - center_pt.x) * (end_point.y - center_pt.y) - (end_point.x - center_pt.x) * (start_point.y - center_pt.y)

      height  = wall_height
      width   = start_point.distance(end_point)
      depth   = wall_depth
      wall_perp_vector = GeomHelper::get_perpendicular_vector edge_arr.first, face

      wall_comp = add_wall_comp width, height, depth, start_point, end_point
      wall_comp.material = room_color

      wall_dict_h = {
        'thickness' => wall_height.to_mm.round.to_s,
        'view_name' => view_name,
        'edges' => edge_arr.map{|ed| ed.persistent_id},
        'depth' => wall_depth.to_mm.round.to_s,
        'width' => width.to_mm.round.to_s, #To avoid mm in string and rounding values to store in dict
        'start_point' => start_point,
        'end_point' => end_point,
        'wall_vector' => start_point.vector_to(end_point),
        'perp_vector' => wall_perp_vector,
        'room_name' => room_name
      }
      wall_dict_h.each_pair{ |wkey, wvalue|
        wall_comp.set_attribute('sdk_atts', wkey, wvalue)
      }


      if door_include_flag
        door_edges    = edge_arr.select{|edge| edge.get_attribute(dict, key)=='door'}
        unless door_edges.empty?
          door_edges.each { |input_edge|
            #door_height = 1500.mm
            clockwise_flag = check_clockwise_edge input_edge, face
            pt1,pt2 = clockwise_flag == 'clockwise' ? [input_edge.start, input_edge.end] : [input_edge.end, input_edge.start]
            puts pt1
            door_offset = start_point.distance(pt1.position)
            door_length = pt1.position.distance(pt2.position)
            Sketchup.active_model.selection.add(input_edge)
            add_door_to_wall wall_comp, door_height, door_length, door_offset
          }
        end
      end
      if window_include_flag
        window_edges    = edge_arr.select{|edge| edge.get_attribute(dict, key)=='window'}
        unless window_edges.empty?
          window_edges.each { |input_edge|
            #window_height = 500.mm
            #vertical_offset = 500.mm
            clockwise_flag = check_clockwise_edge input_edge, face
            pt1,pt2 = clockwise_flag == 'clockwise' ? [input_edge.start, input_edge.end] : [input_edge.end, input_edge.start]
            puts pt1
            window_offset = start_point.distance(pt1.position)
            window_length = pt1.position.distance(pt2.position)
            Sketchup.active_model.selection.add(input_edge)
            add_window_to_wall wall_comp, window_height, window_length, window_offset, vertical_offset
          }
        end
      end
      #Sketchup.active_model.entities.erase_entities(wall_comp)
    }

    #Convert floor face to group
    floor_group = add_floor_group face, room_name

    return ["success", "Room Created successfully"]
  end

  def add_floor_group room_face, room_name

    #Create text component
    temp_group 			  = Sketchup.active_model.entities.add_group
    temp_entity_list 	= temp_group.entities
    text_scale 			  = room_face.bounds.height/50
    temp_entity_list.add_3d_text(room_name,  TextAlignCenter, "Arial", false, false, text_scale)
    text_component 		= temp_group.to_component
    text_definition 	= text_component.definition
    text_inst 			  = Sketchup.active_model.entities.add_instance text_definition, Geom::Transformation.new(room_face.bounds.center)

    texture_path = File.join(SDESK_ROOT_PATH ,'UI/assets/images' ,'/tile.jpg')
    materials = Sketchup.active_model.materials
    floor_material = materials.add('skpdesk room floor tile')
    floor_material.texture = texture_path
    floor_material.texture.size = [100]
    room_face.material = floor_material
    room_face.back_material = floor_material
    room_face.set_attribute('sdk_atts', 'room_name', room_name)

    floor_group = Sketchup.active_model.entities.add_group([room_face, text_inst])
    floor_group.set_attribute('sdk_atts', 'room_name', room_name)
    floor_group.set_attribute('sdk_atts', 'face_id', room_face.persistent_id)
    floor_group.set_attribute('sdk_atts', 'skp_class', 'FloorModel')

    #https://stackoverflow.com/questions/1887845/add-method-to-an-instanced-object
    floor_group.define_singleton_method(:face_id)   do;self.get_attribute('sdk_atts', 'face_id');end
    floor_group.define_singleton_method(:room_name) do;self.get_attribute('sdk_atts', 'room_name');end
    floor_group.define_singleton_method(:skp_class) do;self.get_attribute('sdk_atts', 'skp_class');end

    Sketchup.active_model.entities.erase_entities text_component unless text_component.deleted?

    return floor_group
  end

  def add_door_to_wall wall_comp, door_height, door_length, door_offset
    puts "add_door_to_wall : #{door_height} : #{door_length} : #{door_offset}"
    wall_origin = wall_comp.transformation.origin
    front_face = wall_comp.definition.entities.grep(Sketchup::Face).select{|face| face.get_attribute('skpdesk_face_atts', 'location', 'front')}[0]
    door_pts = [[door_offset ,0, 0], [door_offset+door_length,0,0],
                [door_offset+door_length, 0, door_height], [door_offset, 0, door_height]]
    model = Sketchup.active_model
    # settings_data = SDESK::get_settings_data
    # thickness = settings_data[:dev_test][:wall_height].mm
    thickness = 50.mm

    new_face = wall_comp.definition.entities.add_face(door_pts)
    new_face.pushpull(-thickness)

    add_real_door = true
    if add_real_door
      puts "add_real_door"
      door_skp = File.join(SDESK_ROOT_PATH, 'ext_assets','door.skp')
      door_defn = Sketchup.active_model.definitions.load(door_skp)

      door_inst 		= Sketchup.active_model.entities.add_instance door_defn, ORIGIN
      door_bbox 	= door_inst.bounds

      puts "door_bbox : #{door_bbox.width}"
      x_factor 	= door_length / door_bbox.width
      y_factor 	= thickness
      z_factor	= door_height / door_bbox.depth

      puts "door factors : #{x_factor} : #{y_factor} : #{z_factor}"
      door_inst.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))

      wall_trans = wall_comp.transformation
      wpt1, wpt2 = wall_trans*door_pts[0], wall_trans*door_pts[1]
      # wpt1.z	=	door_offset
      # wpt2.z 	= 	door_offset
      door_inst.transform!(Geom::Transformation.new(wpt1))
      extra = 0
      #Rotate instance
      trans_vector = wpt1.vector_to(wpt2)
      if trans_vector.y < 0
        trans_vector.reverse!
        extra = Math::PI
      end
      angle 	= extra + X_AXIS.angle_between(trans_vector)
      puts "door angle : #{angle} : #{trans_vector} : #{wpt1} #{wpt2}"
      door_inst.transform!(Geom::Transformation.rotation(wpt1, Z_AXIS, angle))

      door_dict_h = {
        'thickness' => thickness.to_mm.round,
        'view_name' => wall_comp.get_attribute('skpdesk_wall_atts', 'view_name'),
        'depth' => door_height.to_mm.round,
        'width' => door_length.to_mm.round, #To avoid mm in string and rounding values to store in dict
        'offset_start_point' => door_offset.to_mm.round,
        'room_name' => wall_comp.get_attribute('skpdesk_wall_atts', 'room_name')
      }
      door_dict_h.each_pair{ |dkey, dvalue|
        door_inst.set_attribute('skpdesk_door_atts', dkey, dvalue)
      }
    end
  end

  def add_window_to_wall wall_comp, window_height, window_length, window_offset, vertical_offset
    wall_comp.make_unique
    puts "add_window_to_wall : #{window_height} : #{window_length} : #{window_offset} : #{vertical_offset}"
    wall_origin = wall_comp.transformation.origin
    front_face = wall_comp.definition.entities.grep(Sketchup::Face).select{|face| face.get_attribute('skpdesk_face_atts', 'location', 'front')}[0]
    window_pts = [[window_offset ,0, vertical_offset], [window_offset+window_length,0,vertical_offset],
                  [window_offset+window_length, 0, vertical_offset+window_height], [window_offset, 0, vertical_offset+window_height]]
    model = Sketchup.active_model
    #new_pts = door_pts.map{|pt| wall_comp.transformation * pt}
    #thickness = wall_comp.get_attribute('skpdesk_wall_atts', 'thickness')
    thickness = 50.mm
    new_face = wall_comp.definition.entities.add_face(window_pts)
    new_face.pushpull(-thickness)


    add_real_window = true
    if add_real_window
      puts "add_real_window"
      window_skp = File.join(SDESK_ROOT_PATH, 'ext_assets', 'window.skp')
      window_defn = Sketchup.active_model.definitions.load(window_skp)

      window_inst 		= Sketchup.active_model.entities.add_instance window_defn, ORIGIN
      window_bbox 	= window_inst.bounds

      x_factor 	= window_length / window_bbox.width
      y_factor 	= thickness / window_bbox.height
      z_factor	= window_height / window_bbox.depth

      puts "factors : #{x_factor} : #{y_factor} : #{z_factor}"
      window_inst.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))

      wall_trans = wall_comp.transformation
      wpt1, wpt2 = wall_trans*window_pts[0], wall_trans*window_pts[1]
      # wpt1.z	=	window_offset
      # wpt2.z 	= 	window_offset
      window_inst.transform!(Geom::Transformation.new(wpt1))
      extra = 0
      #Rotate instance
      trans_vector = wpt1.vector_to(wpt2)
      if trans_vector.y < 0
        trans_vector.reverse!
        extra = Math::PI
      end
      angle 	= extra + X_AXIS.angle_between(trans_vector)
      puts "Window angle : #{angle} : #{trans_vector}"
      window_inst.transform!(Geom::Transformation.rotation(wpt1, Z_AXIS, angle))

      window_dict_h = {
        'thickness' => thickness.to_mm.round,
        'view_name' => wall_comp.get_attribute('skpdesk_wall_atts', 'view_name'),
        'depth' => window_height.to_mm.round,
        'width' => window_length.to_mm.round, #To avoid mm in string and rounding values to store in dict
        'offset_start_point' => window_offset.to_mm.round,
        'vertical_offset' => vertical_offset.to_mm.round,
        'room_name' => wall_comp.get_attribute('skpdesk_wall_atts', 'room_name')
      }
      window_dict_h.each_pair{ |wkey, wvalue|
        window_inst.set_attribute('skpdesk_window_atts', wkey, wvalue)
      }
    end
  end

  def create_cuboid_defn width, height, depth
    pt1 = ORIGIN
    pt2 = Geom::Point3d.new([width, 0, 0])
    y_offset_pt = pt2.offset(Y_AXIS, height)
    pt3 = Geom::Point3d.new([width, height, 0])
    pt4 = Geom::Point3d.new([0, height, 0])

    model = Sketchup.active_model
    pre_op_ents = model.entities.to_a

    #Setting values to use it any time later in the model
    bottom_face_pts = [pt1, pt2, pt3, pt4]
    top_face_pts    = bottom_face_pts.map{|pt| pt.offset(Z_AXIS, depth)}
    #puts bottom_face_pts, top_face_pts
    front_face_pts  = [bottom_face_pts[0], bottom_face_pts[1], top_face_pts[1], top_face_pts[0]]
    left_face_pts   = [bottom_face_pts[0], bottom_face_pts[3], top_face_pts[3], top_face_pts[0]]
    right_face_pts  = [bottom_face_pts[1], bottom_face_pts[2], top_face_pts[2], top_face_pts[1]]
    back_face_pts   = [bottom_face_pts[2], bottom_face_pts[3], top_face_pts[3], top_face_pts[2]]

    dict = "skpdesk_face_atts"
    key = "location"
    bottom_face = model.entities.add_face(bottom_face_pts)
    bottom_face.set_attribute(dict, key, 'bottom')
    top_face    = model.entities.add_face(top_face_pts)
    top_face.set_attribute(dict, key, 'top')
    front_face  = model.entities.add_face(front_face_pts)
    front_face.set_attribute(dict, key, 'front')
    left_face   = model.entities.add_face(left_face_pts)
    left_face.set_attribute(dict, key, 'left')
    right_face  = model.entities.add_face(right_face_pts)
    right_face.set_attribute(dict, key, 'right')
    back_face   = model.entities.add_face(back_face_pts)
    back_face.set_attribute(dict, key, 'back')

    post_op_ents = model.entities.to_a

    new_ents = post_op_ents - pre_op_ents
    new_group = model.entities.add_group(new_ents)
    new_comp = new_group.to_component
    defn =  new_comp.definition
    model.entities.erase_entities(new_comp)

    return defn
  end

  def add_wall_comp width, height, depth, start_point, end_point
    puts "add_wall_comp : #{width} #{height} #{depth}"
    cuboid_defn = create_cuboid_defn width, height, depth
    wall_inst = Sketchup.active_model.entities.add_instance cuboid_defn, start_point

    extra = 0
    #Rotate instance
    trans_vector = start_point.vector_to(end_point)
    if trans_vector.y < 0
      trans_vector.reverse!
      extra = Math::PI
    end
    angle 	= extra + X_AXIS.angle_between(trans_vector)
    wall_inst.transform!(Geom::Transformation.rotation(start_point, Z_AXIS, angle))
    #wall_inst.material= Sketchup::Color.names
    return wall_inst
  end
end

#
# p_h = {
#   :room_name => "Room1",
#   :room_type => "Kitchen"
# }
# $room_obj = RoomModel.new(p_h)
# puts $room_obj.inspect