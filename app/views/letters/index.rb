# frozen_string_literal: true

class Views::Letters::Index < Views::Base
  def initialize(unbatched_letters:, batched_letters: {})
    @unbatched_letters = unbatched_letters
    @batched_letters = batched_letters
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      render Components::Shared::PageHeader.new(title: "Letters") do |header|
        header.with_actions do
          render Primer::Beta::Button.new(tag: :a, href: new_letter_path, scheme: :primary) do |btn|
            btn.with_leading_visual_icon(icon: :plus)
            "Send Letter"
          end
        end
      end

      # Tab navigation
      nav_section

      # Content based on active tab
      if params[:view] == 'batched'
        batched_letters_section
      else
        unbatched_letters_section
      end
    end
  end

  private

  attr_reader :unbatched_letters, :batched_letters

  def nav_section
    nav(style: "margin-bottom: 24px;") do
      ul(style: "display: flex; gap: 16px; list-style: none; margin: 0; padding: 0; border-bottom: 1px solid var(--borderColor-default);") do
        li(style: "margin: 0;") do
          a(
            href: letters_path,
            style: "display: block; padding: 12px; text-decoration: none; color: var(--fgColor-default); border-bottom: 2px solid #{params[:view] == 'batched' ? 'transparent' : 'var(--borderColor-accent)'}; font-weight: #{params[:view] == 'batched' ? 'normal' : '600'};"
          ) { "Unbatched Letters" }
        end
        li(style: "margin: 0;") do
          a(
            href: letters_path(view: 'batched'),
            style: "display: block; padding: 12px; text-decoration: none; color: var(--fgColor-default); border-bottom: 2px solid #{params[:view] == 'batched' ? 'var(--borderColor-accent)' : 'transparent'}; font-weight: #{params[:view] == 'batched' ? '600' : 'normal'};"
          ) { "Batched Letters" }
        end
      end
    end
  end

  def unbatched_letters_section
    div do
      if unbatched_letters.any?
        letters_collection(@unbatched_letters)
        div(style: "margin-top: 24px;") do
          unsafe_raw(paginate(@unbatched_letters).to_s) if @unbatched_letters.respond_to?(:total_pages)
        end
      else
        blankslate("No unbatched letters", "Get started by creating one.")
      end
    end
  end

  def batched_letters_section
    div do
      if batched_letters.any?
        batched_letters.each do |batch, letters|
          batch_group(batch, letters)
        end
      else
        blankslate("No batched letters", "Batches will appear here once they're processed.")
      end
    end
  end

  def batch_group(batch, letters)
    details(style: "margin-bottom: 16px; border: 1px solid var(--borderColor-default); border-radius: 6px; overflow: hidden;") do
      summary(style: "cursor: pointer; display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; background: var(--bgColor-muted); font-weight: 600;") do
        div do
          h3(style: "margin: 0 0 8px 0; font-size: 16px;") { "Batch ##{batch.id}" }
          p(style: "margin: 0; font-size: 13px; color: var(--fgColor-muted); font-weight: normal;") do
            plain "#{pluralize(letters.size, 'letter')} • Created #{time_ago_in_words(batch.created_at)} ago"
          end
          if batch.tags.any?
            div(style: "margin-top: 8px;") do
              render Components::Shared::Tags.new(tags: batch.tags)
            end
          end
        end
      end
      div(style: "padding: 16px;") do
        render partial: "batches/letters_collection", locals: { letters: letters }
      end
    end
  end

  def letters_collection(letters)
    render partial: "batches/letters_collection", locals: { letters: letters }
  end

  def blankslate(title, description)
    render Primer::Beta::Blankslate.new(border: true) do |bs|
      bs.with_visual_icon(icon: :inbox)
      bs.with_heading(tag: :h2) { title }
      bs.with_description { description }
    end
  end
end
