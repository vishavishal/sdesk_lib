# =====================================================================
# The main loader file for the SKPDESK Library.
#
#
# =====================================================================

SDESK_ROOT_PATH = File.join(File.dirname(__FILE__ )) unless defined?(SDESK_ROOT_PATH)
require 'json'
require 'pp' #Can remove during production

module SDESK_LOADER
  extend self
  @@config_data = {}
  @@settings_data = {}

  def load_json_file json_path
    unless File.exists?(json_path)
      return false
    end
    file_obj = File.open json_path
    json_data = JSON.load(file_obj)
  end

  #------ Load all ruby files -----------------------
  def get_file_load_list
    json_file_path = File.join(SDESK_ROOT_PATH, 'configs', 'file_list.json')
    json_data = load_json_file json_file_path
    return [] unless json_data

    flist_arr = []
    json_data.each_pair do |dir_name, file_h|
      file_h.each_pair do |fname, queue_id|
        flist_arr << [File.join(dir_name, fname+'.rb'), queue_id]
      end
    end
    flist_arr.sort_by!{|arr| arr.last}
    flist_arr.map(&:first)
  end

  def load_sdesk_files
    flist_arr = get_file_load_list
    return false if flist_arr.empty?
    flist_arr.each do |file_path|
      ruby_file_path = File.join(SDESK_ROOT_PATH, file_path)
      if File.exists?(ruby_file_path)
        Sketchup.load ruby_file_path
      else
        puts "SKPDESK Boot Files Loading error : #{ruby_file_path}"
        return false
      end
    end
  end

  def load_settings
    settings_file_path = File.join(SDESK_ROOT_PATH,'configs', 'settings.json')
    unless File.exists?(settings_file_path)
      sdesk_log_err "Error loading Settings file.File not found."
      return false
    end
    settings_file = File.open settings_file_path

    #Symbolize the hash from config json file
    data = JSON.load(settings_file)
    set_settings_data data
    SDESK::symbolize_keys_deep!(@@settings_data)

    return true
  end

  def load_config_data
    config_file_path = File.join(SDESK_ROOT_PATH, 'configs', 'skpdesk_config.json')
    data = load_json_file config_file_path
    @@config_data = data
  end

  def set_config_data idata; class_variable_set(:@@config_data, idata);end
  def set_settings_data idata; class_variable_set(:@@settings_data, idata);end

  def config_data
    @@config_data
  end

  class SKPDeskEntitiesObserver < Sketchup::EntitiesObserver
    def onElementAdded(entities, entity)
      if entity.is_a?(Sketchup::ComponentInstance) && !entity.deleted?
        puts "Component Instance Added"
        dict = nil
        if entity.definition.attribute_dictionaries
          dict = entity.definition.attribute_dictionaries['sdk_atts']
          if dict
            dict.each_pair{|k,v| entity.set_attribute(:sdk_atts, k, v)}
          end
        end
      end
    end #onElementAdded
  end

  skpdesk_ent_observer = SKPDeskEntitiesObserver.new
  Sketchup.active_model.entities.add_observer(skpdesk_ent_observer)

end

SDESK_LOADER.load_sdesk_files
MenuHelper::add_entity_menus

UIController.start_skpdesk_ui

DECORPOT_MENU = UI.menu('Plugins').add_item('SKPDesk'){
  UIController::start_skpdesk_ui
}