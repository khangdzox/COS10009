require './modules'

# Roll the player
# -> Set the time when player starts to roll to calculate the player angle later
# @param player: the player to roll
def roll(player)
  player.roll = Gosu.milliseconds
end

# Calculate the player's angle since when the player starts to roll
# @param player: the player to calculate the angle
def degree_since_roll(player)
  time_passed = Gosu.milliseconds - player.roll
  if time_passed > 740
    player.roll = nil
    return 0
  else
    return -360 * (1.0 - (1.0 - time_passed.to_f / 740.0) ** 2.0)
  end
end

# Damage a player
# -> reduce player's heart by 1
# @param player: the player to damage
def damage(player)
  player.heart -= 1
  player.time_start_hurt = Gosu.milliseconds
end

# Check if the player is dead or not
# @param player: the player to check
def is_dead(player)
  return true if player.heart <= 0
  return false
end

# Check if the player is hurt or not
# A player is hurt if the player has been damaged in the last 750ms
# @param player: the player to check
def is_hurt(player)
  return false if player.time_start_hurt.nil?
  if Gosu.milliseconds - player.time_start_hurt > 750
    player.time_start_hurt = nil
    return false
  else
    return true
  end
end

# Make a player to fall
# -> add gravity to player's vertical velocity
# @param player: the player to fall
def fall(player)
  player.vy += player.ay
end

# Make a player to jump
# @param player: the player to jump
# @param vy: the jumping velocity (negative value). The bigger -vy is, the higher the player jump. Default to -11
# @param vol: the volume of the jumping sound effect. Set to 0 to mute sound effect. Default to 1
def jump(player, vy = - 11, vol = 1)
  player.vy = vy
  player.sfx_jump.play(vol)
end

# Move a player left, also change the player's direction
# @param player: the player to move
def move_left(player)
  player.dir = 'left'
  if player.vx > -6
    player.ax = -0.4
    player.vx += player.ax
  end
end

# Move a player right, also change the player's direction
# @param player: the player to move
def move_right(player)
  player.dir = 'right'
  if player.vx < 6
    player.ax = 0.4
    player.vx += player.ax
  end
end

# Slowly decrease a player's velocity to 0
# @param player: the player to slow down
def slow_down(player)
  if player.vx > 0
    player.ax = -0.1
    player.vx += player.ax
    if player.vx < 0
      player.ax = 0
      player.vx = 0
    end
  elsif player.vx < 0
    player.ax = 0.1
    player.vx += player.ax
    if player.vx > 0
      player.ax = 0
      player.vx = 0
    end
  end
end

# Vertically move a player
# @param player: the player to move
def player_move_y(player)
  player.y += player.vy

  player.top = player.y - player.h/2
  player.bottom = player.y + player.h/2
end

# Horizontally move a player
# @param player: the player to move
def player_move_x(player)
  player.x += player.vx

  player.x = player.x % Window::WIDTH

  player.left = player.x - 15
  player.right = player.x + 15
end

# Set player's y ordinate to a position
# @param player: the player to set position
# @param top: the y ordinate to move the player's top to
def set_top(player, top)
  player.y = top + player.h/2
  player.top = top
  player.bottom = top + player.h
end

# Set player's x ordinate to a position
# @param player: the player to set position
# @param x: the x ordinate to move the player to
def set_x(player, x)
  player.x = x

  player.x = player.x % Window::WIDTH

  player.left = player.x - 15
  player.right = player.x + 15
end

# Check if a player is colliding with a platform
# @param player: the player to check
# @param platform: the platform to check
def collide_with(player, platform)
  if (platform.left <= player.left and player.left <= platform.right) or (platform.left <= player.right and player.right <= platform.right)
    if platform.bottom >= player.bottom and player.bottom >= platform.top
      return true
    end
  end
  return false
end

# Draw a player on the screen
# @param player: the player to draw
def player_draw(player)
  case player.dir
  when 'left'
    img = player.img_left
  when 'right'
    img = player.img_right
  end
  if is_hurt(player) and ((Gosu.milliseconds - player.time_start_hurt)/50).to_i.even?
    opacity = 0x66_ffffff
  else
    opacity = 0xff_ffffff
  end
  if player.roll == nil
    img.draw_rot(player.x, player.y, ZOrder::PLAYER, 0, 0.5, 0.5, 1, 1, opacity)
  else
    img.draw_rot(player.x, player.y, ZOrder::PLAYER, degree_since_roll(player), 0.5, 0.5, 1, 1, opacity)
  end
  player.img_stars.draw_rot(player.x, player.top, ZOrder::PLAYER, 0, 0.5, 0.5, 1, 1, opacity) if is_hurt(player) or is_dead(player)
end

# Draw a player's score on screen
# @param player: the player whose score is drawed
def draw_score(player)
  player.font_score.draw_text(player.score.to_s, 200 - player.score.to_s.length*10, 10, ZOrder::UI, 1, 1, Gosu::Color::YELLOW)
end

# Draw a player's hearts on screen
# @param player: the player whose hearts are drawed
def draw_heart(player)
  player.heart.times do |i|
    player.img_heart.draw(10 + i*35, 10, ZOrder::UI)
  end
end

class Player
  attr_accessor :score, :left, :right, :bottom, :top, :vx, :vy, :ax, :ay, :y, :x, :w, :h, :dir, :img_left, :img_right, :img_stars, :img_heart, :sfx_jump, :heart, :score, :font_score, :roll, :dead, :time_start_hurt

  def initialize(x, y)
    @img_left = Gosu::Image.new("img/lik-left.png")
    @img_right = Gosu::Image.new("img/lik-right.png")
    @img_stars = Gosu::Image.new("img/stars.png")
    @img_heart = Gosu::Image.new("img/heart.png")
    @sfx_jump = Gosu::Sample.new("sound/jump.wav")
    @x = x
    @y = y
    @w = 62
    @h = 60
    @vx = @vy = @ax = 0
    @ay = Gravity
    @heart = 3
    @score = 0
    @font_score = Gosu::Font.new(40, bold: true, name: "Consolas")
    @dir = 'right'
    @roll = nil
    @dead = false
    @time_start_hurt = nil

    @top = @y - @h/2
    @bottom = @y + @h/2
    @left = @x - 15
    @right = @x + 15
  end
end
