# frozen_string_literal: true

class Components::Shared::Tags < Components::Base
  def initialize(tags:)
    @tags = tags
  end

  def view_template
    return if tags.blank?

    div(style: "display: flex; flex-wrap: wrap; gap: 4px; align-items: center;") do
      tags.compact_blank.each do |tag|
        a(href: tag_stats_path(tag), style: "text-decoration: none;") do
          render Primer::Beta::Label.new(scheme: :accent, size: :medium) { tag }
        end
      end
    end
  end

  private

  attr_reader :tags
end
