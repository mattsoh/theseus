# frozen_string_literal: true

class Views::APIKeys::New < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(api_key:)
    @api_key = api_key
  end

  def view_template
    div(class: "p-4") do
      div(class: "Box") do
        div(class: "Box-header p-3 border-bottom") do
          h2(class: "m-0 h4") { "New API Key" }
        end

        div(class: "Box-body p-4") do
          form_with model: api_key, url: api_keys_path, local: true do |f|
            render Primer::Alpha::TextField.new(
              name: "api_key[name]",
              label: "Name",
              caption: "Short description (think \"high-seas\")",
              full_width: true,
              autofocus: true,
            )

            fieldset(class: "mt-4 mb-4") do
              legend(class: "f5 color-fg-muted mb-2") { "Permissions" }

              render Primer::Alpha::CheckBox.new(
                name: "api_key[pii]",
                label: "PII Access",
                caption: "Should this key be able to read address data? (probably not!)"
              )

              admin_tool do
                render Primer::Alpha::CheckBox.new(
                  name: "api_key[may_impersonate]",
                  label: "Can Impersonate",
                  caption: "Can this key impersonate other back office users? (don't enable unless needed)"
                )
              end
            end
            render Primer::Beta::Button.new(type: :submit, scheme: :primary) do |btn|
              btn.with_leading_visual_icon(icon: :key)
              "Create API Key"
            end
          end
        end
      end
    end
    div class: "p-4" do
      render Components::Shared::BackButton.new(href: api_keys_path)
    end
  end

  private

  attr_reader :api_key
end
