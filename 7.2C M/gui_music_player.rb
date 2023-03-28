require 'rubygems'
require 'gosu'

## albums.txt
# <number of albums>
# <first album's title>
# <first album's artist>
# <first album's artwork location>
# <number of tracks in album>
# <first track's title>
# <first track's location>
# ... and so on
## albums.txt

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, MID, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

module State
  NONE, HOVERED, CLICKED, SELECTED = *0..3
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

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

    tracks = Array.new
    tracks_count = file.gets.chomp.to_i
    tracks_count.times do |i|
      track_title = file.gets.chomp
      track_loc = file.gets.chomp
      tracks << Track.new(track_title, track_loc)
    end

    return self.new(title, artist, artwork, tracks)
  end

  def draw
    # draw at x (top-left), y(top-left)
    @artwork.draw(@x, @y, 100, 100)

    @font_title.draw_text(@title, @x+110, @y+10, ZOrder::UI)

    @font.draw_text(@artist, @x+110, @y+40, ZOrder::UI, 1, 1, 0xaa_ffffff)

    text_tracks = "#{@tracks.length} track#{@tracks.length > 1 ? 's' : ''}"
    @font.draw_text(text_tracks, @x+110, @y+60, ZOrder::UI, 1, 1, 0xaa_ffffff)
  end

  def draw_hovered
    Gosu::draw_rect(40, @y-10, 420, 120, 0x33_000000, ZOrder::MID)
  end

  def draw_clicked
    Gosu::draw_rect(40, @y-10, 420, 120, 0x55_000000, ZOrder::MID)
  end

  def draw_selected
    Gosu::draw_rect(40, @y-10, 420, 120, 0x55_ffffff, ZOrder::MID)
  end

end

class Track
  attr_accessor :title, :location, :x, :y, :state

  def initialize(title, location)
    @title = title
    @location = location

    @font_normal = Gosu::Font.new(18)
    @font_playing = Gosu::Font.new(20, bold: true)

    @x = @y = 0

    @state = State::NONE
  end

  def draw
    if @state < State::SELECTED
      @font_normal.draw_text(@title, x, y, ZOrder::UI, 1, 1, 0xff_ffffff)
    else
      @font_playing.draw_text(@title, x, y-1, ZOrder::UI, 1, 1, 0xff_ffffff)
    end
  end

  def draw_hovered
    Gosu::draw_rect(500, @y-6, 300, 30, 0x33_000000, ZOrder::MID)
  end

  def draw_clicked
    Gosu::draw_rect(500, @y-6, 300, 30, 0x55_000000, ZOrder::MID)
  end

  def draw_selected
    Gosu::draw_rect(500, @y-6, 300, 30, 0x55_ffffff, ZOrder::MID)
  end
end

class ArtWork
  attr_accessor :bmp

  def initialize (file)
    @bmp = Gosu::Image.new(file)
  end

  def draw(x, y, w, h)
    @bmp.draw_as_quad(x, y, Gosu::Color::WHITE, x+w, y, Gosu::Color::WHITE, x, y+h, Gosu::Color::WHITE, x+w, y+h, Gosu::Color::WHITE, ZOrder::UI)
  end
end

# Put your record definitions here

