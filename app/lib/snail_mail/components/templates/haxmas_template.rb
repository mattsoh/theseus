# frozen_string_literal: true

module SnailMail
  module Components
    module Templates
      class HaxmasTemplate < TemplateBase
        def self.template_name
          "Haxmas"
        end

        def self.show_on_single?
          true
        end

        def view_template
          image(
            image_path("haxmas.png"),
            at: [0, 288],
            width: 432,
          )

          render_return_address(85, 250, 120, 55, size: 7, font: "f25")
          render_destination_address(190, 180, 150, 80, size: 12, valign: :center, align: :left)

          render_imb(190, 95, 150)
          render_qr_code(85, 115, 45)
          render_letter_id(3, 15, 6, rotate: 90)
          render_postage
        end
      end
    end
  end
end