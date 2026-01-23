# frozen_string_literal: true

class Views::APIKeys::Index < Views::Base
  def initialize(api_keys:)
    @api_keys = api_keys
  end

  def view_template
    div(class: "d-flex flex-justify-between flex-items-center mb-3") do
      render Primer::Beta::Heading.new(tag: :h1) { "API Keys" }
      render Primer::Beta::Button.new(tag: :a, href: new_api_key_path, scheme: :primary) do |btn|
        btn.with_leading_visual_icon(icon: :key)
        "Visit the locksmith!"
      end
    end

    if api_keys.any?
      render Primer::Beta::BorderBox.new do |box|
        api_keys.each do |key|
          box.with_row do
            a(href: api_key_path(key), class: "d-block Link--muted no-underline") do
              div(class: "d-flex flex-justify-between flex-items-start") do
                div(class: "flex-1") do
                  div(class: "d-flex flex-items-center mb-1") do
                    span(class: "text-bold mr-2") { key.pretty_name }
                    render Primer::Beta::Label.new(scheme: key.active? ? :success : :secondary) do
                      key.active? ? "Active" : "Revoked"
                    end
                  end
                  span(class: "f6 color-fg-muted") { "Acts as: #{key.user.username}" }
                end

                div(class: "d-flex flex-items-center") do
                  render(Primer::Beta::Label.new(scheme: :attention, mr: 2)) { "PII" } if key.pii
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

  private

  attr_reader :api_keys
end
