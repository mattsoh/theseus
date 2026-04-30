# frozen_string_literal: true

class Components::Letter::InstantQueues::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  register_value_helper :available_tags
  register_output_helper :vite_javascript_tag

  def initialize(queue:)
    @queue = queue
  end

  def view_template
    vite_javascript_tag("taggable")

    error_messages

    form_with(model: queue, url: form_url, scope: :letter_instant_queue) do |f|
      section_heading("The important part")

      div(style: "display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;") do
        render Primer::Alpha::TextField.new(
          name: "letter_instant_queue[name]", label: "Name",
          value: queue.name, required: true, full_width: true
        )
        render Primer::Alpha::TextField.new(
          name: "letter_instant_queue[user_facing_title]", label: "Display Title",
          value: queue.user_facing_title, full_width: true,
          caption: "Optional title shown to users"
        )
      end

      tag_picker(f)

      section_heading("Letter defaults")

      # Template
      div(style: "margin-bottom: 16px;") do
        render Components::Shared::TemplatePicker.new(
          form: f, name: :template,
          selected: queue.template, show_all: true
        )
      end

      # Letter dimensions (Svelte component)
      scope = "letter_instant_queue"
      div(
        style: "margin-bottom: 16px;",
        data_svelte_component: "letter-attributes-picker",
        data_form_scope: scope,
        data_is_batch: "true",
        data_initial_width: queue.letter_width.to_s,
        data_initial_height: queue.letter_height.to_s,
        data_initial_weight: (queue.letter_weight || 1).to_s,
        data_initial_processing_category: (queue.letter_processing_category || "letter").to_s
      )

      # Mailer ID
      select_field(
        name: "letter_instant_queue[letter_mailer_id_id]",
        label: "USPS Mailer ID",
        options: USPS::MailerId.all.map { |m| [m.display_name, m.id] },
        selected: queue.letter_mailer_id_id || current_user.home_mid_id
      )

      # Return Address
      addresses = ReturnAddress.shared.or(ReturnAddress.owned_by(current_user))
      select_field(
        name: "letter_instant_queue[letter_return_address_id]",
        label: "Return Address",
        options: addresses.map { |a| [a.display_name, a.id] },
        selected: queue.letter_return_address_id || current_user.home_return_address_id,
        link: { text: "(manage)", href: return_addresses_path }
      )

      div(style: "margin-bottom: 16px;") do
        render Primer::Alpha::TextField.new(
          name: "letter_instant_queue[letter_return_address_name]",
          label: "Custom return address name",
          value: queue.letter_return_address_name, full_width: true,
          caption: "Leave blank to use the address' default name"
        )
      end

      section_heading("Instant queue settings")

      # Postage type
      select_field(
        name: "letter_instant_queue[postage_type]",
        label: "Postage Type",
        options: [["Indicia", "indicia"], ["Stamps", "stamps"], ["International Origin", "international_origin"]],
        selected: queue.postage_type || "indicia"
      )

      # USPS Payment Account
      select_field(
        name: "letter_instant_queue[usps_payment_account_id]",
        label: "USPS Payment Account",
        options: USPS::PaymentAccount.all.map { |a| [a.display_name, a.id] },
        selected: queue.usps_payment_account_id
      )

      # HCB Payment Account
      if current_user.hcb_payment_accounts.any?
        select_field(
          name: "letter_instant_queue[hcb_payment_account_id]",
          label: "Pay with HCB Organization",
          options: current_user.hcb_payment_accounts.map { |a| [a.organization_name, a.id] },
          selected: queue.hcb_payment_account_id
        )
      else
        div(style: "margin-bottom: 16px;") do
          label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;") { "Pay with HCB Organization" }
          p(style: "font-size: 14px; color: var(--fgColor-muted); margin-top: 4px;") do
            a(href: new_hcb_oauth_connection_path) { "Connect your HCB account" }
            plain " to use indicia."
          end
        end
      end

      # QR Code
      div(style: "margin-bottom: 16px;") do
        checked = queue.include_qr_code.nil? ? true : queue.include_qr_code
        label(style: "display: flex; align-items: center; gap: 8px; cursor: pointer;") do
          input(
            type: :checkbox, name: "letter_instant_queue[include_qr_code]",
            value: "1", checked: checked
          )
          span { "Include QR Code" }
        end
        input(type: :hidden, name: "letter_instant_queue[include_qr_code]", value: "0")
      end

      # Admin slug
      admin_tool do
        div(style: "margin-bottom: 16px;") do
          render Primer::Alpha::TextField.new(
            name: "letter_instant_queue[slug]", label: "Slug",
            value: queue.slug, full_width: true
          )
        end
      end

      # Submit
      div(style: "margin-top: 24px;") do
        render Primer::Beta::Button.new(type: :submit, scheme: :primary) do |btn|
          btn.with_leading_visual_icon(icon: :check)
          queue.new_record? ? "Create Instant Queue" : "Update Instant Queue"
        end
      end
    end
  end

  private

  attr_reader :queue

  def form_url
    queue.new_record? ? letter_instant_queues_path : letter_instant_queue_path(queue)
  end

  def error_messages
    return unless queue.errors.any?

    div(style: "padding: 12px 16px; margin-bottom: 16px; border: 1px solid var(--borderColor-danger-muted); background: var(--bgColor-danger-muted); border-radius: 6px; color: var(--fgColor-danger);") do
      strong { "#{queue.errors.count} #{"error".pluralize(queue.errors.count)} prohibited this queue from being saved:" }
      ul(style: "margin: 8px 0 0; padding-left: 20px;") do
        queue.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end

  def section_heading(text)
    h3(style: "font-size: 16px; font-weight: 600; margin: 24px 0 12px;") { text }
  end

  def tag_picker(f)
    div(style: "margin-bottom: 16px;") do
      label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;") { "Tags" }
      select(
        name: "letter_instant_queue[tags][]",
        multiple: true,
        class: "selectize-tags",
        style: "width: 100%;"
      ) do
        available_tags.each do |tag|
          option(value: tag, selected: queue.tags&.include?(tag)) { tag }
        end
      end
      p(style: "color: var(--fgColor-muted); font-size: 12px; margin-top: 4px;") { "Select from common tags or create your own" }
    end
  end

  def select_field(name:, label:, options:, selected: nil, link: nil)
    div(style: "margin-bottom: 16px;") do
      div(style: "display: flex; align-items: baseline; gap: 8px; margin-bottom: 4px;") do
        label(style: "display: block; font-size: 14px; font-weight: 600;") { label }
        if link
          a(href: link[:href], style: "font-size: 12px;") { link[:text] }
        end
      end
      select(name: name, style: "width: 100%; padding: 8px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);") do
        options.each do |display, value|
          option(value: value, selected: value.to_s == selected.to_s) { display }
        end
      end
    end
  end
end
