require 'gosu'

# Check if mouse is hovered over a button and change its appearance
# @param button: the button to check
# @param mouse_x: mouse's x ordinate
# @param mouse_y: mouse's y ordinate
def mouse_in?(button, mouse_x, mouse_y)
  if (button.x - button.w/2 <= mouse_x and mouse_x <= button.x + button.w/2) and (button.y - button.h/2 <= mouse_y and mouse_y <= button.y + button.h/2)
    button.img = button.pressed
    return true
  else
    button.img = button.normal
    return false
  end
end

# Check if a button is clicked
# @param button: the button to check
# @param mouse_x: mouse's x ordinate
# @param mouse_y: mouse's y ordinate
def button_clicked?(button, mouse_x, mouse_y)
  if mouse_in?(button, mouse_x, mouse_y) and Gosu.button_down?(Gosu::MS_LEFT)
    return true
  else
    return false
  end
end

# Draw a button
# @param button: the button to draw
def button_draw(button)
  button.img.draw_rot(button.x, button.y, ZOrder::UI)
end

class Button
  attr_accessor :x, :y, :w, :h, :img, :normal, :pressed
  # Generate a new button
  # @param x: x ordinate of the button
  # @param y: y ordinate of the button
  # @param w: width of the button
  # @param h: height of the button
  # @param img_normal: image of normal button
  # @param img_pressed: image of pressed button
  def initialize(x, y, w, h, img_normal, img_pressed)
    @x = x
    @y = y
    @w = w
    @h = h
    @normal = img_normal
    @pressed = img_pressed
    @img = @normal
  end
end