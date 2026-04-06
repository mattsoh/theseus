# frozen_string_literal: true

class Views::Warehouse::Batches::Process < Views::Base
  include Phlex::Rails::Helpers::NumberToCurrency

  def initialize(batch:)
    @batch = batch
  end

  def view_template
    div(style: "max-width: 800px; margin: 0 auto; padding: 24px;") do
      div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 24px;") do
        render Primer::Beta::Button.new(tag: :a, href: warehouse_batch_path(@batch), scheme: :invisible, size: :small) do |btn|
          btn.with_leading_visual_icon(icon: :"arrow-left")
          "Back to batch"
        end
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "Process Warehouse Batch ##{@batch.id}" }
      end

      render Primer::Alpha::Banner.new(scheme: :default, mb: 4) do
        "This will create #{helpers.pluralize(@batch.addresses.count, 'warehouse order')}."
      end

      # Line Items
      render Primer::Beta::BorderBox.new(mb: 4) do |box|
        box.with_header do |header|
          header.with_title(tag: :h3) { "Template: #{@batch.warehouse_template.name}" }
        end
        @batch.warehouse_template.line_items.each do |line_item|
          box.with_row do
            div(style: "display: flex; justify-content: space-between;") do
              span { "#{line_item.quantity}x #{line_item.sku.name}" }
            end
          end
        end
      end

      # Cost Breakdown
      render Primer::Beta::BorderBox.new(mb: 4) do |box|
        box.with_header do |header|
          header.with_title(tag: :h3) { "Cost Breakdown" }
        end
        box.with_body do
          dl(style: "display: grid; grid-template-columns: auto 1fr; gap: 8px 16px; margin: 0;") do
            dt(style: "font-size: 14px; color: var(--fgColor-muted);") { "Contents" }
            dd(style: "margin: 0; font-size: 14px;") { number_to_currency(@batch.contents_cost) }

            dt(style: "font-size: 14px; color: var(--fgColor-muted);") { "Labor" }
            dd(style: "margin: 0; font-size: 14px;") { number_to_currency(@batch.labor_cost) }

            dt(style: "font-size: 14px; color: var(--fgColor-muted);") { "Postage" }
            dd(style: "margin: 0; font-size: 14px; color: var(--fgColor-muted);") { "TBD" }

            dt(style: "font-size: 14px; font-weight: 600;") { "Total (est.)" }
            dd(style: "margin: 0; font-size: 14px; font-weight: 600;") { "~#{number_to_currency(@batch.total_cost)}" }
          end
        end
      end

      # Submit
      div(class: "d-flex gap-2") do
        render Primer::Beta::Button.new(tag: :a, href: warehouse_batch_path(@batch), scheme: :secondary) do
          "Cancel"
        end
        form(method: :post, action: process_batch_warehouse_batch_path(@batch), style: "display: inline;") do
          input(type: :hidden, name: :authenticity_token, value: form_authenticity_token)
          render Primer::Beta::Button.new(type: :submit, scheme: :primary) do |btn|
            btn.with_leading_visual_icon(icon: :play)
            "do it!"
          end
        end
      end
    end
  end
end
