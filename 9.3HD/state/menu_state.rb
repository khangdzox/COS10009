require './modules'
require './entity/button'
require './state/game_state'
require './state/play_state'

class MenuState < GameState
  # Generate new menu state
  # @param window: the associated window
  def initialize(window)
    super(window)
    @font = Gosu::Font.new(40, name: "./img/DoodleJump.ttf")
    @background_color = 0xFF_82C4FF
    @title = Gosu::Image.new("./img/doodle-jump.png")
    play_img = Gosu::Image.new("./img/play.png")
    play_img_pressed = Gosu::Image.new("./img/play-on.png")
    @play_button = Button.new(270, 270, 111, 40, play_img, play_img_pressed)
    @bgm = Gosu::Song.new('sound/Analog-Nostalgia.mp3')
    @bgm.volume = 0.7
    @platform = StaticPlatform.new(80, 500)
    @player = Player.new(80, 630)
    jump(@player, -15, 0)
  end

  # Play background music when enter menu state
  def enter
    @bgm.play(true)
  end

  # Stop background music when exit menu state
  def leave
    @bgm.stop
  end

  def draw
    intro if @intro
    outro if @outro
    platform_draw(@platform)
    player_draw(@player)
    @title.draw_rot(150, 200, ZOrder::UI)
    button_draw(@play_button)
    Gosu.draw_rect(0, 0, Window::WIDTH, Window::HEIGHT, @background_color)
  end

  def update
    # Animate the player
    if @player.vy > 0 and collide_with(@player, @platform)
      jump(@player)
    end
    fall(@player)
    player_move_y(@player)

    # Handle the button
    if button_clicked?(@play_button, @window.mouse_x, @window.mouse_y)
      @outro = true
    end
    if @outro == false
      state_switch(@window, PlayState.new(@window))
    end
  end
end