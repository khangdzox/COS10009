require './modules'
require './track'
require './artwork'

def read_albums
  if File.exist?('albums.txt')
    filename = 'albums.txt'
  else
    print('Albums file: ')
    filename = gets.chomp
  end

  file = File.new(filename, 'r')

  albums = []
  albums_count = file.gets.to_i
  albums_count.times do
    albums << Album.from_file(file)
  end

  file.close
  albums
end

class Album
  attr_accessor :title, :artist, :artwork, :tracks, :from_file, :x, :y, :state

  def initialize(title, artist, artwork, tracks)
    @title = title
    @artist = artist
    @artwork = artwork
    @tracks = tracks

    @font_title = Gosu::Font.new(30, bold: true)
    @font = Gosu::Font.new(20)
    @x = @y = 0

    @state = State::NONE
  end

  def self.from_file(file)
    title = file.gets.chomp

    artist = file.gets.chomp

    artwork_filename = file.gets.chomp
    artwork = ArtWork.new(artwork_filename)

    tracks = []
    tracks_count = file.gets.chomp.to_i
    tracks_count.times do |_i|
      track_title = file.gets.chomp
      track_loc = file.gets.chomp
      tracks << Track.new(track_title, track_loc)
    end

    new(title, artist, artwork, tracks)
  end

  def draw
    @artwork.draw(@x, @y, 100, 100)

    @font_title.draw_text(@title, @x + 110, @y + 10, ZOrder::UI)

    @font.draw_text(@artist, @x + 110, @y + 40, ZOrder::UI, 1, 1, 0xaa_ffffff)

    text_tracks = "#{@tracks.length} track#{@tracks.length > 1 ? 's' : ''}"
    @font.draw_text(text_tracks, @x + 110, @y + 60, ZOrder::UI, 1, 1, 0xaa_ffffff)

    case @state
    when State::CLICKED
      draw_clicked
    when State::HOVERED
      draw_hovered
    when State::SELECTED
      draw_selected
    end
  end

  def draw_hovered
    Gosu.draw_rect(20, @y - 10, 460, 120, 0x33_000000, ZOrder::MID)
  end

  def draw_clicked
    Gosu.draw_rect(20, @y - 10, 460, 120, 0x66_000000, ZOrder::MID)
  end

  def draw_selected
    Gosu.draw_rect(20, @y - 10, 460, 120, 0x4b_00ddff, ZOrder::MID)
  end
end
