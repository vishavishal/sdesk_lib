module TreeHelper
  extend self

  def get_bound_faces
    room_faces = CivilHelper::get_floor_faces
    bounds_faces = []
    room_faces.each do |face|
      room_name = face.get_attribute(:sdk_atts, 'room_name')
      floor_group = CivilHelper::get_floor_group(room_name)

      pts = face.vertices.map{|x| floor_group.transformation * x.position.offset(Z_AXIS, -20000.mm)}
      temp_face = Sketchup.active_model.entities.add_face(pts)
      temp_face.set_attribute(:sdk_atts, 'room_name', room_name)
      temp_face.set_attribute(:sdk_atts, 'garbage', true)
      bounds_faces << temp_face
    end
    return bounds_faces
  end

  def get_bounded_face bound_faces, pt
    bound_faces.each do |bface|
      plane_pt = pt.project_to_plane(bface.plane)
      resp = bface.classify_point(plane_pt)
      if resp.between?(1,8)
        return bface
      end
    end
    return nil
  end

  def bound_update ent, bound_faces=[]
    bound_faces = get_bound_faces if bound_faces.empty?
    center_pt = ent.bounds.center
    resp = get_bounded_face bound_faces, center_pt
    if resp && resp.is_a?(Sketchup::Face)
      room_name = resp.get_attribute(:sdk_atts, 'room_name')
      ent.set_attribute(:sdk_atts, 'room_name', room_name)
    else
      ent.set_attribute(:sdk_atts, 'room_name', '')
    end
  end

  def bound_update_ents ents=[]
    begin
      bound_faces = get_bound_faces
      ents.each do |ent|
        bound_update ent, bound_faces
      end
    rescue e
      puts "SKPdesk Error : #{e}"
    ensure
      puts "Ensuring....."
      SDESK::empty_garbage
    end
  end

end


