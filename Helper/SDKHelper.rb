module SDESK
  extend self
  def symbolize_keys_deep!(h)
    h.keys.each do |k|
      ks    = k.to_sym
      h[ks] = h.delete k
      symbolize_keys_deep! h[ks] if h[ks].kind_of? Hash
    end
  end

  def empty_garbage
    model = Sketchup.active_model
    ents = model.entities
    garbage_ents = ents.select{|ent| ent.get_attribute(:sdk_atts, 'garbage')}
    garbage_ents.each do |ent|
      case ent
      when Sketchup::Face
        ents.erase_entities ent.edges
      end
    end
  end
end
