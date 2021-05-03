module CompController
  extend self
  @vert_finish_panel_defn = nil
  @vert_edge_panel_defn = nil
  @horizontal_panel_defn = nil
  def add_external_panels comp_defn, ext_param_h
    puts "add_external_panels : #{ext_param_h}"
    directions = ['left', 'right', 'top', 'bottom', 'back']

    model = Sketchup.active_model
    entities = model.entities
    directions.each {|dir_name|
      panel_name  = dir_name + 'Panel'
      panel_attr  = ext_param_h[panel_name]

      puts "dir_name : #{dir_name} : #{panel_name}"
      if ['left', 'right'].include?(dir_name)
        panel_bbox  = @vert_edge_panel_defn.bounds
        x_factor    = panel_attr[:xlen].mm / panel_bbox.width
        y_factor    = panel_attr[:ylen].mm / panel_bbox.height
        z_factor    = panel_attr[:zlen].mm / panel_bbox.depth

        #puts "Scaling Left : #{x_factor} : #{y_factor} : #{z_factor} : #{panel_attr} : #{@vert_edge_panel_defn}"
        pt = [panel_attr[:xpos].to_i.mm, panel_attr[:ypos].to_i.mm, panel_attr[:zpos].to_i.mm]
        #puts pt
        panel_comp = comp_defn.entities.add_instance(@vert_edge_panel_defn, ORIGIN)
        panel_comp.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))
        panel_comp.transform!(Geom::Transformation.new(pt))
      elsif ['top', 'bottom'].include?(dir_name)
        panel_bbox  = @horizontal_panel_defn.bounds
        x_factor    = panel_attr[:xlen].mm / panel_bbox.width
        y_factor    = panel_attr[:ylen].mm / panel_bbox.height
        z_factor    = panel_attr[:zlen].to_i.mm / panel_bbox.depth

        #puts "Scaling Left : #{@horizontal_panel_defn} : #{panel_bbox.depth} : #{x_factor} : #{y_factor} : #{z_factor} : #{panel_attr} : #{@horizontal_panel_defn}"
        pt = [panel_attr[:xpos].to_i.mm, panel_attr[:ypos].to_i.mm, panel_attr[:zpos].to_i.mm]
        #puts pt
        panel_comp = comp_defn.entities.add_instance(@horizontal_panel_defn, ORIGIN)
        panel_comp.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))
        panel_comp.transform!(Geom::Transformation.new(pt))
      elsif ['back'].include?(dir_name)
        panel_bbox  = @vert_finish_panel_defn.bounds
        x_factor    = panel_attr[:xlen].mm / panel_bbox.width
        y_factor    = panel_attr[:ylen].mm / panel_bbox.height
        z_factor    = panel_attr[:zlen].mm / panel_bbox.depth

        #puts "Scaling Left : #{x_factor} : #{y_factor} : #{z_factor} : #{panel_attr} : #{@horizontal_panel_defn}"
        pt = [panel_attr[:xpos].to_i.mm, panel_attr[:ypos].to_i.mm, panel_attr[:zpos].to_i.mm]
        #puts pt
        panel_comp = comp_defn.entities.add_instance(@vert_finish_panel_defn, ORIGIN)
        panel_comp.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))
        panel_comp.transform!(Geom::Transformation.new(pt))
      end
      panel_comp.set_attribute('skpdesk_panel_atts', 'panel_name', dir_name+'_ext_panel')
    }
  end

  def create_comp_defn input_h={}
    puts "create_comp : #{input_h}"
    puts "Path : #{PATH} " if defined?(PATH)
    finish_panel_file_name = File.join(SDESK_ROOT_PATH,'ext_assets', 'vertical_finish.skp')
    unless File.exists?(finish_panel_file_name)
      puts "Vertical finish Panel file not found"
      return nil
    end
    edge_panel_file_name = File.join(SDESK_ROOT_PATH, 'ext_assets', 'vertical_edge.skp')
    unless File.exists?(edge_panel_file_name)
      puts "Vertical Edge Panel file not found"
      return nil
    end
    horizontal_panel_file_name = File.join(SDESK_ROOT_PATH, 'ext_assets', 'horizontal_panel.skp')
    unless File.exists?(horizontal_panel_file_name)
      puts "Horizontal Panel file not found"
      return nil
    end

    @vert_finish_panel_defn = Sketchup.active_model.definitions.load(finish_panel_file_name)
    @vert_edge_panel_defn = Sketchup.active_model.definitions.load(edge_panel_file_name)
    @horizontal_panel_defn = Sketchup.active_model.definitions.load(horizontal_panel_file_name)

    model = Sketchup.active_model
    entities = model.entities

    #Add external panels
    ext_panels = input_h[:externalPanels]
    puts "comp_depth : #{input_h}"
    bottom_panel_attr = ext_panels['bottomPanel']

    temp_defn = Sketchup.active_model.definitions.add()

    comp_depth = input_h[:comp_depth]
    panel_thickness = input_h[:thickness]
    comp_width = input_h[:comp_width]
    shelves_front_offset = input_h[:shelf_front_offset]

    add_external_panels temp_defn, ext_panels

    glue_flag = 3
    if glue_flag == SnapTo_Horizontal
      temp_defn.behavior.is2d=true
      temp_defn.behavior.snapto=SnapTo_Horizontal
      return temp_defn
    elsif glue_flag == SnapTo_Vertical
      comp_inst = Sketchup.active_model.entities.add_instance temp_defn, ORIGIN

      comp_inst.move!(Geom::Transformation.new([0, -comp_depth, 0]))
      comp_inst.transform!(Geom::Transformation.rotation(ORIGIN, X_AXIS, -90.degrees))

      comp_group = Sketchup.active_model.entities.add_group(comp_inst)

      comp = comp_group.to_component
      glue_defn = comp.definition

      glue_defn.behavior.is2d=true
      glue_defn.behavior.snapto=SnapTo_Vertical

      return glue_defn
    end


    #total_internal_vertical_space = comp_depth - (ext_panels['bottomPanel']['zpos'].to_i.mm+panel_thickness) - (comp_depth - ext_panels['topPanel']['zpos'].to_i.mm)
    #total_internal_horizontal_space = comp_width - ext_panels['leftPanel']['xlen'].to_i.mm - ext_panels['rightPanel']['xlen'].to_i.mm
    #total_internal_storage_space = ext_panels["backPanel"]["ypos"].to_i.mm - shelves_front_offset

    #
    # equiHorizShelved = input_h["equiHorizShelved"].to_i
    #
    # puts "total_internal_vertical_space : #{total_internal_vertical_space*25.4}"
    # if equiHorizShelved > 0
    #   available_vert_space = total_internal_vertical_space - (equiHorizShelved * panel_thickness)
    #   shelf_distance = available_vert_space / (equiHorizShelved+1)
    #
    #   available_hor_space = total_internal_horizontal_space
    #   available_storage_space = total_internal_storage_space
    #
    #   bottom_panel = temp_defn.entities.grep(Sketchup::ComponentInstance).select{|ent| ent.name == 'bottom_ext_panel'}
    #
    #   panel_bbox  = @horizontal_panel_defn.bounds
    #   x_factor    = total_internal_horizontal_space / panel_bbox.width
    #   y_factor    = total_internal_storage_space / panel_bbox.height
    #   z_factor    = panel_thickness / panel_bbox.depth
    #
    #   (1..equiHorizShelved).each {|index|
    #     #puts "Scaling equi #{index} : #{x_factor} : #{y_factor} : #{z_factor} : #{@horizontal_panel_defn}"
    #     pt = [panel_thickness, input_h["shelvesFrontOffset"].to_i.mm,
    #           ext_panels['bottomPanel']['zpos'].to_i.mm + index*(shelf_distance+panel_thickness)]
    #     #puts pt
    #     panel_comp = temp_defn.entities.add_instance(@horizontal_panel_defn, ORIGIN)
    #     panel_comp.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))
    #     panel_comp.transform!(Geom::Transformation.new(pt))
    #   }
    #
    # end
    #
    # if centerVerticalSplit_h['left'].to_i > 0 || centerVerticalSplit_h['right'].to_i > 0
    #   x_point = (comp_width-panel_thickness)/2 #Adding panel thickness for keeping the panel at offset of panel_thickness
    #   y_point = shelves_front_offset
    #   z_point = ext_panels['bottomPanel']['zpos'].to_i.mm + panel_thickness
    #   x_factor = panel_thickness / @vert_edge_panel_defn.bounds.width
    #   y_factor = total_internal_storage_space / @vert_edge_panel_defn.bounds.height
    #   z_factor = (ext_panels['topPanel']['zpos'].to_i.mm - (ext_panels['bottomPanel']['zpos'].to_i.mm+panel_thickness))/@vert_edge_panel_defn.bounds.depth
    #
    #   pt = [x_point, y_point, z_point]
    #   panel_comp = temp_defn.entities.add_instance(@vert_edge_panel_defn, ORIGIN)
    #   panel_comp.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))
    #   panel_comp.transform!(Geom::Transformation.new(pt))
    #
    #   split_x_space = (total_internal_horizontal_space-panel_thickness)/2
    #
    #   left_count = centerVerticalSplit_h["left"].to_i
    #   if left_count > 0
    #     available_vert_space = total_internal_vertical_space
    #     shelf_distance = available_vert_space / (left_count+1)
    #     panel_bbox  = @horizontal_panel_defn.bounds
    #     x_factor    = split_x_space / panel_bbox.width
    #     y_factor    = total_internal_storage_space / panel_bbox.height
    #     z_factor    = panel_thickness / panel_bbox.depth
    #
    #     (1..left_count).each{|index|
    #       pt = [panel_thickness, input_h["shelvesFrontOffset"].to_i.mm,
    #             ext_panels['bottomPanel']['zpos'].to_i.mm + index*(shelf_distance+panel_thickness)]
    #       panel_comp = temp_defn.entities.add_instance(@horizontal_panel_defn, ORIGIN)
    #       panel_comp.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))
    #       panel_comp.transform!(Geom::Transformation.new(pt))
    #     }
    #   end
    #   right_count = centerVerticalSplit_h["right"].to_i
    #   if right_count > 0
    #     available_vert_space = total_internal_vertical_space
    #     shelf_distance = available_vert_space / (right_count+1)
    #
    #     panel_bbox  = @horizontal_panel_defn.bounds
    #     x_factor    = split_x_space / panel_bbox.width
    #     y_factor    = total_internal_storage_space / panel_bbox.height
    #     z_factor    = panel_thickness / panel_bbox.depth
    #
    #     (1..right_count).each{|index|
    #       pt = [split_x_space + 2*panel_thickness, input_h["shelvesFrontOffset"].to_i.mm,
    #             ext_panels['bottomPanel']['zpos'].to_i.mm + index*(shelf_distance+panel_thickness)]
    #       panel_comp = temp_defn.entities.add_instance(@horizontal_panel_defn, ORIGIN)
    #       panel_comp.transform!(Geom::Transformation.scaling(x_factor, y_factor, z_factor))
    #       panel_comp.transform!(Geom::Transformation.new(pt))
    #     }
    #   end
    #
    #   @vert_edge_panel_defn
    # end

    temp_defn.behavior.is2d=true
    temp_defn.behavior.snapto=2
    temp_defn
  end

  #Stub : CompControllerStub::get_comp_params
  def create_comp param_h
    parsed_inputs = parse_inputs(param_h)
    comp_defn = create_comp_defn parsed_inputs
    comp_defn.set_attribute(:sdk_atts, 'libcomp', true)
    parsed_inputs.each_pair do |key, value|
      puts "Key : #{key} : #{value}"
      case value
      when Hash
        value = value.to_json
      end
      comp_defn.set_attribute(:sdk_atts, key, value)
    end
    comp_defn
  end

  def parse_inputs inputs

    thickness = inputs[:panelThickness].to_i #|| 18.mm
    comp_width = inputs[:compWidth].to_i
    comp_height = inputs[:compHeight].to_i
    comp_depth = inputs[:compDepth].to_i
    int_skirting = inputs[:internalSkirting].to_i
    int_loft_skirting = inputs[:internalLoftSkirting].to_i
    shelf_front_offset = inputs[:shelvesFrontOffset].to_i
    back_panel_posn = inputs[:backPanelPosition].to_i

    result_h = {
      :thickness => thickness,
      :comp_width => comp_width,
      :comp_height => comp_height,
      :comp_depth => comp_depth,
      :int_skirting => int_skirting,
      :int_loft_skirting => int_loft_skirting,
      :shelf_front_offset => shelf_front_offset,
      :back_panel_posn => back_panel_posn
    }

    external_panels = {}
    ["left", "right", "top", "bottom", "back"].each{|side_name|
      panel_name = side_name+"Panel"
      ylen  = comp_height
      ypos  = 0
      case side_name
      when "left", "right"
        xlen  = thickness
        zlen  = comp_depth
        zpos  = 0
        xpos  = side_name == "left" ? 0 : comp_width-thickness
      when "top", "bottom"
        xlen  = comp_width-2*thickness
        xpos  = thickness
        zlen  = thickness
        zpos  = side_name == "bottom" ? 0+int_skirting : comp_depth-thickness-int_loft_skirting
      when "back"
        xlen  = comp_width-2*thickness
        xpos  = thickness
        zlen  = comp_depth-2*thickness-int_loft_skirting-int_skirting
        zpos  = thickness+int_skirting
        ylen  = thickness; ypos  = comp_height - back_panel_posn
      end
      external_panels[panel_name]= {
        "xlen": xlen, "ylen": ylen, "zlen": zlen,
        "xpos": xpos, "ypos": ypos, "zpos": zpos
      }
    }
    result_h[:externalPanels] = external_panels
    return result_h
  end

  def convert_inputs_to_json inputs
    puts "convert_inputs_to_json : #{inputs}"
    output_h = {}

    thickness = inputs[:panelThickness].to_i.mm #|| 18.mm
    comp_width = inputs[:compWidth].to_i.mm
    comp_height = inputs[:compHeight].to_i.mm
    comp_depth = inputs[:compDepth].to_i.mm
    int_skirting = inputs[:internalSkirting].to_i.mm
    int_loft_skirting = inputs[:internalLoftSkirting].to_i.mm
    shelf_front_offset = inputs[:shelvesFrontOffset].to_i.mm
    back_panel_posn = inputs[:backPanelPosition].to_i.mm

    # external_panels = {}
    # inputs["externalPanels"].each{|side_name|
    #   panel_name = side_name+"Panel"
    #   ylen  = comp_height
    #   ypos  = 0
    #   case side_name
    #   when "left", "right"
    #     xlen  = thickness
    #     zlen  = comp_depth
    #     zpos  = 0
    #     xpos  = side_name == "left" ? 0 : comp_width-thickness
    #   when "top", "bottom"
    #     xlen  = comp_width-2*thickness
    #     xpos  = thickness
    #     zlen  = thickness
    #     zpos  = side_name == "bottom" ? 0+int_skirting : comp_depth-thickness-int_loft_skirting
    #   when "back"
    #     xlen  = comp_width-2*thickness
    #     xpos  = thickness
    #     zlen  = comp_depth-2*thickness-int_loft_skirting-int_skirting
    #     zpos  = thickness+int_skirting
    #     ylen  = thickness; ypos  = comp_height - back_panel_posn
    #   end
    #   external_panels[panel_name]= {
    #     "xlen": xlen.to_mm, "ylen": ylen.to_mm, "zlen": zlen.to_mm,
    #     "xpos": xpos.to_mm, "ypos": ypos.to_mm, "zpos": zpos.to_mm
    #   }
    # }
    # inputs["externalPanels"] = external_panels
    #
    # centerSplit_h = {}
    # center_split_a = inputs["centerVerticalSplit"]
    # center_split_h = {
    #   "left": center_split_a[0].to_i,
    #   "right": center_split_a[1].to_i
    # }
    # inputs["centerVerticalSplit"] = center_split_h

    json_file_path = File.join(SDESK_ROOT_PATH, "temp_scripts/comp_details.json")
    File.open(json_file_path,"w") do |f|
      f.write(JSON.pretty_generate(inputs))
    end

    inputs
  end

end

module CompControllerStub
  extend self
  def get_comp_params
    #Use for create_comp function
    sample_h = {:panelThickness=>"18",
            :compWidth=>"1600",
            :compHeight=>"400",
            :compDepth=>"1200",
            :internalSkirting=>"100",
            :internalLoftSkirting=>"50",
            :shelvesFrontOffset=>"1200",
            :backPanelPosition=>"54"
          }
    return sample_h
  end
end