class MusicPlayerMain < Gosu::Window

  def initialize
    super 800, 600
    self.caption = "Music Player"

    @title = Gosu::Font.new(50, bold: true)
    @track_normal = Gosu::Font.new(17)
    @track_playing = Gosu::Font.new(20, bold: true)

    @playing = nil
    @current_song_index = -1

    # Reads in an array of albums from a file and then prints all the albums in the
    # array to the terminal
    if File.exist?('albums.txt')
      @albums = read_albums('albums.txt')
    else
      print("Albums file: ")
      filename = gets.chomp
      @albums = read_albums(filename)
    end
  end

  # Put in your code here to load albums and tracks
  def read_albums(filename)
    file = File.new(filename, 'r')

    albums = Array.new
    albums_count = file.gets.to_i
    albums_count.times do
      albums << Album.from_file(file)
    end

    file.close
    return albums
  end

  # Draws the artwork on the screen for all the albums
  def draw_albums
    @title.draw_text("Albums", 50, 25, ZOrder::UI)

    x = 50
    y = 100

    @albums.each do |album|
      album.x = x
      album.y = y
      album.draw

      case album.state
      when State::CLICKED
        album.draw_clicked
      when State::HOVERED
        album.draw_hovered
      when State::SELECTED
        album.draw_selected
      end

      y += 125
    end
  end

  def draw_tracks
    Gosu::draw_rect(500, 0, 300, 600, 0x33_000000, ZOrder::MID)
    @title.draw_text("Tracks", 550, 25, ZOrder::UI)

    x = 525
    y = 100

    @playing.tracks.length.times do |i|
      @playing.tracks[i].x = x
      @playing.tracks[i].y = y
      @playing.tracks[i].draw

      case @playing.tracks[i].state
      when State::CLICKED, State::CLICKED + State::SELECTED
        @playing.tracks[i].draw_clicked
      when State::HOVERED, State::HOVERED + State::SELECTED
        @playing.tracks[i].draw_hovered
      when State::SELECTED
        @playing.tracks[i].draw_selected
      end

      y += 30
    end
  end

  # You may want to use the following:
  # def display_track(title, x, y)
  # 	@track_normal.draw_text(title, x, y, ZOrder::MID, 1, 1, 0xff_ffffff)
  # end

  # Detects if a 'mouse sensitive' area has been clicked on
  # i.e either an album or a track. returns true or false

  def is_mouse_in(leftX, topY, rightX, bottomY)
    # complete this code
    return (((leftX <= mouse_x) and (mouse_x <= rightX)) and ((topY <= mouse_y) and (mouse_y <= bottomY)))
 end

  # Takes a track index and an Album and plays the Track from the Album

  def playTrack(track_index, album)
    if track_index == album.tracks.length
      @playing = nil
      @current_song_index = -1
    else
      @song = Gosu::Song.new(album.tracks[track_index].location)
      @song.play(false)
    end
  end

# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR

  def draw_background
    draw_quad(0, 0, TOP_COLOR, 800, 0, TOP_COLOR, 0, 600, BOTTOM_COLOR, 800, 600, BOTTOM_COLOR, ZOrder::BACKGROUND)
  end

# Not used? Everything depends on mouse actions.

  def update
    if Gosu::Song.current_song == nil and @playing != nil
      @current_song_index += 1
      playTrack(@current_song_index, @playing)
    end

    @albums.each do |album|
      if is_mouse_in(40, album.y - 10, 460, album.y + 110)
        if button_down?(Gosu::MsLeft)
          album.state = State::CLICKED
          if Gosu::Song.current_song != nil
            @song.stop
            @current_song_index = -1
          end
          @playing = album
        else
          album.state = State::HOVERED
        end
      elsif album == @playing
        album.state = State::SELECTED
      else
        album.state = State::NONE
      end
    end

    if @playing != nil
      @playing.tracks.length.times do |i|
        if is_mouse_in(525, @playing.tracks[i].y - 6, 800, @playing.tracks[i].y + 24)
          if button_down?(Gosu::MsLeft)
            @playing.tracks[i].state = State::CLICKED + State::SELECTED
            @song.stop
            @current_song_index = i - 1
          else
            @playing.tracks[i].state = State::HOVERED + (@playing.tracks[i].state >= State::SELECTED ? State::SELECTED : 0)
          end
        elsif @current_song_index == i
          @playing.tracks[i].state = State::SELECTED
        else
          @playing.tracks[i].state = State::NONE
        end
      end
    end
  end

 # Draws the album images and the track list for the selected album

  def draw
    # Complete the missing code
    draw_background()
    draw_albums()
    if @playing != nil
      draw_tracks()
    end
  end

   def needs_cursor?; true; end

  def button_down(id)
    case id
    when Gosu::MsLeft
    end
  end

end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0