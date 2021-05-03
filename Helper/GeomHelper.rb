module GeomHelper
  extend self

  # Get the cross Product of the edge and normal of the face to get the perpendicular vector between the two
  # Check which direction of the vector falls inside the face.
  def get_perpendicular_vector edge, face
    return false if edge.nil? || !edge.is_a?(Sketchup::Edge)
    return false if face.nil? || !face.is_a?(Sketchup::Face)
    edge_vector = edge.line[1]
    perp_vector = edge_vector.cross face.normal

    offset_pt 	= edge.bounds.center.offset(perp_vector, 2.mm)
    res         = face.classify_point(offset_pt)
    return perp_vector if (res == Sketchup::Face::PointInside||res == Sketchup::Face::PointOnFace)
    return perp_vector.reverse
  end

end
