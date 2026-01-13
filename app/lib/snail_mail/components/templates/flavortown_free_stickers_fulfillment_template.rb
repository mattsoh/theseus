# frozen_string_literal: true

module SnailMail
  module Components
    module Templates
      class FlavortownFreeStickersFulfillmentTemplate < TemplateBase
        def self.template_name
          "flavortown free stickers fulfillment"
        end

        def self.template_description
          "Flavortown Free Stickers Fulfillment"
        end

        def self.show_on_single?
          true
        end

        def view_template
          # Add your template content here

          # Example: Add an image
          image(
            image_path("flavortown/domain.png"),
            at: [ -2.5, 295 ],
            width: 443,
          )

          # Render return address
          render_return_address(10, 278, 260, 70, size: 8)

          # Render destination address
          render_destination_address(
            165,
            140,
            230,
            71,
            size: 14,
            valign: :bottom,
            align: :left
          )

          # Render postal elements
          render_imb(240, 24, 183)
          render_qr_code(5, 115, 50)
          render_letter_id(10, 65, 10, rotate: 90)
          render_postage
        end

      end
    end
  end
end
