module SnailMail
  module Components
    class HalfLetterComponent < TemplateBase
      def self.abstract?
        true
      end
      
      def self.template_size
        :half_letter
      end

      def view_template
        render_front
      end

      # Override in subclasses to define the front content
      def render_front
        raise NotImplementedError, "Subclasses must implement render_front"
      end
    end
  end
end
