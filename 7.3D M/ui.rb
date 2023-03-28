require './modules'
require './circle'

class NextButton
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y, w, h)
    @w = w
    @h = h
    @x = x
    @y = y
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::INACTIVE
      color = UI_INACTIVE_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State::CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_triangle(@x+@w, @y+(@h/2).to_i, color, @x, @y, color, @x, @y+@h, color, ZOrder::UI)
  end

end

class BackButton
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y, w, h)
    @w = w
    @h = h
    @x = x
    @y = y
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::INACTIVE
      color = UI_INACTIVE_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State::CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_triangle(@x, @y+(@h/2).to_i, color, @x+@w, @y, color, @x+@w, @y+@h, color, ZOrder::UI)
  end

end

class PlayButton
  attr_accessor :x, :y, :w, :h, :state, :is_play

  def initialize(x, y)
    @x = x
    @y = y
    @w = @h = 49
    @state = State::NONE
    @is_play = false
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::INACTIVE
      color = UI_INACTIVE_COLOR
    when State::HOVERED
      color = 0xFF_8A94A9
    when State::CLICKED
      color = 0xFF_3C4A67
    end
    draw_circle(@x, @y, 24, color, ZOrder::UI)

    if not @is_play
      Gosu.draw_triangle(@x+16, @y+12, CONTROL_BAR_COLOR, @x+16, @y+37, CONTROL_BAR_COLOR, @x+34, @y+24, CONTROL_BAR_COLOR, ZOrder::UI)
    else
      Gosu.draw_rect(@x+13, @y+12, 8, 25, CONTROL_BAR_COLOR, ZOrder::UI)
      Gosu.draw_rect(@x+28, @y+12, 8, 25, CONTROL_BAR_COLOR, ZOrder::UI)
    end
  end
end

class VolUpButton
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y)
    @x = x
    @y = y
    @w = @h = 30
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = 0xFF_8A94A9
    when State::CLICKED
      color = 0xFF_3C4A67
    end

    Gosu.draw_rect(@x+11, @y, 8, 30, color, ZOrder::UI)
    Gosu.draw_rect(@x, @y+11, 30, 8, color, ZOrder::UI)
  end
end

class VolDownButton
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y)
    @x = x
    @y = y
    @w = 30
    @h = 8
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State::CLICKED
      color = UI_CLICKED_COLOR
    end

    Gosu.draw_rect(@x, @y, 30, 8, color, ZOrder::UI)
  end
end

class Volume
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def draw(vol)
    vol = (vol * 10).to_i
    for i in 1..10
      if i <= vol
        color = UI_COLOR
      else
        color = UI_CLICKED_COLOR
      end
      Gosu.draw_rect(x + (i-1)*10, y + 40-i*4, 5, i*4, color, ZOrder::UI)
    end
  end
end
