# frozen_string_literal: true

class Views::APIKeys::Show < Views::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(api_key:)
    @api_key = api_key
  end

  def view_template
    div do
      div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 24px;") do
        div do
          h1(style: "font-size: 24px; font-weight: 600; margin: 0 8px 8px 0; display: inline-block;") { api_key.pretty_name }
          render Primer::Beta::Label.new(scheme: api_key.active? ? :success : :secondary) do
            api_key.active? ? "Active" : "Revoked"
          end
          br
          p(style: "font-size: 12px; color: var(--fgColor-muted, #656d76); margin: 0;") { "Created #{api_key.created_at.strftime('%B %d, %Y')}" }
        end

      end

      # Main card with secret key
      div(style: "background: var(--bgColor-default, #fff); border: 1px solid var(--borderColor-default, #d0d7de); border-radius: 6px; overflow: hidden; margin-bottom: 16px;") do
        # Header
        div(style: "padding: 12px 16px; border-bottom: 1px solid var(--borderColor-default, #d0d7de); background: var(--bgColor-muted, #f6f8fa);") do
          h2(style: "font-size: 14px; font-weight: 600; margin: 0; color: var(--fgColor-default, #24292f);") { "Secret Key" }
        end

        # Body
        div(style: "padding: 16px;") do
          div(style: "display: flex; align-items: center; gap: 12px;") do
            code(
              style: "flex: 1; font-family: monospace; font-size: 13px; padding: 10px 12px; background: var(--bgColor-inset, #f6f8fa); border: 1px solid var(--borderColor-default, #d0d7de); border-radius: 4px; word-break: break-all;",
              data_copy_to_clipboard: api_key.token
            ) { api_key.token }

            render Primer::Beta::IconButton.new(
              icon: :copy,
              aria: { label: "Copy to clipboard" },
              data_copy_to_clipboard: api_key.token
            )
          end

          p(style: "font-size: 12px; color: var(--fgColor-muted, #656d76); margin: 8px 0 0 0; font-style: italic;") { "Keep this secret. Don't share it with anyone." }
        end
      end

      # Permissions panel
      div(style: "background: var(--bgColor-default, #fff); border: 1px solid var(--borderColor-default, #d0d7de); border-radius: 6px; overflow: hidden; margin-bottom: 16px;") do
       # Header
       div(style: "padding: 12px 16px; border-bottom: 1px solid var(--borderColor-default, #d0d7de); background: var(--bgColor-muted, #f6f8fa);") do
         h3(style: "font-size: 14px; font-weight: 600; margin: 0; color: var(--fgColor-default, #24292f);") { "Permissions" }
       end

       div(style: "padding: 0;") do
         pii_bg = api_key.pii ? "var(--bgColor-success-muted, #dafbe1)" : "var(--bgColor-default, #fff)"
         pii_icon = api_key.pii ? "✓" : "✗"
         pii_text = api_key.pii ? "var(--fgColor-success, #1a7f37)" : "var(--fgColor-muted, #656d76)"

         div(style: "padding: 12px 16px; border-bottom: 1px solid var(--borderColor-default, #d0d7de); background: #{pii_bg};") do
           span(style: "color: #{pii_text}; font-weight: 600;") { "#{pii_icon} PII Access" }
         end

         imp_bg = api_key.may_impersonate? ? "var(--bgColor-danger-muted, #ffebe6)" : "var(--bgColor-default, #fff)"
         imp_icon = api_key.may_impersonate? ? "✓" : "✗"
         imp_text = api_key.may_impersonate? ? "var(--fgColor-danger, #ae1c17)" : "var(--fgColor-muted, #656d76)"

         div(style: "padding: 12px 16px; background: #{imp_bg};") do
           span(style: "color: #{imp_text}; font-weight: 600;") { "#{imp_icon} Can Impersonate" }
         end
       end
      end

      # Revoked status (if applicable)
      if api_key.revoked?
        div(style: "background: var(--bgColor-attention-muted, #fff8c5); border: 1px solid var(--borderColor-attention-muted, #ffd480); border-radius: 6px; padding: 12px 16px; margin-bottom: 16px;") do
          p(style: "font-size: 12px; color: var(--fgColor-attention, #9a6700); margin: 0;") do
            strong { "Revoked on #{api_key.revoked_at.strftime('%B %d, %Y at %l:%M %p')}" }
          end
        end
      end

      # Actions
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
