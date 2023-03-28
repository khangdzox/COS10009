require './modules'
require './entity/player'
require './entity/platform'
require './state/game_state'
require './state/replay_state'

class PlayState < GameState
  # Generate new playing state
  # @param window: the associated window
  def initialize(window)
    super(window)

    # Initialize platforms list
    @platforms = []
    19.downto(-10) do |i|
      @platforms << StaticPlatform.new(30 + rand(341), i * 30)
    end

    @player = Player.new(@platforms[0].x, 600)
    jump(@player, -13, 0)

    @highest_standable_platform = @platforms.last

    @background_color = 0xFF_82C4FF

    @bgm = Gosu::Song.new('sound/Insert-Quarter.mp3')
    @bgm.volume = 0.4
  end

    # Play background music when enter play state
  def enter
    @bgm.play(true)
  end

    # Stop background music when exit play state
  def leave
    @bgm.stop
  end

  def draw
    intro if @intro
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, @background_color)
    player_draw(@player)
    draw_score(@player)
    draw_heart(@player)
    @platforms.each do |platform|
      platform_draw(platform)
    end
  end

  def update
    # Handle platforms
    @platforms.each do |platform|
      # Animate platforms
      case platform.type
      when :movehori
        move_horizontal(platform)
      when :movevert
        move_vertical(platform)
      when :break
        drop(platform) if platform.broken != nil
      end

      # Checking for collision with platforms if the player is falling
      if @player.vy > 0 and not is_dead(@player)
        if platform.bottom > HeightLimit + 60
          if collide_with(@player, platform)
            case platform.type
            when :boost
              active(platform)
              jump(@player, -22)
              roll(@player)
            when :break
              platform_break(platform)
            when :spike
              if platform.is_spike
                damage(@player)
              end
              @platforms.each do |platform|
                if platform.type == :spike
                  change_state(platform)
                end
              end
              jump(@player)
            else
              jump(@player)
            end
          end
        end
      end
    end

    # Control the player
    if not is_dead(@player) and not is_hurt(@player)
      if Gosu.button_down?(Gosu::KB_A) or Gosu.button_down?(Gosu::KB_LEFT)
        move_left(@player)
      elsif Gosu.button_down?(Gosu::KB_D) or Gosu.button_down?(Gosu::KB_RIGHT)
        move_right(@player)
      end
    end
    slow_down(@player)

    # Animate the player and scrolling the screen
    fall(@player)
    if @player.vy < 0 and @player.top <= HeightLimit
      @platforms.each { |platform| platform_move_y(platform, @player.vy + @player.top - HeightLimit)}
      @platforms.reject! { |platform| platform.bottom >= Window::HEIGHT}
      set_top(@player, HeightLimit)
      @player.score += 1
    else
      player_move_y(@player)
    end
    player_move_x(@player)

    # Randomly generate new platforms
    if @platforms.last.top > 5
      if @highest_standable_platform.top > 80
        @platforms += generate_random_standable_platform(@highest_standable_platform.x, 70)
        @highest_standable_platform = @platforms.last
      elsif @highest_standable_platform.top > 50
        if rand(100) < 50
          @platforms += generate_random_standable_platform(@highest_standable_platform.x, 120)
          @highest_standable_platform = @platforms.last
        elsif rand(100) < 30
          @platforms += generate_random_breakable_platform
        end
      elsif @highest_standable_platform.top > 30
        if rand(100) < 30
          @platforms += generate_random_standable_platform(@highest_standable_platform.x, 180)
          @highest_standable_platform = @platforms.last
        elsif rand(100) < 30
          @platforms += generate_random_breakable_platform
        end
      elsif @highest_standable_platform.top > 10
        if rand(100) < 10
          @platforms += generate_random_standable_platform(@highest_standable_platform.x, 200)
          @highest_standable_platform = @platforms.last
        elsif rand(100) < 10
          @platforms += generate_random_breakable_platform
        end
      end
    end

    # End game if player fall ouf of the screen
    if @player.top >= Window::HEIGHT
      state_switch(@window, ReplayState.new(@window, @player.score, @player.x, @player.dir))
    end
  end
end