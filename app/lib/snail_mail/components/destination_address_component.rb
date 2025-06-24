module SnailMail
  module Components
    class DestinationAddressComponent < BaseComponent
      def initialize(letter:, x:, y:, width:, height:, **options)
        @x = x
        @y = y
        @width = width
        @height = height
        super(letter: letter, **options)
      end

      def view_template
        default_options = {
          font: "f25",
          size: 11,
          align: :left,
          valign: :center,
          overflow: :shrink_to_fit,
          min_font_size: 6,
          disable_wrap_by_char: true,
        }

        opts = default_options.merge(options)
        font_name = opts.delete(:font)
        stroke_box = opts.delete(:dbg_stroke)

        font(font_name) do
          text_box(
            letter.address.snailify(letter.return_address.country),
            at: [@x, @y],
            width: @width,
            height: @height,
            **opts,
          )
        end

        if stroke_box
          stroke { rectangle([@x, @y], @width, @height) }
        end
      end
    end
  end
end
