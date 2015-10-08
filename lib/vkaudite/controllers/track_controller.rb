require_relative 'controller'
require_relative '../time_helper'
require_relative '../ui/table'
require_relative '../ui/input'
require_relative '../models/track_collection'

module VKAudite
  module Controllers
    class TrackController < Controller

      def initialize(view, client)
        super(view)

        @client = client

        events.on(:key) do |key|
          case key
          when :enter
            @view.select
            events.trigger(:select, current_track)
          when :up, :k
            @view.up
          when :down, :j
            @view.down
            else

          end
        end
      end

      def current_track
        @tracks[@view.current]
      end

      # tracks is TrackCollection
      def bind_to(tracks)
        @tracks = tracks
        @view.bind_to(tracks)
      end

      def load
        @tracks.load
      end

      def next_track
        @view.down
        @view.select
        events.trigger(:select, current_track)
      end
    end
  end
end
