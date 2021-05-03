module UIController
  extend self
  include SDESK
  @@skpdesk_main_dialog = nil
  def start_skpdesk_ui
    puts "start_skpdesk_ui called"
    dialog_h = {
      :dialog_title=>"SKPDesk",
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
    skpdesk_dialog = get_skpdesk_dialog

    #If dialog not created or not visible...create new
    if skpdesk_dialog.nil? || !skpdesk_dialog.visible?
      skpdesk_dialog = UI::HtmlDialog.new(dialog_h)
      dialog_file_path = File.join(SDESK_ROOT_PATH, 'UI/html','skpdesk.html')

      skpdesk_dialog.set_file(dialog_file_path)
      skpdesk_dialog.set_size(450, 600)
      skpdesk_dialog.set_position(100,100)
      add_main_action_callbacks skpdesk_dialog

      @@skpdesk_main_dialog = skpdesk_dialog

      skpdesk_dialog.show
    end

  end

  def get_skpdesk_dialog
    @@skpdesk_main_dialog
  end

  def add_main_action_callbacks skpdesk_dialog

    #Add all the callback feature requests here
    skpdesk_dialog.add_action_callback("cbRubyFeature") { |dlg, params|
      puts "SKPDesK cbRubyFeature #{params}"
      split_str = params.split('#')
      cb_func_name = split_str[0]
      param_h = JSON.parse(split_str[1]) if split_str[1]
      SDESK::symbolize_keys_deep!(param_h)

      msg_resp = ""
      case cb_func_name.to_sym
      when :createProject
        msg_resp = ProjectHelper::create_project_in_current_model param_h
      when :selectFloorEdge
        msg_resp = CivilController::select_edges_for_floor param_h
      when :createSpace
        msg_resp = CivilController::create_space_from_face param_h
        #jscmd = "updateWall('"+10.to_s+"')"
        #@@skpdesk_main_dialog.execute_script(jscmd);
      when :selectRoomTool
        room_tool_inst = SdeskRoomTool.instance
        Sketchup.active_model.select_tool(room_tool_inst)
      when :deleteRoomEntities
        room_name = split_str[1]
        CivilHelper::delete_room_entities(room_name)
      when :getRoomList
        roomNames = BaseHelper::get_room_names
        puts "Hex room names : #{roomNames}"
        js_cmd    = "addRoomNames('"+roomNames.to_s+"')";
        ui_dialog = get_skpdesk_dialog
        ui_dialog.execute_script(js_cmd);
      when :createComponent
        #input_h = CompController::convert_inputs_to_json param_h
        comp_defn = CompController::create_comp param_h

        #puts "comp_defn : #{comp_defn} #{comp_defn.name}"
        #pt = [1000.mm, 1000.mm, 0]
        #comp_inst = Sketchup.active_model.entities.add_instance(comp_defn, pt)
        Sketchup.active_model.place_component comp_defn
        #Sketchup.active_model.entities.add_instance comp_defn, ORIGIN
      when :applyMaterial
        puts "Ruby applyMaterial"
        MaterialController::apply_material param_h
        puts "Material Applied successfully"
      end

      if msg_resp && !msg_resp.empty?
        js_str = msg_resp[0].to_s+"=="+msg_resp[1].to_s
        js_cmd = "ruby2UI('"+ js_str +"')"

        ui_dialog = get_skpdesk_dialog
        puts "Ruby Return msg : #{ui_dialog} : #{js_cmd}"

        #ui_dialog.execute_script(js_cmd);
      end
    }

    #Add all the model details callback request
    skpdesk_dialog.add_action_callback("cbRubyDetails") { |dlg, params|
      puts "SKPDesK cbRubyDetails #{params}"
      split_str = params.split('#')
      cb_func_name = split_str[0]
      param_h = JSON.parse(split_str[1]) if split_str[1]

      js_cmd = ""
      case cb_func_name.to_sym
      when :getProjectDetails
        project_details = ProjectHelper::get_project_details
        js_cmd = "setProjectDetails("+project_details.to_json+")"
      end

      unless js_cmd.empty?
        ui_dialog = get_skpdesk_dialog
        puts "Ruby Return msg : #{ui_dialog} : #{js_cmd}"
        ui_dialog.execute_script(js_cmd);
      end
    }

  end
end
