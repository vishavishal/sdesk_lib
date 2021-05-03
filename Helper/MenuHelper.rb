
module MenuHelper
  extend self
  def add_entity_menus
    UI.add_context_menu_handler do |menu|
      model = Sketchup.active_model
      selected_entity = model.selection[0]
      if selected_entity && model.selection.length==1
        sel_atts = selected_entity.attribute_dictionaries
        if sel_atts
          if sel_atts['sdk_atts']
            rbm = menu.add_submenu("Add SKPDesk item->")
            rbm.add_item("Door") {
              CivilHelper::get_wall_item_dialog selected_entity
            }
            rbm.add_item("Window") {
              CivilHelper::get_wall_item_dialog selected_entity
            }
          end
        end
      end
    end #UI.add context menu
  end
end