# frozen_string_literal: true

class Views::Letter::Batches::Process < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::NumberToCurrency

  def initialize(batch:)
    @batch = batch
  end

  def view_template
    div(style: "max-width: 800px; margin: 0 auto; padding: 24px;") do
      div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 24px;") do
        render Primer::Beta::Button.new(tag: :a, href: letter_batch_path(@batch), scheme: :invisible, size: :small) do |btn|
          btn.with_leading_visual_icon(icon: :"arrow-left")
          "Back to batch"
        end
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "Process Letter Batch ##{@batch.id}" }
      end

      render Primer::Alpha::Banner.new(scheme: :default, mb: 4) do
        "This will generate labels for #{helpers.pluralize(@batch.addresses.count, 'address')}."
      end

      form_with(model: @batch, url: process_letter_batch_path(@batch), method: :post, scope: :batch) do |f|
        # Title
        render Primer::Beta::BorderBox.new(mb: 4) do |box|
          box.with_header do |header|
            header.with_title(tag: :h3) { "Letter Details" }
          end
          box.with_body do
            render Primer::Alpha::TextField.new(
              name: "batch[user_facing_title]",
              label: "Letter Title",
              caption: "Visible to recipients on their letters (e.g. \"Monthly Newsletter\")",
              full_width: true,
              mb: 3
            )

            # Mailing Date
            div(style: "margin-bottom: 16px;") do
              label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;", for: "batch_letter_mailing_date") { "Mailing Date" }
              p(style: "color: var(--fgColor-muted); font-size: 12px; margin-bottom: 4px;") { "Select the date you plan to mail these letters." }
              input(
                type: "date",
                name: "batch[letter_mailing_date]",
                id: "batch_letter_mailing_date",
                value: (@batch.letter_mailing_date || @batch.default_mailing_date).iso8601,
                min: Date.current.iso8601,
                required: true,
                style: "width: 100%; padding: 5px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);"
              )
            end
          end
        end

        # Templates
        render Primer::Beta::BorderBox.new(mb: 4) do |box|
          box.with_header do |header|
            header.with_title(tag: :h3) { "Label Templates" }
          end
          box.with_body do
            p(style: "color: var(--fgColor-muted); font-size: 12px; margin-bottom: 8px;") { "Select multiple templates to cycle through them, or just one for all labels." }
            template_select
          end
        end

        # QR Code
        render Primer::Beta::BorderBox.new(mb: 4) do |box|
          box.with_header do |header|
            header.with_title(tag: :h3) { "Options" }
          end
          box.with_body do
            label(style: "display: flex; align-items: center; gap: 8px; cursor: pointer;") do
              input(type: "checkbox", name: "batch[include_qr_code]", value: "1", checked: true)
              span { "Include QR code on labels" }
            end
          end
        end

        # Postage
        render Primer::Beta::BorderBox.new(mb: 4) do |box|
          box.with_header do |header|
            header.with_title(tag: :h3) { "Postage" }
          end
          box.with_body do
            postage_options
            cost_info
          end
        end

        # Payment Account
        render Primer::Beta::BorderBox.new(mb: 4) do |box|
          box.with_header do |header|
            header.with_title(tag: :h3) { "Payment" }
          end
          box.with_body do
            payment_fields
          end
        end

        # Submit
        div(style: "display: flex; gap: 8px;") do
          render Primer::Beta::Button.new(tag: :a, href: letter_batch_path(@batch), scheme: :secondary) do
            "Cancel"
          end
          render Primer::Beta::Button.new(type: :submit, scheme: :primary) do |btn|
            btn.with_leading_visual_icon(icon: :play)
            "Generate Labels"
          end
        end
      end

      cost_update_script
    end
  end

  private

  def template_select
    standard_templates = SnailMail::PhlexService.templates_for_size(:standard)
    envelope_templates = SnailMail::PhlexService.templates_for_size(:envelope)

    select(
      name: "batch[template_cycle]",
      id: "batch_template_cycle",
      multiple: true,
      size: [8, (standard_templates.length + envelope_templates.length + 2)].min,
      style: "width: 100%; min-height: 120px; padding: 5px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);"
    ) do
      if standard_templates.present?
        optgroup(label: "Standard 4x6 Labels") do
          standard_templates.uniq.each do |template|
            option(value: template.to_s) { template.to_s }
          end
        end
      end
      if envelope_templates.present?
        optgroup(label: "#10 Envelopes") do
          envelope_templates.uniq.each do |template|
            option(value: template.to_s) { template.to_s }
          end
        end
      end
    end
  end

  def postage_options
    div(style: "display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 16px;") do
      div do
        h4(style: "font-size: 14px; font-weight: 600; margin: 0 0 8px;") { "US Mail" }
        div(style: "display: flex; flex-direction: column; gap: 8px;") do
          label(style: "display: flex; align-items: center; gap: 8px; cursor: pointer;") do
            input(type: "radio", name: "batch[us_postage_type]", value: "stamps", checked: true)
            span { "Stamps" }
          end
          label(style: "display: flex; align-items: center; gap: 8px; cursor: pointer;") do
            input(type: "radio", name: "batch[us_postage_type]", value: "indicia")
            span { "Indicia (Metered)" }
          end
        end
      end
      div do
        h4(style: "font-size: 14px; font-weight: 600; margin: 0 0 8px;") { "International Mail" }
        div(style: "display: flex; flex-direction: column; gap: 8px;") do
          label(style: "display: flex; align-items: center; gap: 8px; cursor: pointer;") do
            input(type: "radio", name: "batch[intl_postage_type]", value: "stamps", checked: true)
            span { "Stamps" }
          end
          label(style: "display: flex; align-items: center; gap: 8px; cursor: pointer;") do
            input(type: "radio", name: "batch[intl_postage_type]", value: "indicia")
            span { "Indicia (Metered)" }
          end
        end
      end
    end
  end

  def cost_info
    div(id: "cost-info", style: "padding: 12px; background: var(--bgColor-muted); border-radius: 6px;") do
      div(style: "display: grid; grid-template-columns: auto 1fr; gap: 4px 16px; font-size: 13px;") do
        span(style: "color: var(--fgColor-muted);") { "Total postage cost:" }
        span(id: "total_postage_cost", style: "font-weight: 600;") { number_to_currency(@batch.postage_cost) }

        span(style: "color: var(--fgColor-muted);") { "US cost difference:" }
        span(id: "us_cost_difference") { number_to_currency(@batch.postage_cost_difference[:us]) }

        span(style: "color: var(--fgColor-muted);") { "International cost difference:" }
        span(id: "intl_cost_difference") { number_to_currency(@batch.postage_cost_difference[:intl]) }
      end
      div(id: "cost_explanation", style: "margin-top: 8px; font-size: 12px; color: var(--fgColor-muted);") do
        us_count = @batch.letters.joins(:address).where(addresses: { country: "US" }).count
        intl_count = @batch.letters.joins(:address).where.not(addresses: { country: "US" }).count
        total_stamps = us_count + intl_count
        if total_stamps > 0
          plain "You'll have to put stamps on #{total_stamps} envelope#{"s" unless total_stamps == 1}"
        end
      end
    end
  end

  def payment_fields
    div(style: "margin-bottom: 16px;") do
      label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;", for: "batch_usps_payment_account_id") { "USPS Payment Account" }
      p(style: "color: var(--fgColor-muted); font-size: 12px; margin-bottom: 4px;") { "Required only when using indicia." }
      select(
        name: "batch[usps_payment_account_id]",
        id: "batch_usps_payment_account_id",
        style: "width: 100%; padding: 5px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);"
      ) do
        option(value: "") { "Select a payment account..." }
        USPS::PaymentAccount.all.each do |pa|
          option(value: pa.id) { pa.display_name }
        end
      end
    end

    if current_user.hcb_payment_accounts.any?
      div do
        label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;", for: "batch_hcb_payment_account_id") { "HCB Payment Account" }
        p(style: "color: var(--fgColor-muted); font-size: 12px; margin-bottom: 4px;") { "Required for indicia purchases." }
        select(
          name: "batch[hcb_payment_account_id]",
          id: "batch_hcb_payment_account_id",
          style: "width: 100%; padding: 5px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);"
        ) do
          option(value: "") { "Select an HCB account..." }
          current_user.hcb_payment_accounts.each do |hcb|
            option(value: hcb.id) { hcb.display_name }
          end
        end
      end
    end
  end

  def cost_update_script
    script do
      raw <<~JS
        (function() {
          var postageInputs = document.querySelectorAll(
            'input[name="batch[us_postage_type]"], input[name="batch[intl_postage_type]"]'
          );
          var paymentSelect = document.getElementById('batch_usps_payment_account_id');

          function updateCosts() {
            var usType = document.querySelector('input[name="batch[us_postage_type]"]:checked').value;
            var intlType = document.querySelector('input[name="batch[intl_postage_type]"]:checked').value;

            if (paymentSelect) {
              paymentSelect.required = (usType === 'indicia' || intlType === 'indicia');
            }

            fetch('#{update_costs_letter_batch_path(@batch)}', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
              },
              body: JSON.stringify({ us_postage_type: usType, intl_postage_type: intlType })
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
              document.getElementById('total_postage_cost').textContent = '$' + data.total_cost.toFixed(2);
              document.getElementById('us_cost_difference').textContent = '$' + data.cost_difference.us.toFixed(2);
              document.getElementById('intl_cost_difference').textContent = '$' + data.cost_difference.intl.toFixed(2);
            });
          }

          postageInputs.forEach(function(input) {
            input.addEventListener('change', updateCosts);
          });
        })();
      JS
    end
  end
end
