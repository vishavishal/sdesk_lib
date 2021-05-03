module MaterialController
  extend self
  @all_faces = []
  def get_all_faces entity
    case entity
    when Sketchup::Face
      @all_faces << entity
    when Sketchup::Group
      entity.make_unique
      entity.entities.each{|ent| get_all_faces ent}
    when Sketchup::ComponentInstance
      entity.make_unique
      entity.definition.entities.each{|ent| get_all_faces ent}
    end 
  end

  def all_faces;@all_faces;end
  
  def apply_material input_h
    ent_selected = Sketchup.active_model.selection[0]
    
    get_all_faces ent_selected
    
    mat_name = input_h[:imageSelected].split('.')[0]
    puts "mat_name : #{mat_name}"
    material_path = File.join(SDESK_ROOT_PATH, 'UI/assets/images/materials', input_h[:imageSelected])

    face_material = Sketchup.active_model.materials[mat_name]
    face_material = Sketchup.active_model.materials.add(mat_name) unless face_material
    face_material.texture = material_path
    
    @all_faces.each{|ent_face|
      ent_face.material = face_material
      ent_face.back_material = face_material
    }
  end
end

module MaterialControllerStub
  extend self
end