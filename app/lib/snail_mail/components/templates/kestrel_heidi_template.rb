module SnailMail
  module Components
    module Templates
      class KestrelHeidiTemplate < TemplateBase
      def self.template_name
        "kestrel's heidi template!"
      end

      def self.show_on_single?
        true
      end

      def view_template
        image(
          image_path("kestrel-mail-heidi.png"),
          at: [107, 216],
          width: 305,
        )

        render_return_address(10, 278, 190, 90, size: 14)

        render_destination_address(
          126,
          201,
          266,
          67,
          size: 16,
          valign: :center,
          align: :left
        )

        render_imb(124, 120, 200)
        render_qr_code(7, 72 + 7, 72)
        render_postage
      end
      end
    end
  end
end
