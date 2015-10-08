require_relative '../ui/view'

module VKAudite
  module Views
    class Splash < UI::View
      CONTENT = %q{

                                  VKAudite

                   WE NEED YOU TO DRAW A LOGO FOR THIS APP
                                                                :)



                                                  Maksim Veynberg 2015

}

    protected

      def left
        (rect.width - lines.map(&:length).max) / 2
      end

      def top
        (rect.height - lines.size) / 2
      end

      def lines
        CONTENT.split("\n")
      end

      def draw
        0.upto(top) {line ''}
        lines.each do |row|
          with_color(:green) do
            line ' ' * left + row
          end
        end
      end

      def refresh
        super
        @window.getch
      end
    end
  end
end

