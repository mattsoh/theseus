# frozen_string_literal: true

class Components::Letters::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  register_value_helper :available_tags
  register_output_helper :vite_javascript_tag

  def initialize(letter:)
    @letter = letter
  end

  def view_template
    vite_javascript_tag("taggable")

    error_messages

    form_with(model: letter, url: form_url) do |f|
      # Letter Specs
      render Primer::Beta::BorderBox.new(mb: 4) do |box|
        box.with_header do |header|
          header.with_title(tag: :h2) { "Letter Specs" }
        end
        box.with_body do
          div(
            data_svelte_component: "letter-attributes-picker",
            data_form_scope: "letter",
            data_is_batch: "false",
            data_initial_width: letter.width.to_s,
            data_initial_height: letter.height.to_s,
            data_initial_weight: (letter.weight || 1).to_s,
            data_initial_processing_category: (letter.processing_category || "letter").to_s,
            data_initial_non_machinable: (letter.non_machinable || false).to_s
          )

          mailing_date_field(f)
        end
      end

      # Recipient Address
      render Primer::Beta::BorderBox.new(mb: 4) do |box|
        box.with_header do |header|
          header.with_title(tag: :h2) { "Recipient Address" }
        end
        box.with_body do
          address_fields(f)
        end
      end

      # Sender & Postage
      render Primer::Beta::BorderBox.new(mb: 4) do |box|
        box.with_header do |header|
          header.with_title(tag: :h2) { "Sender & Postage" }
        end
        box.with_body do
          sender_postage_fields(f)
        end
      end

      postage_script

      # Extras
      render Primer::Beta::BorderBox.new(mb: 4) do |box|
        box.with_header do |header|
          header.with_title(tag: :h2) { "Extras" }
        end
        box.with_body do
          render Primer::Alpha::TextField.new(
            name: "letter[user_facing_title]",
            label: "Title",
            caption: "Optional — shown on the letter list",
            value: letter.user_facing_title,
            full_width: true,
            mb: 3
          )

          render Primer::Alpha::TextField.new(
            name: "letter[recipient_email]",
            label: "Recipient email",
            caption: "Optional email address for the recipient",
            value: letter.recipient_email,
            input_type: :email,
            full_width: true,
            mb: 3
          )

          render Primer::Alpha::TextArea.new(
            name: "letter[rubber_stamps]",
            label: "Rubber stamps",
            caption: "Extra text to print on the label",
            value: letter.rubber_stamps,
            rows: 3,
            full_width: true
          )
        end
      end

      # Tags
      tag_picker(f)

      # Actions
      div(style: "display: flex; gap: 8px;") do
        render Primer::Beta::Button.new(tag: :a, href: letters_path, scheme: :secondary) do
          "Cancel"
        end
        render Primer::Beta::Button.new(type: :submit, scheme: :primary) do |btn|
          btn.with_leading_visual_icon(icon: :check)
          letter.persisted? ? "Update Letter" : "Create Letter"
        end
      end
    end
  end

  private

  attr_reader :letter

  def form_url
    letter.persisted? ? letter_path(letter) : letters_path
  end

  def error_messages
    return unless letter.errors.any?

    render Primer::Beta::Flash.new(scheme: :danger, mb: 3) do
      strong { "Hey, slight issue:" }
      ul(style: "margin: 8px 0 0 16px; padding: 0;") do
        letter.errors.each do |error|
          li { error.full_message }
        end
      end
    end
  end

  def mailing_date_field(f)
    div(style: "margin-top: 12px;") do
      label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;", for: "letter_mailing_date") { "Mailing date" }
      div(style: "margin-top: 4px;") do
        input(
          type: "date",
          name: "letter[mailing_date]",
          id: "letter_mailing_date",
          value: (letter.mailing_date || letter.default_mailing_date)&.iso8601,
          min: letter.new_record? ? Date.current.iso8601 : nil,
          style: "width: 100%; padding: 5px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);"
        )
      end
      div(style: "display: flex; gap: 4px; margin-top: 4px;") do
        button(
          type: "button",
          style: "padding: 3px 8px; font-size: 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default); cursor: pointer;",
          data_mailing_date: Date.tomorrow.iso8601
        ) { "Tomorrow" }
        button(
          type: "button",
          style: "padding: 3px 8px; font-size: 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default); cursor: pointer;",
          data_mailing_date: Date.current.next_occurring(:monday).iso8601
        ) { "Next Monday" }
      end
    end
  end

  def address_fields(f)
    countries = Address.countries_for_select.map do |code, name|
      flag = code.present? ? code.upcase.chars.map { |c| (c.ord + 127397).chr(Encoding::UTF_8) }.join : ""
      { code: code, name: name, flag: flag, display: "#{flag}  #{name}" }
    end

    top_codes = %w[US CA]
    top = top_codes.filter_map { |c| countries.find { |co| co[:code] == c } }
    others = countries.reject { |c| top_codes.include?(c[:code]) }
    all_ordered = top + others

    f.fields_for :address do |a|
      current_country = a.object&.country
      current_entry = countries.find { |c| c[:code] == current_country }
      form_id = "address-form-#{SecureRandom.hex(4)}"

      div(id: form_id, style: "display: grid; gap: 20px; max-width: 540px;") do
        # Name
        div(style: "display: grid; grid-template-columns: 1fr 1fr; gap: 16px;") do
          render Primer::Alpha::TextField.new(
            name: a.field_name(:first_name), label: "First name",
            value: a.object&.first_name, required: true, full_width: true
          )
          render Primer::Alpha::TextField.new(
            name: a.field_name(:last_name), label: "Last name",
            value: a.object&.last_name, full_width: true
          )
        end

        # Street
        render Primer::Alpha::TextField.new(
          name: a.field_name(:line_1), label: "Street address",
          value: a.object&.line_1, required: true, full_width: true
        )

        # Apt
        render Primer::Alpha::TextField.new(
          name: a.field_name(:line_2), label: "Apt, suite, unit, etc.",
          caption: "Optional", value: a.object&.line_2, full_width: true
        )

        # City / State / Postal
        div(style: "display: grid; grid-template-columns: 1fr 80px 100px; gap: 16px;") do
          render Primer::Alpha::TextField.new(
            name: a.field_name(:city), label: "City",
            value: a.object&.city, required: true, full_width: true
          )
          render Primer::Alpha::TextField.new(
            name: a.field_name(:state), label: "State",
            value: a.object&.state, required: true, full_width: true
          )
          render Primer::Alpha::TextField.new(
            name: a.field_name(:postal_code), label: "Postal code",
            value: a.object&.postal_code, required: true, full_width: true
          )
        end

        # Country
        div(style: "max-width: 280px;") do
          label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;") do
            plain "Country "
            span(style: "color: var(--fgColor-danger);") { "*" }
          end
          div(style: "margin-top: 6px;") do
            render(Primer::Alpha::SelectPanel.new(
              title: "Select country",
              size: :medium,
              fetch_strategy: :local,
              dynamic_label: true,
              select_variant: :single,
              form_arguments: { builder: a, name: :country }
            )) do |panel|
              panel.with_show_button(scheme: :secondary) do
                span(style: "display: flex; align-items: center; gap: 8px;") do
                  if current_entry
                    span(style: "font-size: 1.2em; line-height: 1;") { current_entry[:flag] }
                    span { current_entry[:name] }
                  else
                    span(style: "color: var(--fgColor-muted);") { "Select" }
                  end
                end
              end

              all_ordered.each do |country|
                panel.with_item(
                  label: country[:display],
                  content_arguments: {
                    data: {
                      value: country[:code],
                      code: country[:code],
                      name: country[:name]
                    }
                  },
                  data: { filter_string: "#{country[:code]}#{country[:code]}#{country[:code]} #{country[:name]}" },
                  active: country[:code] == current_country
                )
              end
            end
          end
        end
      end

      country_filter_script(form_id)
    end
  end

  def country_filter_script(form_id)
    script do
      raw <<~JS
        (function() {
          var container = document.getElementById('#{form_id}');
          if (!container) return;
          function setupPanel() {
            var panel = container.querySelector('select-panel');
            if (!panel) return;
            panel.filterFn = function(item, query) {
              var q = query.toLowerCase().trim();
              if (!q) return true;
              var itemContent = item.querySelector('[data-code]');
              var code = itemContent ? itemContent.dataset.code.toLowerCase() : '';
              var name = itemContent ? itemContent.dataset.name.toLowerCase() : '';
              if (code === q) return true;
              if (name.startsWith(q)) return true;
              return false;
            };
          }
          setupPanel();
          if (window.customElements) {
            window.customElements.whenDefined('select-panel').then(setupPanel);
          }
        })();
      JS
    end
  end

  def sender_postage_fields(f)
    addresses = ReturnAddress.shared.or(ReturnAddress.owned_by(current_user))

    # Return address
    div(style: "margin-bottom: 16px;") do
      label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;", for: "letter_return_address_id") { "Return address" }
      div(style: "margin-top: 4px;") do
        select(
          name: "letter[return_address_id]",
          id: "letter_return_address_id",
          style: "width: 100%; padding: 5px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);"
        ) do
          option(value: "") { "Select a return address..." }
          addresses.each do |addr|
            option(
              value: addr.id,
              selected: addr.id == letter.return_address_id
            ) { addr.display_name }
          end
        end
      end
      p(style: "color: var(--fgColor-muted); font-size: 12px; margin-top: 4px;") do
        a(href: return_addresses_path(from_letter: true)) { "Manage return addresses" }
      end
    end

    render Primer::Alpha::TextField.new(
      name: "letter[return_address_name]",
      label: "Custom return name",
      caption: "Leave blank to use the return address name",
      value: letter.return_address_name,
      full_width: true,
      mb: 3
    )

    # Postage type (hidden by default, shown by JS for US addresses)
    div(id: "postage-options", style: "display: none; margin-bottom: 16px;") do
      div do
        label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;") { "Postage type" }
        div(style: "display: flex; gap: 16px; margin-top: 4px;") do
          label(style: "display: flex; align-items: center; gap: 4px; cursor: pointer;") do
            input(
              type: "radio", name: "letter[postage_type]",
              value: "stamps",
              checked: letter.postage_type == "stamps" || letter.postage_type.blank?
            )
            plain " Stamps"
          end
          label(style: "display: flex; align-items: center; gap: 4px; cursor: pointer;") do
            input(
              type: "radio", name: "letter[postage_type]",
              value: "indicia",
              checked: letter.postage_type == "indicia"
            )
            plain " Indicia (Metered)"
          end
        end
        p(style: "color: var(--fgColor-muted); font-size: 12px; margin-top: 4px;") { "Indicia is slightly cheaper for standard letters" }
      end
    end

    # Mailer ID
    div(style: "margin-bottom: 16px;") do
      label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;", for: "letter_usps_mailer_id_id") { "USPS Mailer ID" }
      div(style: "margin-top: 4px;") do
        select(
          name: "letter[usps_mailer_id_id]",
          id: "letter_usps_mailer_id_id",
          style: "width: 100%; padding: 5px 12px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);"
        ) do
          option(value: "") { "Select a mailer ID..." }
          USPS::MailerId.all.each do |m|
            option(
              value: m.id,
              selected: m.id == (letter.usps_mailer_id_id || USPS::MailerId.first&.id)
            ) { m.name }
          end
        end
      end
    end

    render(Primer::Beta::Flash.new(scheme: :warning)) do
      raw "Please leave the mailer ID at the default if you're mailing from HQ &mdash; otherwise talk to Nora (it has USPS implications)."
    end
  end

  def postage_script
    addresses = ReturnAddress.shared.or(ReturnAddress.owned_by(current_user))
    address_data = addresses.map { |ra| { id: ra.id, country: ra.country } }

    script do
      raw <<~JS
        (function() {
          document.addEventListener('DOMContentLoaded', function() {
            var returnAddressSelect = document.getElementById('letter_return_address_id');
            var postageOptions = document.getElementById('postage-options');
            var stampsRadio = document.querySelector('input[name="letter[postage_type]"][value="stamps"]');
            var returnAddresses = #{address_data.to_json};

            function updatePostageOptions() {
              var selectedId = returnAddressSelect.value;
              if (!selectedId) {
                postageOptions.style.display = 'none';
                return;
              }

              var existingHidden = postageOptions.querySelector('input[type="hidden"][name="letter[postage_type]"]');
              if (existingHidden) existingHidden.remove();

              var selectedAddress = returnAddresses.find(function(ra) { return ra.id.toString() === selectedId; });
              var isUS = selectedAddress && selectedAddress.country === 'US';

              if (isUS) {
                postageOptions.style.display = 'block';
                if (!document.querySelector('input[name="letter[postage_type]"]:checked')) {
                  stampsRadio.checked = true;
                }
              } else {
                postageOptions.style.display = 'none';
                var internationalInput = document.createElement('input');
                internationalInput.type = 'hidden';
                internationalInput.name = 'letter[postage_type]';
                internationalInput.value = 'international_origin';
                postageOptions.appendChild(internationalInput);
              }
            }

            returnAddressSelect.addEventListener('change', updatePostageOptions);
            updatePostageOptions();

            document.querySelectorAll('[data-mailing-date]').forEach(function(btn) {
              btn.addEventListener('click', function() {
                document.getElementById('letter_mailing_date').value = btn.dataset.mailingDate;
              });
            });
          });
        })();
      JS
    end
  end

  def tag_picker(f)
    div(style: "margin-bottom: 16px;") do
      label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 4px;") { "Tags" }
      select(
        name: "letter[tags][]",
        multiple: true,
        class: "selectize-tags",
        style: "width: 100%;"
      ) do
        available_tags.each do |tag|
          option(value: tag, selected: letter.tags&.include?(tag)) { tag }
        end
      end
      p(style: "color: var(--fgColor-muted); font-size: 12px; margin-top: 4px;") { "Select from common tags or create your own" }
    end
  end
end
