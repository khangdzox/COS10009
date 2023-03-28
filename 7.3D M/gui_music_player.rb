####################################
#          Main Program            #
####################################

# Beside basis function, this program can:
# - Page through multiple pages of albums and tracks
# - Automatically load albums.txt if exist
# - Back, next, and play-pause button
# - Adjust volume
# - Show current playing song at the bottom left corner
#   as well as highlight in tracks list

# Please note that the albums.txt file is just an example
# file. You should change it so that the path is actual
# link to your file on your system.

## albums.txt file structure
# <number of albums>
# <first album's title>
# <first album's artist>
# <first album's artwork location>
# <number of tracks in album>
# <first track's title>
# <first track's location>
# ... and so on
## end of albums.txt file structure

require './modules'
require './album'
require './track'
require './artwork'
require './circle'
require './ui'

class MusicPlayerMain < Gosu::Window

  def initialize
    super 800, 600
    self.caption = "Music Player"

    @title = Gosu::Font.new(50, bold: true)
    @track_normal = Gosu::Font.new(17)
    @track_playing = Gosu::Font.new(20, bold: true)
    @ui_font = Gosu::Font.new(30, bold: true)
    @detail_font = Gosu::Font.new(15)

    @back_button_album = BackButton.new(183, 485, 23, 26)
    @next_button_album = NextButton.new(288, 485, 23, 26)

    @back_button_track = BackButton.new(586, 485, 23, 26)
    @next_button_track = NextButton.new(691, 485, 23, 26)

    @back_button_music = BackButton.new(299, 545, 30, 35)
    @next_button_music = NextButton.new(472, 545, 30, 35)
    @play_button = PlayButton.new(376, 538)

    @vol_down_button = VolDownButton.new(607, 558)
    @vol_up_button = VolUpButton.new(756, 547)
    @volume_display = Volume.new(649, 542)

    @volume = 1.0

    @playing_album = nil
    @playing_song_index = nil

    @selecting_album = nil

    @albums = read_albums()

    @album_page = 1
    @track_page = 1

    @max_album_page = @albums.length == 0 ? 1 : (@albums.length / 3 != @albums.length / 3.0) ? @albums.length / 3 + 1 : @albums.length / 3
  end

  # Check if mouse is in the area
  def is_mouse_in(leftX, topY, rightX, bottomY)
    return (((leftX <= mouse_x) and (mouse_x <= rightX)) and ((topY <= mouse_y) and (mouse_y <= bottomY)))
  end

  # Play the track, reset playing_album if out of bound
  def play_track(track_index, album)
    if track_index < 0 or track_index == album.tracks.length
      @song.stop
      @playing_album = nil
      @playing_song_index = nil
    else
      @song = Gosu::Song.new(album.tracks[track_index].location)
      @song.volume = @volume
      @song.play(false)
    end
  end

  # Drawing functions

  def draw_background
    @title.draw_text("Albums", 35, 20, ZOrder::UI)
    @title.draw_text("Tracks", 535, 20, ZOrder::UI)
    draw_quad(0, 0, TOP_BG_COLOR, 800, 0, TOP_BG_COLOR, 0, 600, BOTTOM_BG_COLOR, 800, 600, BOTTOM_BG_COLOR, ZOrder::BACKGROUND)
    draw_rect(0, 525, 800, 75, CONTROL_BAR_COLOR, ZOrder::MID)
    draw_rect(500, 0, 300, 525, 0x33_000000, ZOrder::MID)
  end

  def draw_albums
    x = 30
    y = 100

    @albums.slice((@album_page-1)*3, @album_page*3).each do |album|
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

      y += 130
    end
  end

  def draw_tracks
    x = 525
    y = 96

    @selecting_album.tracks.slice((@track_page-1)*10, @track_page*10).each do |track|
      track.x = x
      track.y = y
      track.draw

      case track.state
      when State::CLICKED, State::CLICKED + State::SELECTED
        track.draw_clicked
      when State::HOVERED, State::HOVERED + State::SELECTED
        track.draw_hovered
      when State::SELECTED
        track.draw_selected
      end

      y += 39
    end
  end

  def draw_control
    # album control
    @back_button_album.draw
    @next_button_album.draw
    @ui_font.draw_text(@album_page.to_s, 240, 484, ZOrder::UI)

    # track control
    @back_button_track.draw
    @next_button_track.draw
    @ui_font.draw_text(@track_page.to_s, 643, 484, ZOrder::UI)

    # playback control
    @back_button_music.draw
    @next_button_music.draw
    @play_button.draw
  end

  def draw_detail
    @playing_album.artwork.draw(10, 535, 55, 55)
    @detail_font.draw_markup("<b>" + @playing_album.title + "</b>", 75, 545, ZOrder::UI)
    @detail_font.draw_markup(@playing_album.tracks[@playing_song_index].title, 75, 565, ZOrder::UI, 1, 1, 0xaa_ffffff)
  end

  def draw_vol
    @vol_down_button.draw
    @vol_up_button.draw
    @volume_display.draw(@volume)
  end

  # Update function

  def update
    # Next song when end if is playing
    if Gosu::Song.current_song == nil and @playing_album != nil and @playing_song_index != nil
      @playing_song_index += 1
      play_track(@playing_song_index, @playing_album)
    end

    # Album page handle
    if @album_page == 1
      @back_button_album.state = State::INACTIVE
    elsif is_mouse_in(@back_button_album.x, @back_button_album.y, @back_button_album.x + @back_button_album.w, @back_button_album.y + @back_button_album.h)
      if button_down?(Gosu::MsLeft)
        if @back_button_album.state != State::CLICKED
          @back_button_album.state = State::CLICKED
          @album_page -= 1
        end
      else
        @back_button_album.state = State::HOVERED
      end
    else
      @back_button_album.state = State::NONE
    end

    if @album_page == @max_album_page
      @next_button_album.state = State::INACTIVE
    elsif is_mouse_in(@next_button_album.x, @next_button_album.y, @next_button_album.x + @next_button_album.w, @next_button_album.y + @next_button_album.h)
      if button_down?(Gosu::MsLeft)
        if @next_button_album.state != State::CLICKED
          @next_button_album.state = State::CLICKED
          @album_page += 1
        end
      else
        @next_button_album.state = State::HOVERED
      end
    else
      @next_button_album.state = State::NONE
    end

    # Track page handle
    if @selecting_album != nil
      @max_track_page = @selecting_album.tracks.length == 0 ? 1 : (@selecting_album.tracks.length / 10 != @selecting_album.tracks.length / 10.0) ? @selecting_album.tracks.length / 10 + 1 : @selecting_album.tracks.length / 10

      if @track_page == 1
        @back_button_track.state = State::INACTIVE
      elsif is_mouse_in(@back_button_track.x, @back_button_track.y, @back_button_track.x + @back_button_track.w, @back_button_track.y + @back_button_track.h)
        if button_down?(Gosu::MsLeft)
          if @back_button_track.state != State::CLICKED
            @back_button_track.state = State::CLICKED
            @track_page -= 1
          end
        else
          @back_button_track.state = State::HOVERED
        end
      else
        @back_button_track.state = State::NONE
      end

      if @track_page == @max_track_page
        @next_button_track.state = State::INACTIVE
      elsif is_mouse_in(@next_button_track.x, @next_button_track.y, @next_button_track.x + @next_button_track.w, @next_button_track.y + @next_button_track.h)
        if button_down?(Gosu::MsLeft)
          if @next_button_track.state != State::CLICKED
            @next_button_track.state = State::CLICKED
            @track_page += 1
          end
        else
          @next_button_track.state = State::HOVERED
        end
      else
        @next_button_track.state = State::NONE
      end
    else
      @back_button_track.state = State::INACTIVE
      @next_button_track.state = State::INACTIVE
    end

    # Album state handle
    @albums.slice((@album_page-1)*3, @album_page*3).each do |album|
      if is_mouse_in(20, album.y - 10, 480, album.y + 110)
        if button_down?(Gosu::MsLeft)
          album.state = State::CLICKED
          @selecting_album = album
          @track_page = 1
        else
          album.state = State::HOVERED
        end
      elsif album == @selecting_album
        album.state = State::SELECTED
      else
        album.state = State::NONE
      end
    end

    # Track state handle
    if @selecting_album != nil
      tracks_on_display = @selecting_album.tracks.slice((@track_page-1)*10, @track_page*10)
      tracks_on_display.length.times do |i|
        if is_mouse_in(525, tracks_on_display[i].y - 6, 800, tracks_on_display[i].y + 24)
          if button_down?(Gosu::MsLeft)
            tracks_on_display[i].state = State::CLICKED + State::SELECTED
            if Gosu::Song.current_song != nil
              @song.stop
            end
            @playing_album = @selecting_album
            @playing_song_index = (@track_page-1)*10 + i
            play_track(@playing_song_index, @playing_album)
          else
            tracks_on_display[i].state = State::HOVERED + (tracks_on_display[i].state >= State::SELECTED ? State::SELECTED : 0)
          end
        elsif @selecting_album == @playing_album and @playing_song_index == (@track_page-1)*10 + i
          tracks_on_display[i].state = State::SELECTED
        else
          tracks_on_display[i].state = State::NONE
        end
      end
    end

    # playback state handle
    if @playing_album != nil

      # back button handle
      if is_mouse_in(@back_button_music.x, @back_button_music.y, @back_button_music.x + @back_button_music.w, @back_button_music.y + @back_button_music.h)
        if button_down?(Gosu::MsLeft)
          if @back_button_music.state != State::CLICKED
            @back_button_music.state = State::CLICKED
            @playing_song_index -= 1
            play_track(@playing_song_index, @playing_album)
          end
        else
          @back_button_music.state = State::HOVERED
        end
      else
        @back_button_music.state = State::NONE
      end

      # next button handle
      if is_mouse_in(@next_button_music.x, @next_button_music.y, @next_button_music.x + @next_button_music.w, @next_button_music.y + @next_button_music.h)
        if button_down?(Gosu::MsLeft)
          if @next_button_music.state != State::CLICKED
            @next_button_music.state = State::CLICKED
            @playing_song_index += 1
            play_track(@playing_song_index, @playing_album)
          end
        else
          @next_button_music.state = State::HOVERED
        end
      else
        @next_button_music.state = State::NONE
      end

      # play button handle
      if is_mouse_in(@play_button.x, @play_button.y, @play_button.x + @play_button.w, @play_button.y + @play_button.h)
        if button_down?(Gosu::MsLeft)
          if @play_button.state != State::CLICKED
            @play_button.state = State::CLICKED
            @song.playing? ? @song.pause : @song.play
          end
        else
          @play_button.state = State::HOVERED
        end
      else
        @play_button.state = State::NONE
      end

      if @song.playing?
        @play_button.is_play = true
      else
        @play_button.is_play = false
      end

    else
      @back_button_music.state = State::INACTIVE
      @next_button_music.state = State::INACTIVE
      @play_button.state = State::INACTIVE
      @play_button.is_play = false
    end

    # handle volume down
    if is_mouse_in(@vol_down_button.x, @vol_down_button.y, @vol_down_button.x + @vol_down_button.w, @vol_down_button.y + @vol_down_button.h)
      if button_down?(Gosu::MsLeft)
        if @vol_down_button.state != State::CLICKED
          @vol_down_button.state = State::CLICKED
          @volume = (@volume - (@volume > 0 ? 0.1 : 0)).round(1)
          if Gosu::Song.current_song != nil
            @song.volume = @volume
          end
        end
      else
        @vol_down_button.state = State::HOVERED
      end
    else
      @vol_down_button.state = State::NONE
    end

    # handle volume up
    if is_mouse_in(@vol_up_button.x, @vol_up_button.y, @vol_up_button.x + @vol_up_button.w, @vol_up_button.y + @vol_up_button.h)
      if button_down?(Gosu::MsLeft)
        if @vol_up_button.state != State::CLICKED
          @vol_up_button.state = State::CLICKED
          @volume = (@volume + (@volume < 1 ? 0.1 : 0)).round(1)
          if Gosu::Song.current_song != nil
            @song.volume = @volume
          end
        end
      else
        @vol_up_button.state = State::HOVERED
      end
    else
      @vol_up_button.state = State::NONE
    end
  end

  # Main draw function

  def draw
    draw_background()
    draw_albums()
    draw_control()
    draw_vol()
    if @selecting_album != nil
      draw_tracks()
    end
    if @playing_album != nil
      draw_detail()
    end
  end

  def needs_cursor?; true; end

end

MusicPlayerMain.new.show if __FILE__ == $0
