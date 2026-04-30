# frozen_string_literal: true

class Views::Letters::Edit < Views::Base
  def initialize(letter:)
    @letter = letter
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 24px;") do
        render Primer::Beta::Button.new(tag: :a, href: letter_path(@letter), scheme: :invisible, size: :small) do |btn|
          btn.with_leading_visual_icon(icon: :"arrow-left")
          "Back"
        end
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "Editing letter" }
      end

      div(style: "display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: start;") do
        div do
          render Components::Letters::Form.new(letter: @letter)
        end

        div(style: "position: sticky; top: 24px;") do
          letter_info_card
        end
      end
    end
  end

  private

  def letter_info_card
    render Primer::Beta::BorderBox.new do |box|
      box.with_header do |header|
        header.with_title(tag: :h3) { "Letter Info" }
      end
      box.with_body do
        dl do
          dt(style: "color: var(--fgColor-muted); font-size: 12px;") { "ID" }
          dd(style: "margin-bottom: 16px;") do
            code { @letter.public_id }
          end

          dt(style: "color: var(--fgColor-muted); font-size: 12px;") { "Status" }
          dd(style: "margin-bottom: 16px;") do
            render Components::Shared::StatusBadge.new(status: @letter.aasm_state, type: :letter)
          end

          dt(style: "color: var(--fgColor-muted); font-size: 12px;") { "Created" }
          dd(style: "margin-bottom: 16px;") { @letter.created_at.strftime("%b %-d, %Y") }

          dt(style: "color: var(--fgColor-muted); font-size: 12px;") { "Origin" }
          dd { @letter.origin_label }
        end
      end
    end
  end
end
