# frozen_string_literal: true

class Components::ReturnAddresses::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(return_address:, from_letter: false)
    @return_address = return_address
    @from_letter = from_letter
  end

  def view_template
    if return_address.errors.any?
      div(style: "background: var(--bgColor-danger-muted); border: 1px solid var(--borderColor-danger-muted); border-radius: 6px; padding: 12px 16px; margin-bottom: 16px;") do
        p(style: "font-size: 14px; font-weight: 600; color: var(--fgColor-danger); margin: 0 0 8px 0;") do
          plain "#{return_address.errors.count} error(s) prohibited this return address from being saved:"
        end
        ul(style: "margin: 0; padding-left: 20px; color: var(--fgColor-danger); font-size: 13px;") do
          return_address.errors.full_messages.each do |message|
            li { message }
          end
        end
      end
    end

    form_with model: return_address, local: true do |f|
      div(style: "display: flex; flex-direction: column; gap: 16px;") do
        div(style: "display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px;") do
          render Primer::Alpha::TextField.new(
            name: "return_address[name]",
            label: "Name",
            value: return_address.name,
            caption: "Organization or personal name",
            full_width: true,
            required: true
          )

          render Primer::Alpha::TextField.new(
            name: "return_address[line_1]",
            label: "Address Line 1",
            value: return_address.line_1,
            caption: "Street address, P.O. box, etc.",
            full_width: true,
            required: true
          )
        end

        render Primer::Alpha::TextField.new(
          name: "return_address[line_2]",
          label: "Address Line 2",
          value: return_address.line_2,
          caption: "Apartment, suite, unit, etc. (optional)",
          full_width: true
        )

        div(style: "display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 16px;") do
          render Primer::Alpha::TextField.new(
            name: "return_address[city]",
            label: "City",
            value: return_address.city,
            full_width: true,
            required: true
          )

          render Primer::Alpha::TextField.new(
            name: "return_address[state]",
            label: "State",
            value: return_address.state,
            full_width: true,
            required: true
          )

          render Primer::Alpha::TextField.new(
            name: "return_address[postal_code]",
            label: "Postal Code",
            value: return_address.postal_code,
            full_width: true,
            required: true
          )
        end

        div do
          label(style: "display: block; font-size: 14px; font-weight: 600; margin-bottom: 6px; color: var(--fgColor-default);") do
            plain "Country"
            span(style: "color: var(--fgColor-danger); margin-left: 2px;") { "*" }
          end
          select(
            name: "return_address[country]",
            style: "width: 100%; padding: 8px 12px; font-size: 14px; border: 1px solid var(--borderColor-default); border-radius: 6px; background: var(--bgColor-default); color: var(--fgColor-default);"
          ) do
            option(value: "") { "Select a country..." }
            ReturnAddress.countries_for_select.each do |code, name|
              if return_address.country == code
                option(value: code, selected: true) { name }
              else
                option(value: code) { name }
              end
            end
          end
        end

        div(style: "padding: 12px; background: var(--bgColor-muted); border-radius: 6px; border: 1px solid var(--borderColor-default);") do
          render Primer::Alpha::CheckBox.new(
            name: "return_address[shared]",
            label: "Make this address shared",
            caption: "Allow other users to select this return address for their letters",
            checked: return_address.shared
          )
        end

        input(type: "hidden", name: "return_address[user_id]", value: current_user&.id)
        input(type: "hidden", name: "from_letter", value: "true") if from_letter

        div(style: "padding-top: 8px;") do
          render Primer::Beta::Button.new(type: :submit, scheme: :primary) do |btn|
            btn.with_leading_visual_icon(icon: :check)
            return_address.persisted? ? "Update Return Address" : "Create Return Address"
          end
        end
      end
    end
  end

  private

  attr_reader :return_address, :from_letter
end
