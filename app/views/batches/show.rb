# frozen_string_literal: true

class Views::Batches::Show < Views::Base
  def initialize(batch:)
    @batch = batch
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      render Components::Shared::PageHeader.new(
        title: "#{@batch.type.split('::').first.titleize} Batch ##{@batch.id}",
        subtitle: "#{pluralize(@batch.addresses.count, @batch.type.split('::').first.downcase)}"
      ) do |header|
        header.with_actions do
          render Primer::Beta::Button.new(tag: :a, href: batches_path, scheme: :secondary, size: :small) do |btn|
            btn.with_leading_visual_icon(icon: :"arrow-left")
            "Back to batches"
          end
          render Primer::Beta::Button.new(tag: :a, href: edit_batch_path(@batch), scheme: :secondary, size: :small) do |btn|
            btn.with_leading_visual_icon(icon: :pencil)
            "Edit"
          end
        end
      end

      # Main batch display (render the existing _batch partial)
      render @batch

      # Letter batch details for Letter::Batch
      if @batch.is_a?(Letter::Batch) && @batch.processed?
        render partial: "letter_batch", locals: { batch: @batch }

        if @batch.letters.any?
          collapsible_section("Letters", @batch.letters.count) do
            render partial: "letters_collection", locals: { letters: @batch.letters }
          end
        end
      end

      # Warehouse orders for Warehouse::Batch
      if @batch.is_a?(Warehouse::Batch) && @batch.orders.any?
        collapsible_section("Orders", @batch.orders.count) do
          render partial: "orders_collection", locals: { orders: @batch.orders }
        end
      end

      # Admin inspector
      render partial: "admin_inspector", locals: { record: @batch }

      # Addresses table
      if @batch.addresses.any?
        collapsible_section("Addresses", @batch.addresses.count) do
          render partial: "addresses_table", locals: { addresses: @batch.addresses }
        end
      end

      # Danger zone
      danger_zone
    end
  end

  private

  attr_reader :batch

  def collapsible_section(title, count)
    details(style: "margin-top: 24px;") do
      summary(style: "cursor: pointer; display: flex; justify-content: space-between; align-items: center; padding: 12px; background: var(--bgColor-muted); border: 1px solid var(--borderColor-default); border-radius: 6px 6px 0 0; font-weight: 600;") do
        h2(style: "margin: 0; font-size: 16px;") { "#{title} (#{count})" }
        span(style: "color: var(--fgColor-muted);") { "▼" }
      end
      div(style: "border: 1px solid var(--borderColor-default); border-top: none; border-radius: 0 0 6px 6px; padding: 16px;") do
        yield
      end
    end
  end

  def danger_zone
    div(style: "margin-top: 24px; padding: 16px; border: 1px solid var(--borderColor-danger-muted); background: var(--bgColor-danger-muted); border-radius: 6px;") do
      h3(style: "margin-top: 0; color: var(--fgColor-danger);") { "Danger Zone" }
      p(style: "color: var(--fgColor-muted); font-size: 14px;") { "This action cannot be undone." }
      render Primer::Beta::Button.new(
        tag: :button,
        scheme: :danger,
        form: "delete-batch-form",
        type: :submit
      ) do |btn|
        btn.with_leading_visual_icon(icon: :trash)
        "Delete this batch"
      end
      form(id: "delete-batch-form", method: :post, action: batch_path(@batch), style: "display: none;") do
        input(type: :hidden, name: :_method, value: :delete)
        input(type: :hidden, name: :authenticity_token, value: form_authenticity_token)
      end
    end
  end
end
