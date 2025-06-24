module SnailMail
  module Components
    class QRCodeComponent < BaseComponent
      def initialize(letter:, x:, y:, size: 70, **options)
        @x = x
        @y = y
        @size = size
        super(letter: letter, **options)
      end

      def view_template
        return unless options[:include_qr_code]
        
        SnailMail::QRCodeGenerator.generate_qr_code(self, "https://hack.club/#{letter.public_id}", @x, @y, @size)
        
        font("f25") do
          text_box("scan this so we know you got it!", at: [@x + 3, @y + 22], width: 54, size: 6.4)
        end
      end
    end
  end
end
