module VKAudite
  module Models
    class Track
      def initialize(hash)
        @hash = hash
      end

      def artist
        @hash[:artist]
      end

      def title
        @hash[:title]
      end

      def url
        @hash[:url]
      end

      def duration
        @hash[:duration]*1000
      end
    end
  end
end
