model = Sketchup.active_model
entities = model.entities
faces = entities.grep(Sketchup::Face)
texturable_entities = entities.select{ |ent|
  (ent.is_a?(Sketchup::ComponentInstance) ||
    ent.is_a?(Sketchup::Group) || ent.is_a?(Sketchup::Image)) }
my_texture_writer = Sketchup.create_texture_writer

face = fsel

uv_helper = face.get_UVHelper true, true, my_texture_writer
face.outer_loop.vertices.each do |vert|
  uvq = uv_helper.get_back_UVQ(vert.position)
  puts "u=" + uvq.x.to_s + " v=" + uvq.y.to_s
end


uv_helper = face.get_UVHelper true, true, my_texture_writer
face.outer_loop.vertices.each do |vert|
  uvq = uv_helper.get_front_UVQ(vert.position)
  puts "u=" + uvq.x.to_s + " v=" + uvq.y.to_s
end


plane_pt = comp.bounds.center.project_to_plane(face.plane)
resp = face.classify_point(plane_pt)
case resp
when 0
  puts "Sketchup::Face::PointUnknown"
when 1
  puts "Sketchup::Face::PointInside"
when 2
end