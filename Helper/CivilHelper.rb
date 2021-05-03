module CivilHelper
  extend self

  def check_clockwise_edge edge, face
    edge, face = face, edge if edge.is_a?(Sketchup::Face)
    conn_vector = GeomHelper::get_perpendicular_vector edge, face
    return false unless conn_vector
    dot_vector	= conn_vector * edge.line[1]
    clockwise_flag = dot_vector.z > 0 ? 'clockwise' : 'anticlockwise'
    return clockwise_flag
  end

  def get_cw_edge_list face
    edges = face.outer_loop.edges
    cw1 = check_clockwise_edge edges[0], face
    cw2 = check_clockwise_edge edges[1], face
    if cw1 == 'clockwise' && edges[1].vertices.include?(edges[0].end)
      return edges
    elsif cw1 == 'anticlockwise' && edges[1].vertices.include?(edges[0].start )
      return edges
    end
    return edges.reverse
  end

  def find_views face_edges
    face_views = []; view_arr= []
    previous_edge = face_edges.first
    face_edges.each{|f_edge|
      if f_edge.line[1].parallel?(previous_edge.line[1])
        #seln.add(f_edge)
        view_arr << f_edge
      else
        #seln.add(f_edge)
        face_views << view_arr
        view_arr = [f_edge]
      end
      previous_edge = f_edge
    }
    if face_views.first[0].line[1].parallel?(previous_edge.line[1])
      #puts "Last and first same"
      view_arr << face_views.first[0]
      face_views.delete(face_views.first)
    end
    #puts "[previous_edge] : #{face_views.first} #{[previous_edge]}"
    face_views << view_arr
    #puts "face_views res : "
    pp face_views
    #puts "===================="
    face_views
  end

  def find_face_corner cw_edges
    (0..cw_edges.length-1).each{|index|
      if cw_edges[0].line[1].parallel?(cw_edges[1].line[1])
        cw_edges.rotate!
      else
        cw_edges.rotate!
        break
      end
    }
    cw_edges
  end

  def get_room_names
    groups = Sketchup.active_model.entities.grep(Sketchup::Group)
    return groups.select{|ent| ent.respond_to?(:face_id) && ent.skp_class == 'FloorModel'}.map(&:room_name)
  end

  def get_floor_group room_name
    groups = Sketchup.active_model.entities.grep(Sketchup::Group)
    return groups.select{|ent| ent.respond_to?(:face_id) && ent.skp_class == 'FloorModel' && ent.room_name == room_name}[0]
  end

  def get_floor_faces
    room_names = get_room_names
    room_names.map{|name| get_floor_group name}.map{|gp| gp.entities.grep(Sketchup::Face)}.flatten!
  end

  def get_room_face_details face
    details_h = {}
    face.outer_loop.edges.each do |edge|
      edge_type = edge.get_attribute('sdk_atts', 'floor_edge_type')
      case edge_type
      when 'Door'
        details_h['door'] = 1 unless details_h['door']
        details_h['door'] += 1
      when 'Window'
        details_h['window'] = 1 unless details_h['window']
        details_h['window'] += 1
      when 'Split'
        details_h['split'] = 1 unless details_h['split']
        details_h['split'] += 1
      else
        details_h['wall/unmarked'] = 1 unless details_h['wall/unmarked']
        details_h['wall/unmarked'] += 1
      end
    end
    details_h['area'] = face.area.to_s + "mm2"
    return details_h
  end

  def get_wall_item_dialog ent
    dialog_h = {
      :dialog_title=>"SKPDESK Wall item",
      :preferences_key=>"com.sample.plugin",
      :scrollable=>true,
      :resizable=>true,
      :style=>UI::HtmlDialog::STYLE_DIALOG,

      #Size values
      :min_width => 50,
      :min_height => 50,
      :max_width =>1000,
      :max_height => 1000
    }
    wallitem_dialog = UI::HtmlDialog.new(dialog_h)
    dialog_file_path = File.join(SDESK_ROOT_PATH, 'UI/html', 'wall_dialog.html')

    wallitem_dialog.set_file(dialog_file_path)
    wallitem_dialog.set_size(450, 600)
    wallitem_dialog.set_position(100,100)
    wallitem_dialog.show

    wallitem_dialog.add_action_callback("createWallItem") {|dlg, params|
      input_h = JSON.parse(params)
      puts "createWallItem : #{input_h}"
      wall_comp = Sketchup.active_model.selection[0]
      if input_h['itemType'] == 'Door'
        door_height = input_h["doorHeight"].to_i.mm
        door_length = input_h["doorLength"].to_i.mm
        door_offset = input_h["doorOffset"].to_i.mm
        CivilModel::add_door_to_wall wall_comp, door_height, door_length, door_offset
      elsif input_h['itemType'] == "Window"
        window_height = input_h["windowHeight"].to_i.mm
        window_length = input_h["windowLength"].to_i.mm
        vertical_offset = input_h["windowVerOffset"].to_i.mm
        window_offset = input_h["windowHorOffset"].to_i.mm
        CivilModel::add_window_to_wall wall_comp, window_height, window_length, window_offset, vertical_offset
      end
    }
  end
end