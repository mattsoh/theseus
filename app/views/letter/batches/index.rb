# frozen_string_literal: true

class Views::Letter::Batches::Index < Views::Base
  include Phlex::Rails::Helpers::TimeAgoInWords

  def initialize(batches:)
    @batches = batches
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      render Components::Shared::PageHeader.new(
        title: "Letter Batches",
        subtitle: "#{@batches.count} batches"
      ) do |header|
        header.with_actions do
          render Primer::Beta::Button.new(tag: :a, href: new_letter_batch_path, scheme: :primary) do |btn|
            btn.with_leading_visual_icon(icon: :plus)
            "New Batch"
          end
        end
      end

      if @batches.any?
        batches_list
      else
        blankslate
      end
    end
  end

  private

  def batches_list
    render Primer::Beta::BorderBox.new(padding: :condensed) do |box|
      @batches.each do |batch|
        box.with_row do
          batch_row(batch)
        end
      end
    end
  end

  def batch_row(batch)
    div(style: "display: flex; justify-content: space-between; align-items: flex-start; gap: 16px;") do
      div(style: "flex: 1; min-width: 0;") do
        div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 8px;") do
          h3(style: "font-size: 16px; font-weight: 600; margin: 0;") do
            a(href: letter_batch_path(batch), style: "color: inherit; text-decoration: none;") do
              "Letter Batch ##{batch.id}"
            end
          end
          render Components::Shared::StatusBadge.new(status: batch.aasm.current_state, type: :batch)
        end

        if batch.tags.any?
          div(style: "margin-bottom: 8px;") do
            render Components::Shared::Tags.new(tags: batch.tags)
          end
        end

        div(style: "display: flex; gap: 16px; font-size: 13px; color: var(--fgColor-muted);") do
          span do
            strong { "Addresses: " }
            plain batch.addresses.count.to_s
          end
          span do
            strong { "Letters: " }
            plain batch.letters.count.to_s
          end
          span do
            plain time_ago_in_words(batch.created_at)
            plain " ago"
          end
        end
      end

      div(style: "display: flex; flex-shrink: 0;") do
        render Primer::Beta::Button.new(tag: :a, href: letter_batch_path(batch), scheme: :secondary, size: :small) do |btn|
          btn.with_trailing_visual_icon(icon: :"arrow-right")
          "View"
        end
      end
    end
  end

  def blankslate
    render Primer::Beta::Blankslate.new(border: true) do |bs|
      bs.with_visual_icon(icon: :inbox)
      bs.with_heading(tag: :h2) { "No letter batches yet" }
      bs.with_description { "Create a batch to send letters to multiple addresses at once." }
      bs.with_primary_action(href: new_letter_batch_path) do
        render Primer::Beta::Button.new(scheme: :primary) do |btn|
          btn.with_leading_visual_icon(icon: :plus)
          "New Batch"
        end
      end
    end
  end
end
