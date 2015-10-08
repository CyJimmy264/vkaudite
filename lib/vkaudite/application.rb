require 'logger'

require_relative 'ui/canvas'
require_relative 'ui/rect'
require_relative 'ui/input'

require_relative 'controllers/player_controller'
require_relative 'controllers/track_controller'

require_relative 'views/splash'
require_relative 'views/tracks_table'

module VKAudite
  class Application
    include Controllers
    include Views
    include Models

    def initialize(client)
      $stderr.reopen('debug.log', 'w')
      @canvas = UI::Canvas.new

      @splash_controller = Controller.new(
        Splash.new(
          UI::Rect.new(0, 0, Curses.cols, Curses.lines)
        )
      )

      @player_controller = PlayerController.new(
        PlayerView.new(
          UI::Rect.new(0, 0, Curses.cols, 5)
        ),
        client
      )

      @track_controller = TrackController.new(
        TracksTable.new(
          UI::Rect.new(0, 5, Curses.cols, Curses.lines - 5)
        ),
        client
      )

      @track_controller.bind_to(TrackCollection.new(client))

      @track_controller.events.on(:select) do |track|
        log :track_controller_event, track
        @player_controller.play(track)
      end

      @player_controller.events.on(:complete) do
        log :player_controller_event, :complete
        @track_controller.next_track
      end
    end

    def main
      loop do
        if @workaround_was_called_once_already
          handle UI::Input.get(-1)
        else
          @workaround_was_called_once_already = true
          handle UI::Input.get(0)
          @track_controller.load
          @track_controller.render
        end

        break if stop?
      end
    ensure
      @canvas.close
    end

    def run
      @splash_controller.render
      main
    end

    # TODO: look at active controller and send key to active controller instead
    def handle(key)
      case key
      when :left, :right, :space, :one, :two, :three, :four, :five, :six, :seven, :eight, :nine
        @player_controller.events.trigger(:key, key)
      when :down, :up, :enter, :u, :f, :s, :j, :k
        @track_controller.events.trigger(:key, key)
      else
      end
    end

    def stop
      @stop = true
    end

    def stop?
      @stop
    end

    def log(*args)
      VKAudite::Application.logger.debug "Application: " + args.join(" ")
    end

    def self.logger
      @logger ||= Logger.new('debug.log')
    end
  end
end
