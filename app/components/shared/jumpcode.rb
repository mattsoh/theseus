# frozen_string_literal: true

class Components::Shared::Jumpcode < Components::Base
  def initialize(code: nil, path: nil)
    @code = code || Shortcodes.code_for(path)
  end

  def view_template
    return unless @code

    span(style: "display: inline-flex; align-items: center; gap: 4px; vertical-align: middle;") do
      span(
        style: "display: inline-flex; align-items: center; gap: 4px; font-size: 11px; font-weight: 600; font-family: var(--fontStack-monospace); padding: 2px 8px; border-radius: 6px; background: var(--bgColor-muted); color: var(--fgColor-muted); letter-spacing: 0.5px; cursor: pointer; user-select: none;",
        title: "Press ⌘K and type #{@code}",
        onclick: safe("window.openKbar?.()")
      ) do
        span(style: "font-size: 10px; opacity: 0.6;") { "⌘K" }
        plain @code
      end

      render_help_button
    end
  end

  private

  def render_help_button
    render(Primer::Alpha::Dialog.new(
      title: "what's a jumpcode?",
      size: :small
    )) do |dialog|
      dialog.with_show_button(
        scheme: :invisible,
        size: :small,
        "aria-label": "What's a jumpcode?"
      ) do
        span(style: "font-size: 11px; color: var(--fgColor-muted); cursor: pointer; opacity: 0.5;") { "?" }
      end

      dialog.with_body do
        cs = "font-size: 12px; padding: 2px 6px; border-radius: 4px; background: var(--bgColor-muted); font-family: var(--fontStack-monospace);"
        div(style: "font-size: 14px; line-height: 1.6; color: var(--fgColor-default);") do
          p(style: "margin: 0 0 12px 0;") do
            plain "you've probably seen the "
            code(style: cs) { "⌘K #{@code}" }
            plain " badges around — those are jumpcodes. hit "
            code(style: cs) { "⌘K" }
            plain ", type the code, go."
          end

          p(style: "margin: 0 0 12px 0;") do
            plain "letter pages start with L ("
            code(style: cs) { "MAIL" }
            plain ", "
            code(style: cs) { "SCAN" }
            plain ", "
            code(style: cs) { "LBAT" }
            plain "), warehouse starts with W ("
            code(style: cs) { "WORD" }
            plain ", "
            code(style: cs) { "SKUS" }
            plain "). you'll pick them up fast."
          end

          p(style: "margin: 0; color: var(--fgColor-muted); font-size: 13px;") do
            plain "the palette also does search — "
            code(style: cs) { "?l" }
            plain " for letters, "
            code(style: cs) { "?w" }
            plain " for orders — and you can paste IDs like "
            code(style: cs) { "ltr!abc123" }
            plain " to jump to them."
          end
        end
      end
    end
  end
end
