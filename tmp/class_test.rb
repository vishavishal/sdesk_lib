class Test
  attr_accessor :height, :width, :depth

  def initialize(p_h)
    set_model_params(p_h)
  end

  def set_model_params(p_h)
    @height = p_h[:height]
    @width = p_h[:width]
    @depth = p_h[:depth]
  end
end

class Test2 < Test
  attr_accessor :param1, :param2
  def initialize(p_h)
    super
  end

  def set_model_params(p_h)
    super
    @param1 = p_h[:param1]
  end
end

p_h = {:x=>325}
pt = Test.new(p_h)
puts pt.height

#puts Test.methods


p_h = {:height=>4578, :width=>21754, :param1=>"Same test Value"}
pt = Test2.new(p_h)

puts "Param #{pt.height} : #{pt.width} : #{pt.param1}"