# frozen_string_literal: true

class Views::Warehouse::Batches::New < Views::Base
  include Phlex::Rails::Helpers::FormWith

  register_value_helper :available_tags
  register_output_helper :vite_javascript_tag

  def initialize(batch:, allowed_templates:)
    @batch = batch
    @allowed_templates = allowed_templates
  end

  def view_template
    vite_javascript_tag("taggable")

    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 24px;") do
        render Primer::Beta::Button.new(tag: :a, href: warehouse_batches_path, scheme: :invisible, size: :small) do |btn|
          btn.with_leading_visual_icon(icon: :"arrow-left")
          "Back"
        end
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "New Warehouse Batch" }
      end

      error_messages

      form_with(model: @batch, url: warehouse_batches_path, scope: :batch) do |f|
        # Template & Title
        render Primer::Beta::BorderBox.new(mb: 4) do |box|
          box.with_header do |header|
            header.with_title(tag: :h2) { "Batch Details" }
          end
          box.with_body do
            div(style: "margin-bottom: 16px;") do
              label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;", for: "batch_warehouse_template_id") { "Template" }
              div(style: "margin-top: 4px;") do
                select(
                  name: "batch[warehouse_template_id]",
                  id: "batch_warehouse_template_id",
                  style: "width: 100%; padding: 5px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);",
                  required: true
                ) do
                  @allowed_templates.each do |template|
                    option(value: template.id, selected: template.id == @allowed_templates.first&.id) { template.name }
                  end
                end
              end
            end

            render Primer::Alpha::TextField.new(
              name: "batch[warehouse_user_facing_title]",
              label: "Title",
              caption: "Optional — shown on the order list",
              full_width: true,
              mb: 3
            )
          end
        end

        # Addresses (CSV)
        render Primer::Beta::BorderBox.new(mb: 4) do |box|
          box.with_header do |header|
            header.with_title(tag: :h2) { "Addresses" }
          end
          box.with_body do
            address_fields = Address.column_names - %w[id created_at updated_at batch_id]
            div(
              data_svelte_component: "batch-csv-mapper",
              data_address_fields: address_fields.to_json,
              data_form_field_name: "batch[addresses_data]"
            )
          end
        end

        # Tags
        tag_picker(f)

        # Actions
        div(class: "d-flex gap-2") do
          render Primer::Beta::Button.new(tag: :a, href: warehouse_batches_path, scheme: :secondary) do
            "Cancel"
          end
          render Primer::Beta::Button.new(type: :submit, scheme: :primary) do |btn|
            btn.with_leading_visual_icon(icon: :check)
            "Create Batch"
          end
        end
      end
    end
  end

  private

  def error_messages
    return unless @batch.errors.any?

    render Primer::Beta::Flash.new(scheme: :danger, mb: 3) do
      strong { "Hey, slight issue:" }
      ul(style: "margin: 8px 0 0 16px; padding: 0;") do
        @batch.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end

  def tag_picker(f)
    div(class: "FormControl mb-3") do
      label(class: "FormControl-label") { "Tags" }
      select(
        name: "batch[tags][]",
        multiple: true,
        class: "selectize-tags width-full"
      ) do
        available_tags.each do |tag|
          option(value: tag) { tag }
        end
      end
      p(class: "FormControl-caption") { "Select from common tags or create your own" }
    end
  end
end
