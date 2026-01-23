# frozen_string_literal: true

class Views::ReturnAddresses::Edit < Views::Base
  def initialize(return_address:)
    @return_address = return_address
  end

  def view_template
    div(style: "max-width: 640px;") do
      h1(style: "font-size: 24px; font-weight: 600; margin: 0 0 24px 0;") { "Edit Return Address" }

      div(style: "background: var(--bgColor-default, #fff); border: 1px solid var(--borderColor-default, #d0d7de); border-radius: 6px; overflow: hidden; margin-bottom: 16px;") do
        div(style: "padding: 12px 16px; border-bottom: 1px solid var(--borderColor-default, #d0d7de); background: var(--bgColor-muted, #f6f8fa);") do
          h2(style: "font-size: 14px; font-weight: 600; margin: 0; color: var(--fgColor-default, #24292f);") { "Address Details" }
        end

        div(style: "padding: 20px;") do
          render Components::ReturnAddresses::Form.new(return_address:)
        end
      end

      render Components::Shared::BackButton.new(href: return_addresses_path)
    end
  end

  private

  attr_reader :return_address
end
