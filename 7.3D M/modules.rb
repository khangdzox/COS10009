require 'rubygems'
require 'gosu'

module ZOrder
  BACKGROUND, MID, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

module State
  NONE, INACTIVE, HOVERED, CLICKED, SELECTED = *0..4
end

TOP_BG_COLOR = Gosu::Color.new(0xFF_1EB1FA)
BOTTOM_BG_COLOR = Gosu::Color.new(0xFF_0F275B)
CONTROL_BAR_COLOR = Gosu::Color.new(0xFF_142852)

UI_COLOR = Gosu::Color::WHITE
UI_INACTIVE_COLOR = Gosu::Color.new(0xFF_7E7E7E)
UI_HOVERED_COLOR = Gosu::Color.new(0x7F_FFFFFF)
UI_CLICKED_COLOR = Gosu::Color.new(0x4C_999999)

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']
