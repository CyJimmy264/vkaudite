require_relative 'collection'
require_relative 'track'
require_relative 'playlist'

module VKAudite
  module Models
    class TrackCollection < Collection
      DEFAULT_LIMIT = 50

      attr_reader :limit
      attr_accessor :collection_to_lead, :playlist

      def initialize(client)
        super
        @limit = DEFAULT_LIMIT
        @collection_to_lead = :recent
      end

      def size
        @rows.size
      end

      def clear_and_replace
        clear
        load_more
        events.trigger(:replace)
      end

      def load
        clear
        load_more
      end

      def load_more
        unless @loaded
          tracks = self.send(@collection_to_lead.to_s + "_tracks")
          @loaded = true if tracks.empty?
          append tracks.map {|hash| Track.new hash}
          @page += 1
        end
      end

      def log(*args)
        VKAudite::Application.logger.debug "TrackCollection: " + args.join(" ")
      end

      def recent_tracks
        @client.tracks
      end

    end
  end
end

