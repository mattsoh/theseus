# frozen_string_literal: true

class Views::Letters::New < Views::Base

  def initialize(letter:)
    @letter = letter
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 24px;") do
        render Primer::Beta::Button.new(tag: :a, href: letters_path, scheme: :invisible, size: :small) do |btn|
          btn.with_leading_visual_icon(icon: :"arrow-left")
          "Back"
        end
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "New Letter" }
      end

      div(style: "display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: start;") do
        div do
          render Components::Letters::Form.new(letter: @letter)
        end

        div(style: "position: sticky; top: 24px;") do
          postage_rates_card
          size_limits_card
        end
      end
    end
  end

  private

  def postage_rates_card
    render Primer::Beta::BorderBox.new(mb: 3) do |box|
      box.with_header do |header|
        header.with_title(tag: :h3) { "Postage Rates" }
      end
      box.with_body do
        p(style: "font-size: 12px; font-weight: 600; margin-bottom: 4px;") { "Letters (stamps)" }
        table(style: "font-size: 12px; margin-bottom: 16px; border-collapse: collapse;") do
          USPS::PricingEngine::US_STAMP_LETTER_RATES.first(4).each do |oz, price|
            tr do
              td(style: "color: var(--fgColor-muted); padding-right: 12px;") { oz == oz.to_i ? "#{oz.to_i} oz" : "#{oz} oz" }
              td(style: "font-family: var(--fontStack-monospace);") { helpers.number_to_currency(price) }
            end
          end
        end

        p(style: "font-size: 12px; font-weight: 600; margin-bottom: 4px;") { "Flats (stamps)" }
        table(style: "font-size: 12px; margin-bottom: 16px; border-collapse: collapse;") do
          USPS::PricingEngine::US_STAMP_FLAT_RATES.first(3).each do |oz, price|
            tr do
              td(style: "color: var(--fgColor-muted); padding-right: 12px;") { oz == oz.to_i ? "#{oz.to_i} oz" : "#{oz} oz" }
              td(style: "font-family: var(--fontStack-monospace);") { helpers.number_to_currency(price) }
            end
          end
        end

        p(style: "font-size: 12px; color: var(--fgColor-muted); margin-bottom: 4px;") do
          plain "Non-machinable surcharge: +"
          plain helpers.number_to_currency(USPS::PricingEngine::FCMI_NON_MACHINABLE_SURCHARGE)
        end
        p(style: "font-size: 12px; color: var(--fgColor-muted);") { "Indicia is slightly cheaper for standard letters." }
      end
    end
  end

  def size_limits_card
    render Primer::Beta::BorderBox.new do |box|
      box.with_header do |header|
        header.with_title(tag: :h3) { "Size Limits" }
      end
      box.with_body do
        dl(style: "font-size: 12px;") do
          dt(style: "font-weight: 600;") { "Letter" }
          dd(style: "color: var(--fgColor-muted); margin-bottom: 8px;") do
            raw "Up to 11.5 &times; 6.125 in, 3.5 oz"
          end
          dt(style: "font-weight: 600;") { "Flat" }
          dd(style: "color: var(--fgColor-muted);") do
            raw "Up to 15 &times; 12 in, 13 oz"
          end
        end
      end
    end
  end
end
