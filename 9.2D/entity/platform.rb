require './modules'

# Generate random standable platforms, including spike, boost, moveable and normal platforms
# @param last_x: The x ordinate of the highest platform
# @param limit: The horizontal distance limit between old and new platforms
def generate_random_standable_platform(last_x, limit)
  case rand(30)
  when 0..1
    # spawn 3 spike platforms and a normal platform
    [
      SpikePlatform.new(30 + (last_x + rand(limit*2+1) - limit) %340, -20, false),
      SpikePlatform.new(30 + rand(341), -60, rand(2)%2==0),
      SpikePlatform.new(30 + rand(341), -100, true),
      StaticPlatform.new(30 + rand(341), -140)
    ]
  when 2..3
    # spawn a boost platform and a normal platform
    [
      BoostPlatform.new(30 + (last_x + rand(limit*2+1) - limit) %340, -20),
      StaticPlatform.new(30 + rand(341), -70)
    ]
  when 4..5
    # spawn a horizontally moving platform
    [HorizontalMoveablePlatform.new(30 + rand(341), -20)]
  when 7
    # spawn 2 vertically moving platforms and a normal platform
    [
      VerticalMoveablePlatform.new(temp = 30 + (last_x - rand(limit+1)) %270, -20, 1),
      VerticalMoveablePlatform.new(temp + 70, -158, -1),
      StaticPlatform.new(30 + rand(341), -240)
    ]
  else
    # spawn a normal platform
    [StaticPlatform.new(30 + (last_x + rand(limit*2+1) - limit) %340, -20)]
  end
end

# Generate a breakable platform that break on collision with player
def generate_random_breakable_platform
  [BreakablePlatform.new(30 + rand(341), -20)]
end

# Move a platform in y ordinate
# @param platform: the platform to move
# @param y: the distance to move
def platform_move_y(platform, y)
  platform.y -= y
  platform.top = platform.y - platform.h/2
  platform.bottom = platform.y + platform.h/2
end

# Draw a platform on screen
# @param platform: the platform to draw
def platform_draw(platform)
  case platform.type
  when :spike
    # Change the image of spike platform after a small delay (if applicable)
    if platform.is_spike and (Gosu.milliseconds - platform.start_delay > platform.delay_time)
      platform.img = platform.img_active
    elsif not platform.is_spike and (Gosu.milliseconds - platform.start_delay > platform.delay_time)
      platform.img = platform.img_normal
    end
  when :break
    # Change the image of breakable platform since colliding with player
    if platform.broken == nil
      platform.img = platform.imgs[0]
    elsif Gosu.milliseconds - platform.broken < 50
      platform.img = platform.imgs[1]
    elsif Gosu.milliseconds - platform.broken < 100
      platform.img = platform.imgs[2]
    else
      platform.img = platform.imgs[3]
    end
  end
  platform.img.draw_rot(platform.x, platform.y, ZOrder::PLATFORMS)
end

# Change the state of a spike platform
# @param spike_platform: the spike platform to change state
def change_state(spike_platform)
  spike_platform.sfx.play(0.3)
  spike_platform.is_spike = !spike_platform.is_spike
  spike_platform.start_delay = Gosu.milliseconds
end

# Activate a boost platform
# @param boost_platform: the boost platform to activate
def active(boost_platform)
  boost_platform.img = boost_platform.img_active
  boost_platform.sfx.play
end

# Move left and right a moveable platform
# @param moveable_platform: the moveable platform to move
def move_horizontal(moveable_platform)
  if moveable_platform.x < moveable_platform.w/2 or moveable_platform.x > Window::WIDTH - moveable_platform.w/2
    # Invert direction if at the edge of screen
    moveable_platform.dir = - moveable_platform.dir
  end
  moveable_platform.x += moveable_platform.vx * moveable_platform.dir
  moveable_platform.left = moveable_platform.x - moveable_platform.w/2
  moveable_platform.right = moveable_platform.x + moveable_platform.w/2
end

# Move up and down a moveable platform
# @param moveable_platform: the moveable platform to move
def move_vertical(moveable_platform)
  if Gosu.milliseconds - moveable_platform.t > 2500
    # Invert direction after a certain amount of time
    moveable_platform.dir = - moveable_platform.dir
    moveable_platform.t = Gosu.milliseconds
  end
  moveable_platform.y += moveable_platform.vy * moveable_platform.dir
  moveable_platform.top = moveable_platform.y - moveable_platform.h/2
  moveable_platform.bottom = moveable_platform.y + moveable_platform.h/2
