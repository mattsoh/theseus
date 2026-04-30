# frozen_string_literal: true

class Views::APIKeys::Index < Views::Base
  def initialize(api_keys:)
    @api_keys = api_keys
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      div(style: "display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;") do
        div(style: "display: flex; align-items: center; gap: 8px;") do
          h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "API Keys" }
          render Components::Shared::Jumpcode.new(path: api_keys_path)
        end
        render Primer::Beta::Button.new(tag: :a, href: new_api_key_path, scheme: :primary) do |btn|
          btn.with_leading_visual_icon(icon: :key)
          "Visit the locksmith!"
        end
      end

      if api_keys.any?
        render Primer::Beta::BorderBox.new do |box|
          api_keys.each do |key|
            box.with_row do
              a(href: api_key_path(key), style: "display: block; color: inherit; text-decoration: none;") do
                div(style: "display: flex; justify-content: space-between; align-items: flex-start;") do
                  div(style: "flex: 1;") do
                    div(style: "display: flex; align-items: center; gap: 8px; margin-bottom: 4px;") do
                      span(style: "font-weight: 600;") { key.pretty_name }
                      render Primer::Beta::Label.new(scheme: key.active? ? :success : :secondary) do
                        key.active? ? "Active" : "Revoked"
                      end
                    end
                    span(style: "font-size: 13px; color: var(--fgColor-muted);") { "Acts as: #{key.user.username}" }
                  end

                  div(style: "display: flex; align-items: center; gap: 8px;") do
                    render(Primer::Beta::Label.new(scheme: :attention)) { "PII" } if key.pii
                    render(Primer::Beta::Label.new(scheme: :danger)) { "Impersonate" } if key.may_impersonate?
                  end
                end
              end
            end
          end
        end
      else
        render Primer::Beta::Blankslate.new(border: true) do |bs|
          bs.with_visual_icon(icon: :key)
          bs.with_heading(tag: :h2) { "No API keys yet" }
        end
      end
    end
  end

  private

  attr_reader :api_keys
end
