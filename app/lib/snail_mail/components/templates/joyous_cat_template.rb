module SnailMail
  module Components
    module Templates
      class JoyousCatTemplate < TemplateBase
      def self.template_name
        "Joyous Cat :3"
      end

      def self.show_on_single?
        true
      end

      def view_template
        render_speech_bubble(
          bubble_position: [111, 189],
          bubble_width: 306,
          bubble_height: 122,
          bubble_radius: 10,
          tail_x: 208,
          tail_y: 74,
          tail_width: 106.4,
          line_width: 3
        )

        image(
          image_path("acon-joyous-cat.png"),
          at: [208, 74],
          width: 106.4,
        )

        render_return_address(10, 270, 130, 70)

        render_destination_address(
          134,
          173,
          266,
          67,
          size: 16,
          valign: :center,
          align: :left
        )

        render_imb(131, 100, 266)
        render_qr_code(7, 72 + 7, 72)
        render_postage
      end
      end
    end
  end
end
