require './modules'

# Abstract class for game states
class GameState
  # Generate new state
  # @param window: the associated window
  def initialize(window)
    @window = window
    @intro = true
    @intro_ani_index = 255
    @outro = nil
    @outro_ani_index = 0
  end

  # Slowly show the screen
  def intro
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, Gosu::Color.new(@intro_ani_index, 0, 0, 0), ZOrder::OVERLAY)
    @intro_ani_index -= 10
    @intro = false if @intro_ani_index < 0
  end

  # Slowly black out the screen
  def outro
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, Gosu::Color.new(@outro_ani_index, 0, 0, 0), ZOrder::OVERLAY)
    @outro_ani_index += 10
    @outro = false if @outro_ani_index > 256
  end

  def enter
  end

  def leave
  end

  def draw
  end

  def update
  end
end