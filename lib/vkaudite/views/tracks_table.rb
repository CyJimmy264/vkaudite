require_relative '../ui/table'

module VKAudite
  module Views
    class TracksTable < UI::Table
      def initialize(*args)
        super
        self.header = ["Artist", "Title", "URL"]
        self.keys   = [:artist, :title, :url]
      end
    end
  end
end