end

# Break a platform on collision with player
# @param breakable_platform: the platform to break
def platform_break(breakable_platform)
  if breakable_platform.broken == nil
    breakable_platform.broken = Gosu.milliseconds
    breakable_platform.sfx.play(0.5)
  end
end

# Drop a breakable platform after collision with player
# @param breakable_platform: the platform to drop
def drop(breakable_platform)
  breakable_platform.vy += Gravity
  breakable_platform.y += breakable_platform.vy
  breakable_platform.top = breakable_platform.y - breakable_platform.h/2
  breakable_platform.bottom = breakable_platform.y + breakable_platform.h/2
end

class StaticPlatform
  attr_accessor :type, :top, :bottom, :left, :right, :x, :y, :w, :h, :img
  # Generate new normal platform
  # @param x: x ordinate of platform
  # @param y: y ordinate of platform
  def initialize(x, y)
    @type = :static
    @img = Gosu::Image.new("./img/static_platform.png")
    @x = x
    @y = y
    @w = 57
    @h = 15

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end
end

class SpikePlatform
  attr_accessor :type, :top, :bottom, :left, :right, :x, :y, :w, :h, :img, :img_normal, :img_active, :is_spike, :sfx, :start_delay, :delay_time
  # Generate new normal platform
  # @param x: x ordinate of platform
  # @param y: y ordinate of platform
  # @param is_spike: whether the platform is active by default or not
  def initialize(x, y, is_spike)
    @type = :spike
    @img_normal, @img_active = *Gosu::Image.load_tiles("img/spike_platform.png", 57, 35)
    @sfx = Gosu::Sample.new("sound/piston.wav")
    @img = @img_normal
    @x = x
    @y = y
    @w = 57
    @h = 15
    @is_spike = is_spike
    @start_delay = 0
    @delay_time = 200

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end
end

class BoostPlatform
  attr_accessor :type, :top, :bottom, :left, :right, :x, :y, :w, :h, :img, :img_active, :sfx
  # Generate new normal platform
  # @param x: x ordinate of platform
  # @param y: y ordinate of platform
  def initialize(x, y)
    @type = :boost
    @img, @img_active = *Gosu::Image.load_tiles("./img/boost_platform.png", 57, 45)
    @sfx = Gosu::Sample.new("sound/boost.mp3")
    @x = x
    @y = y
    @w = 57
    @h = 15

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end
end

class HorizontalMoveablePlatform
  attr_accessor :type, :top, :bottom, :left, :right, :x, :y, :w, :h, :img, :dir, :vx
  # Generate new normal platform
  # @param x: x ordinate of platform
  # @param y: y ordinate of platform
  def initialize(x, y)
    @type = :movehori
    @img = Gosu::Image.new("./img/horizontal_moveable_platform.png")
    @x = x
    @y = y
    @w = 57
    @h = 15
    @dir = 1
    @vx = 1

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end
end

class VerticalMoveablePlatform
  attr_accessor :type, :top, :bottom, :left, :right, :x, :y, :w, :h, :img, :dir, :vy, :t
  # Generate new normal platform
  # @param x: x ordinate of platform
  # @param y: y ordinate of platform
  # @param dir: the default moving direction of the platform
  def initialize(x, y, dir)
    @type = :movevert
    @img = Gosu::Image.new("./img/vertical_moveable_platform.png")
    @x = x
    @y = y
    @w = 57
    @h = 15
    @dir = dir
    @vy = 1
    @t = 0

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end
end

class BreakablePlatform
  attr_accessor :type, :top, :bottom, :left, :right, :x, :y, :w, :h, :img, :imgs, :sfx, :vy, :broken
  # Generate new normal platform
  # @param x: x ordinate of platform
  # @param y: y ordinate of platform
  def initialize(x, y)
    @type = :break
    @imgs = Gosu::Image.load_tiles("img/breakable_platform.png", 60, 33)
    @img = @imgs[0]
    @sfx = Gosu::Sample.new("sound/break.mp3")
    @x = x
    @y = y
    @w = 60
    @h = 15
    @broken = nil
    @vy = 2

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - @w/2
    @right = @x + @w/2
  end
end
