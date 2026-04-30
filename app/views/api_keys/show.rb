# frozen_string_literal: true

class Views::APIKeys::Show < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(api_key:)
    @api_key = api_key
  end

  def view_template
    div(style: "max-width: 800px; margin: 0 auto; padding: 24px;") do
      div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 24px;") do
        div do
          div(style: "display: flex; align-items: center; gap: 8px; margin-bottom: 4px;") do
            h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { api_key.pretty_name }
            render Primer::Beta::Label.new(scheme: api_key.active? ? :success : :secondary) do
              api_key.active? ? "Active" : "Revoked"
            end
          end
          p(style: "font-size: 13px; color: var(--fgColor-muted); margin: 0;") { "Created #{api_key.created_at.strftime('%B %d, %Y')}" }
        end
      end

      render Primer::Beta::BorderBox.new(mb: 3) do |box|
        box.with_header { "Secret Key" }
        box.with_body do
          div(style: "display: flex; align-items: center; gap: 12px;") do
            code(
              style: "flex: 1; font-family: var(--fontStack-monospace); font-size: 13px; padding: 10px 12px; background: var(--bgColor-inset); border: 1px solid var(--borderColor-default); border-radius: 4px; word-break: break-all;",
              data_copy_to_clipboard: api_key.token
            ) { api_key.token }

            render Primer::Beta::IconButton.new(
              icon: :copy,
              aria: { label: "Copy to clipboard" },
              data_copy_to_clipboard: api_key.token
            )
          end
          p(style: "font-size: 12px; color: var(--fgColor-muted); margin: 8px 0 0 0; font-style: italic;") { "Keep this secret. Don't share it with anyone." }
        end
      end

      render Primer::Beta::BorderBox.new(mb: 3) do |box|
        box.with_header { "Permissions" }
        box.with_row do
          pii_color = api_key.pii ? "var(--fgColor-success)" : "var(--fgColor-muted)"
          div(style: "display: flex; align-items: center; gap: 8px;#{"background: var(--bgColor-success-muted); margin: -8px -16px; padding: 8px 16px;" if api_key.pii}") do
            span(style: "color: #{pii_color}; font-weight: 600;") { api_key.pii ? "✓" : "✗" }
            span(style: "font-weight: 500;") { "PII Access" }
          end
        end
        box.with_row do
          imp_color = api_key.may_impersonate? ? "var(--fgColor-danger)" : "var(--fgColor-muted)"
          div(style: "display: flex; align-items: center; gap: 8px;#{"background: var(--bgColor-danger-muted); margin: -8px -16px; padding: 8px 16px;" if api_key.may_impersonate?}") do
            span(style: "color: #{imp_color}; font-weight: 600;") { api_key.may_impersonate? ? "✓" : "✗" }
            span(style: "font-weight: 500;") { "Can Impersonate" }
          end
        end
      end

      if api_key.revoked?
        render Primer::Beta::Flash.new(scheme: :warning, mb: 3) do
          strong { "Revoked on #{api_key.revoked_at.strftime('%B %d, %Y at %l:%M %p')}" }
        end
      end

      div(style: "display: flex; gap: 12px;") do
        render Components::Shared::BackButton.new(href: api_keys_path)
        if api_key.active?
          render_revoke_dialog
        end
      end
    end
  end

  private

  attr_reader :api_key

  def render_revoke_dialog
    render Primer::Alpha::Dialog.new(
      title: "Revoking #{api_key.pretty_name}...",
      subtitle: "That which thou canst not undo.",
      size: :large,
      id: "revoke-dialog"
    ) do |dialog|
      dialog.with_show_button(scheme: :danger) do |btn|
        btn.with_leading_visual_icon(icon: :x)
        plain "Revoke Key"
      end

      form_with url: revoke_api_key_path(api_key), method: :post, local: true do |f|
        render(Primer::Alpha::Dialog::Body.new) do
          render(Primer::Alpha::Banner.new(icon: :alert, scheme: :danger, description: "Are you sure you want to revoke this key? Everything that relies on it will unceremoniously break.")) { "This is irreversible and painful!" }
        end

        render(Primer::Alpha::Dialog::Footer.new(show_divider: true)) do
          render(Primer::Beta::Button.new(data: { "close-dialog-id": "revoke-dialog" })) { "Cancel" }
          render(Primer::Beta::Button.new(scheme: :danger, type: :submit)) { "Do it. Pull the trigger. I can't even stand to look at it anymore." }
        end
      end
    end
  end
end
