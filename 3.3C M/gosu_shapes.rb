require 'rubygems'
require 'gosu'
require './circle'

##################################################
# # The screen has layers: Background, middle, top
# module ZOrder
#   BACKGROUND, MIDDLE, TOP = *0..2
# end

# class DemoWindow < Gosu::Window
#   def initialize
#     super(640, 400, false)
#   end

#   def draw
#     # see www.rubydoc.info/github/gosu/gosu/Gosu/Color for colours
#     # white background
#     draw_quad(0, 0, 0xff_ffffff, 640, 0, 0xff_ffffff, 0, 400, 0xff_ffffff, 640, 400, 0xff_ffffff, ZOrder::BACKGROUND)
#     draw_quad(5, 10, Gosu::Color::BLUE, 200, 10, Gosu::Color::AQUA, 5, 150, Gosu::Color::FUCHSIA, 200, 150, Gosu::Color::RED, ZOrder::MIDDLE)
#     draw_triangle(50, 50, Gosu::Color::GREEN, 100, 50, Gosu::Color::GREEN, 50, 100, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
#     draw_line(200, 200, Gosu::Color::BLACK, 350, 350, Gosu::Color::BLACK, ZOrder::TOP, mode=:default)
#     # draw_rect works a bit differently:
#     Gosu.draw_rect(300, 200, 100, 50, Gosu::Color::BLACK, ZOrder::TOP, mode=:default)

#     # Circle parameter - Radius
#     img2 = Gosu::Image.new(Circle.new(50))
#     # Image draw parameters - x, y, z, horizontal scale (use for ovals), vertical scale (use for ovals), colour
#     # Colour - use Gosu::Image::{Colour name} or .rgb({red},{green},{blue}) or .rgba({alpha}{red},{green},{blue},)
#     # Note - alpha is used for transparency.
#     # drawn as an elipse (0.5 width:)
#     img2.draw(200, 200, ZOrder::TOP, 0.5, 1.0, Gosu::Color::BLUE)
#     # drawn as a red circle:
#     img2.draw(300, 50, ZOrder::TOP, 1.0, 1.0, 0xff_ff0000)
#     # drawn as a red circle with transparency:
#     img2.draw(300, 250, ZOrder::TOP, 1.0, 1.0, 0x64_ff0000)

#   end
# end

# DemoWindow.new.show
#####################

# Because the description said that I can draw my own
# unique picture, so I add mountains, blue sky, sun, 
# door and window. I also use custom colors.

# Custom Colors
module CColor
  SKY_BLUE = 0xff_a7ecff
  YELLOW = 0xff_fff200
  GREEN = 0xff_22b14c
  LIGHT_GREEN = 0xff_34e32a
  LIME = 0xff_b5e61d
  DARK_LIME = 0xff_8cb316
  GRAY = 0xff_b0b0b0
  RED = 0xff_ed1c24
  PURPLE = 0xff_a349a4
end

module ZOrder
  BACKGROUND, LOWER_MIDDLE, UPPER_MIDDLE, TOP = *0..3
end

class MyWindow < Gosu::Window

  def initialize()
    super(800, 600, false)
    self.caption = "House on the Hill"
  end

  def draw()
    # draw background
    draw_rect(0, 0, 800, 600, CColor::SKY_BLUE, ZOrder::BACKGROUND)
    # draw sun
    sun = Gosu::Image.new(Circle.new(86))
    sun.draw(309, 95, ZOrder::LOWER_MIDDLE, 1, 1, CColor::YELLOW)
    # draw mountains
    draw_triangle(-50, 600, CColor::GREEN, 246, 20, CColor::LIGHT_GREEN, 541, 600, CColor::GREEN, ZOrder::LOWER_MIDDLE)
    draw_triangle(352, 600, CColor::DARK_LIME, 601, 57, CColor::LIME, 850, 600, CColor::DARK_LIME, ZOrder::LOWER_MIDDLE)
    # draw ground
    oval = Gosu::Image.new(Circle.new(400))
    oval.draw(0, 441, ZOrder::LOWER_MIDDLE, 1, 0.4, CColor::LIGHT_GREEN)
    # draw house
    draw_triangle(297, 377, CColor::RED, 441, 310, CColor::RED, 585, 377, CColor::RED, ZOrder::UPPER_MIDDLE)
    draw_rect(323, 377, 236, 118, CColor::GRAY, ZOrder::UPPER_MIDDLE)
    draw_rect(486, 395, 57, 101, CColor::PURPLE, ZOrder::TOP)
    draw_rect(344, 395, 122, 82, CColor::YELLOW, ZOrder::TOP)
  end
end

MyWindow.new.show
