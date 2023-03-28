require './state/menu_state'

# Switch the current state of window
# @param window: the window to change state
# @param new_state: the state to change to
def state_switch(window, new_state)
  window.state && window.state.leave
  window.state = new_state
  new_state.enter
end

# Main game window
class MainWindow < Gosu::Window
  attr_accessor :state

  def initialize
    super Window::WIDTH, Window::HEIGHT
    self.caption = "Infinite Jumper"
    @state = state
  end

  def draw
    @state.draw
  end

  def update
    @state.update
  end
end

window = MainWindow.new
state_switch(window, MenuState.new(window))
window.show
