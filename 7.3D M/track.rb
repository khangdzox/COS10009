require './modules'

class Track
  attr_accessor :title, :location, :x, :y, :state

  def initialize(title, location)
    @title = title
    @location = location

    @font_normal = Gosu::Font.new(18)
    @font_playing = Gosu::Font.new(18, bold: true)

    @x = @y = 0

    @state = State::NONE
  end

  def draw
    if @state < State::SELECTED
      @font_normal.draw_text(@title, x, y, ZOrder::UI, 1, 1, 0xff_ffffff)
    else
      @font_playing.draw_text(@title, x, y, ZOrder::UI, 1, 1, 0xff_ffffff)
    end

    case @state
    when State::CLICKED, State::CLICKED + State::SELECTED
      draw_clicked
    when State::HOVERED, State::HOVERED + State::SELECTED
      draw_hovered
    when State::SELECTED
      draw_selected
    end
  end

  def draw_hovered
    Gosu.draw_rect(510, @y - 6, 280, 30, 0x33_000000, ZOrder::MID)
  end

  def draw_clicked
    Gosu.draw_rect(510, @y - 6, 280, 30, 0x4b_000000, ZOrder::MID)
  end

  def draw_selected
    Gosu.draw_rect(510, @y - 6, 280, 30, 0x66_00ddff, ZOrder::MID)
  end
end
