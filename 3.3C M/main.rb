require 'gosu'
require './circle'

def draw_rect(x1, y1, x2, y2, color, zOrder = 1)
  draw_quad(x1, y1, color, x2, y1, color, x1, y2, color, x2, y2, color, zOrder)
end

class MyWindow < Gosu::Window

  def initialize()
    super(800, 600, false)
    self.caption = "Gosu Picture"
  end

  def update()
  end

  def draw()
    draw_rect(0, 0, 800, 600, Gosu::Color::WHITE)
  end
end

MyWindow.new.show
