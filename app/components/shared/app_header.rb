# frozen_string_literal: true

class Components::Shared::AppHeader < Components::Base
  include Phlex::Rails::Helpers::LinkTo

  register_value_helper :request

  def view_template
    header(class: "app-header", style: "display: flex; align-items: center; justify-content: space-between;") do
      div(style: "display: flex; align-items: center; gap: 1rem;") do
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

      if current_user
        render(Primer::Alpha::ActionMenu.new(anchor_align: :end)) do |menu|
          menu.with_show_button(scheme: :invisible) do |btn|
            btn.with_leading_visual_icon(icon: :person)
            plain current_user.username
            plain " [IMPERSONATING]" if session[:impersonator_user_id]
          end
          
          if session[:impersonator_user_id]
            menu.with_item(label: "Stop impersonating", href: stop_impersonating_path)
            menu.with_divider
          end
          
          menu.with_item(label: "Log out", href: signout_path, data: {method: :delete}) do |item|
            item.with_leading_visual_icon(icon: :"sign-out")
          end
        end
      end
    end
  end

  private

  def session
    Rails.application.env_config["rack.session"] || {}
  end
end
