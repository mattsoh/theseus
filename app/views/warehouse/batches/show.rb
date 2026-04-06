# frozen_string_literal: true

class Views::Warehouse::Batches::Show < Views::Base
  include Phlex::Rails::Helpers::TimeAgoInWords
  include Phlex::Rails::Helpers::NumberToCurrency

  def initialize(batch:)
    @batch = batch
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      render Components::Shared::PageHeader.new(
        title: "Warehouse Batch ##{@batch.id}",
        subtitle: "#{helpers.pluralize(@batch.addresses.count, 'address')}"
      ) do |header|
        header.with_actions do
          render Primer::Beta::Button.new(tag: :a, href: warehouse_batches_path, scheme: :secondary, size: :small) do |btn|
            btn.with_leading_visual_icon(icon: :"arrow-left")
            "Back"
          end
          render Primer::Beta::Button.new(tag: :a, href: edit_warehouse_batch_path(@batch), scheme: :secondary, size: :small) do |btn|
            btn.with_leading_visual_icon(icon: :pencil)
            "Edit"
          end
          if @batch.fields_mapped?
            render Primer::Beta::Button.new(tag: :a, href: process_confirm_warehouse_batch_path(@batch), scheme: :primary, size: :small) do |btn|
              btn.with_leading_visual_icon(icon: :play)
              "Process"
            end
          end
        end
      end

      batch_details
      orders_section if @batch.orders.any?
      addresses_section if @batch.addresses.any?
      danger_zone
    end
  end

  private

  def batch_details
    render Primer::Beta::BorderBox.new(mb: 4) do |box|
      box.with_header do |header|
        header.with_title(tag: :h3) { "Details" }
      end
      box.with_body do
        dl(style: "display: grid; grid-template-columns: auto 1fr; gap: 8px 16px; margin: 0;") do
          detail_row("Status") { render Components::Shared::StatusBadge.new(status: @batch.aasm.current_state, type: :batch) }
          detail_row("Template") { plain @batch.warehouse_template&.name || "—" }
          detail_row("Title") { plain @batch.warehouse_user_facing_title || "—" }
          detail_row("Created") { plain "#{time_ago_in_words(@batch.created_at)} ago" }

          if @batch.tags.any?
            detail_row("Tags") { render Components::Shared::Tags.new(tags: @batch.tags) }
          end

          if @batch.processed?
            detail_row("Contents Cost") { plain number_to_currency(@batch.contents_cost) }
            detail_row("Labor Cost") { plain number_to_currency(@batch.labor_cost) }
            detail_row("Total Cost") { strong { number_to_currency(@batch.total_cost) } }
          end
        end
      end
    end
  end

  def detail_row(label)
    dt(style: "font-size: 13px; color: var(--fgColor-muted); font-weight: 600;") { label }
    dd(style: "margin: 0; font-size: 14px;") { yield }
  end

  def orders_section
    details(style: "margin-bottom: 16px;") do
      summary(style: "cursor: pointer; padding: 12px; background: var(--bgColor-muted); border: 1px solid var(--borderColor-default); border-radius: 6px; font-weight: 600;") do
        "Orders (#{@batch.orders.count})"
      end
      div(style: "border: 1px solid var(--borderColor-default); border-top: none; border-radius: 0 0 6px 6px; overflow-x: auto;") do
        table(style: "width: 100%; border-collapse: collapse; font-size: 13px;") do
          thead do
            tr do
              %w[ID Recipient Status].each do |h|
                th(style: "text-align: left; padding: 8px 12px; background: var(--bgColor-muted); font-weight: 600; border-bottom: 1px solid var(--borderColor-default);") { h }
              end
            end
          end
          tbody do
            @batch.orders.includes(:address).limit(100).each do |order|
              tr do
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") do
                  a(href: warehouse_order_path(order)) { order.public_id }
                end
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") do
                  plain "#{order.address&.first_name} #{order.address&.last_name}"
                end
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") do
                  render Components::Shared::StatusBadge.new(status: order.aasm_state, type: :warehouse_order)
                end
              end
            end
          end
        end
      end
    end
  end

  def addresses_section
    details(style: "margin-bottom: 16px;") do
      summary(style: "cursor: pointer; padding: 12px; background: var(--bgColor-muted); border: 1px solid var(--borderColor-default); border-radius: 6px; font-weight: 600;") do
        "Addresses (#{@batch.addresses.count})"
      end
      div(style: "border: 1px solid var(--borderColor-default); border-top: none; border-radius: 0 0 6px 6px; overflow-x: auto;") do
        table(style: "width: 100%; border-collapse: collapse; font-size: 13px;") do
          thead do
            tr do
              %w[Name Address City State ZIP Country].each do |h|
                th(style: "text-align: left; padding: 8px 12px; background: var(--bgColor-muted); font-weight: 600; border-bottom: 1px solid var(--borderColor-default);") { h }
              end
            end
          end
          tbody do
            @batch.addresses.limit(100).each do |addr|
              tr do
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") { "#{addr.first_name} #{addr.last_name}" }
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") { addr.line_1 || "—" }
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") { addr.city || "—" }
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") { addr.state || "—" }
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") { addr.postal_code || "—" }
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") { addr.country || "—" }
              end
            end
          end
        end
      end
    end
  end

  def danger_zone
    div(style: "margin-top: 24px; padding: 16px; border: 1px solid var(--borderColor-danger-muted); background: var(--bgColor-danger-muted); border-radius: 6px;") do
      h3(style: "margin-top: 0; color: var(--fgColor-danger);") { "Danger Zone" }
      p(style: "color: var(--fgColor-muted); font-size: 14px;") { "This action cannot be undone." }
      form(method: :post, action: warehouse_batch_path(@batch)) do
        input(type: :hidden, name: :_method, value: :delete)
        input(type: :hidden, name: :authenticity_token, value: form_authenticity_token)
        render Primer::Beta::Button.new(type: :submit, scheme: :danger) do |btn|
          btn.with_leading_visual_icon(icon: :trash)
          "Delete this batch"
        end
      end
    end
  end
end
