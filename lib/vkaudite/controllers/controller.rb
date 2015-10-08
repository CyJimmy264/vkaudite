require_relative '../events'

module VKAudite
  module Controllers
    class Controller
      attr_reader :events

      def initialize(view)
        @view = view
        @events = Events.new
      end

      def render
        @view.render
      end
    end
  end
end
