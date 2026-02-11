# frozen_string_literal: true

class Views::Batches::Index < Views::Base
  def initialize(batches:)
    @batches = batches
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      render Components::Shared::PageHeader.new(title: "Batches", subtitle: "#{@batches.count} batches") do |header|
        header.with_actions do
          render Primer::Beta::Button.new(tag: :a, href: new_batch_path, scheme: :primary) do |btn|
            btn.with_leading_visual_icon(icon: :plus)
            "Upload CSV"
          end
        end
      end

      if @batches.any?
        batches_grid
      else
        blankslate
      end
    end
  end

  private

  attr_reader :batches

  def batches_grid
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
      # Left side: batch info
      div(style: "flex: 1; min-width: 0;") do
        div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 8px;") do
          h3(style: "font-size: 16px; font-weight: 600; margin: 0;") do
            "#{batch.type.split('::').first.titleize} Batch ##{batch.id}"
          end
          render Components::Shared::StatusBadge.new(status: batch.aasm.current_state, type: :batch)
        end

        # Tags
        if batch.tags.any?
          div(style: "margin-bottom: 8px;") do
            render Components::Shared::Tags.new(tags: batch.tags)
          end
        end

        # Metadata
        div(style: "display: flex; gap: 16px; font-size: 13px; color: var(--fgColor-muted);") do
          span do
            strong { "Type: " }
            plain batch.type.split('::').first.titleize
          end
          span do
            strong { "Created: " }
            plain time_ago_in_words(batch.created_at)
            plain " ago"
          end
          span do
            strong { "Addresses: " }
            plain batch.addresses.count
          end
        end
      end

      # Right side: action button
      div(style: "display: flex; flex-shrink: 0;") do
        render Primer::Beta::Button.new(tag: :a, href: batch_path(batch), scheme: :secondary, size: :small) do |btn|
          btn.with_trailing_visual_icon(icon: :arrow_right)
          "View Details"
        end
      end
    end
  end

  def blankslate
    render Primer::Beta::Blankslate.new(border: true) do |bs|
      bs.with_visual_icon(icon: :inbox)
      bs.with_heading(tag: :h2) { "No batches yet" }
      bs.with_description { "Get started by uploading a CSV file." }
      bs.with_primary_action(href: new_batch_path) do
        render Primer::Beta::Button.new(scheme: :primary) do |btn|
          btn.with_leading_visual_icon(icon: :plus)
          "Upload CSV"
        end
      end
    end
  end
end
