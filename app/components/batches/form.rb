# frozen_string_literal: true

class Components::Batches::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(batch:)
    @batch = batch
  end

  def view_template
    if batch.errors.any?
      div(style: "background: var(--bgColor-danger-muted, #ffebe6); border: 1px solid var(--borderColor-danger-muted, #ff8182); border-radius: 6px; padding: 12px 16px; margin-bottom: 16px;") do
        p(style: "font-size: 14px; font-weight: 600; color: var(--fgColor-danger, #ae1c17); margin: 0 0 8px 0;") do
          plain "#{batch.errors.count} error(s) prohibited this batch from being saved:"
        end
        ul(style: "margin: 0; padding-left: 20px; color: var(--fgColor-danger, #ae1c17); font-size: 13px;") do
          batch.errors.full_messages.each do |message|
            li { message }
          end
        end
      end
    end

    form_with model: batch, local: true do |f|
      div(style: "display: flex; flex-direction: column; gap: 16px;") do
        # File input
        div do
          label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 6px; color: var(--fgColor-default, #24292f);") do
            plain "CSV File"
            span(style: "color: var(--fgColor-danger, #ae1c17); margin-left: 2px;") { "*" }
          end
          p(style: "font-size: 13px; color: var(--fgColor-muted); margin: 0 0 6px 0;") do
            plain "Upload a CSV file with addresses to process"
          end
          input(
            type: :file,
            name: "batch[csv]",
            accept: "text/csv",
            required: true,
            style: "display: block; width: 100%; padding: 8px; font-size: 14px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default);"
          )
        end

        div(style: "padding-top: 8px;") do
          render Primer::Beta::Button.new(type: :submit, scheme: :primary) do |btn|
            btn.with_leading_visual_icon(icon: :upload)
            "Upload CSV"
          end
        end
      end
    end
  end

  private

  attr_reader :batch
end
