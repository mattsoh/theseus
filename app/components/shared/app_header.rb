# frozen_string_literal: true

class Components::Shared::AppHeader < Components::Base
  def view_template
    header(class: "app-header") do
      render(Primer::Alpha::Dialog.new(
        title: "Navigation",
        position: :left,
        position_narrow: :fullscreen,
        size: :small,
        visually_hide_title: true
      )) do |dialog|
        dialog.with_show_button(icon: :"three-bars", "aria-label": "Menu", scheme: :default)
        dialog.with_body(padding: :none) do
          render Components::Shared::Nav.new
        end
      end

      span(class: "app-header-brand") do
        plain "Theseus"
        sup(class: "app-header-env-badge") { "dev" } if Rails.env.development?
      end
    end
  end
end
