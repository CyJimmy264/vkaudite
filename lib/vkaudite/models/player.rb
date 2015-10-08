require 'audite'
require_relative '../download_thread'

module VKAudite
  module Models
    class Player
      attr_reader :track, :events

      def initialize
        @track = nil
        @events = Events.new
        @folder = File.expand_path('~/.config/vkaudite')
        @tracks_folder = @folder + '/tracks'
        @seek_speed = {}
        @seek_time = {}
        create_player

        Dir.mkdir(@folder) unless File.exist?(@folder)
        Dir.mkdir(@tracks_folder) unless File.exist?(@tracks_folder)
      end

      def create_player
        @player = Audite.new
        @player.events.on(:position_change) do |position|
          events.trigger(:progress)
        end

        @player.events.on(:complete) do
          log :player_event, :complete
          events.trigger(:complete)
        end
      end

      def play(track, location)
        log :play, track.artist
        @track = track
        load(track, location)
        start
      end

      def play_progress
        seconds_played / duration
      end

      def duration
        @track.duration
      end

      def title
        @track.title
      end

      # TODO: reveal Mpg123 method names to clarify formula
      def length_in_seconds
        mpg = Mpg123.new(@file)
        mpg.length * mpg.tpf / mpg.spf
      end

      def load(track, location, &block)
        filename = "#{track.artist} - #{track.title}.mp3"
        filename.gsub!(/[^0-9A-Za-z.\-]/, '_')
        @file = "#{@tracks_folder}/#{filename}"

        if (!File.exist?(@file)) || (track.duration / 1000) > length_in_seconds
          File.unlink(@file) rescue nil
          @download = DownloadThread.new(location, @file)
        else
          @download = nil
        end

        @player.load(@file)
      end

      def log(*args)
        VKAudite::Application.logger.debug "Player: " + args.join(" ")
      end

      def level
        @player.level
      end

      def seconds_played
        @player.position
      end

      def download_progress
        if @download
          @download.progress / @download.total.to_f
        else
          1
        end
      end

      def playing?
        @player.active
      end

      # TODO: understand this
      def seek_speed(direction)
        if @seek_time[direction] && Time.now - @seek_time[direction] < 0.5
          @seek_speed[direction] *= 1.05
        else
          @seek_speed[direction] = 1
        end

        @seek_time[direction] = Time.now
        @seek_speed[direction]
      end

      # change song position
      def seek_position(position)
        position *= 0.1
        relative_position = position * duration
        if relative_position < seconds_played
          difference = seconds_played - relative_position
          @player.rewind(difference)
        elsif download_progress > (relative_position / duration) && relative_position > seconds_played
          log download_progress
          difference = relative_position - seconds_played
          @player.forward(difference)
        end
      end

      def rewind
        @player.rewind(seek_speed(:rewind))
      end

      def forward
        seconds = seek_speed(:forward)

        if ((seconds + seconds_played) / duration) < download_progress
          @player.forward(seconds)
        end
      end

      def stop
        @player.stop_stream
      end

      def start
        @player.start_stream
      end

      def toggle
        @player.toggle
      end
    end
  end
end
