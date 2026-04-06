# frozen_string_literal: true

class Views::Letter::Batches::Show < Views::Base
  include Phlex::Rails::Helpers::TimeAgoInWords
  include Phlex::Rails::Helpers::NumberToCurrency

  def initialize(batch:)
    @batch = batch
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      render Components::Shared::PageHeader.new(
        title: "Letter Batch ##{@batch.id}",
        subtitle: "#{helpers.pluralize(@batch.addresses.count, 'address')} / #{helpers.pluralize(@batch.letters.count, 'letter')}"
      ) do |header|
        header.with_actions do
          render Primer::Beta::Button.new(tag: :a, href: letter_batches_path, scheme: :secondary, size: :small) do |btn|
            btn.with_leading_visual_icon(icon: :"arrow-left")
            "Back"
          end
          render Primer::Beta::Button.new(tag: :a, href: edit_letter_batch_path(@batch), scheme: :secondary, size: :small) do |btn|
            btn.with_leading_visual_icon(icon: :pencil)
            "Edit"
          end
          if @batch.fields_mapped?
            render Primer::Beta::Button.new(tag: :a, href: process_letter_batch_path(@batch), scheme: :primary, size: :small) do |btn|
              btn.with_leading_visual_icon(icon: :play)
              "Process"
            end
          end
        end
      end

      batch_details
      batch_actions if @batch.processed?
      letters_section if @batch.letters.any?
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
          detail_row("Origin") { plain @batch.origin }
          detail_row("Letter Size") { plain "#{@batch.letter_width}\" x #{@batch.letter_height}\"" }
          detail_row("Weight") { plain "#{@batch.letter_weight} oz" }
          detail_row("Mailer ID") { plain @batch.mailer_id&.display_name || "—" }
          detail_row("Return Address") { plain @batch.letter_return_address&.display_name || "—" }
          detail_row("Mailing Date") { plain @batch.letter_mailing_date&.strftime("%b %-d, %Y") || "Not set" }
          detail_row("Created") { plain "#{time_ago_in_words(@batch.created_at)} ago" }

          if @batch.tags.any?
            detail_row("Tags") { render Components::Shared::Tags.new(tags: @batch.tags) }
          end
        end
      end
    end
  end

  def detail_row(label)
    dt(style: "font-size: 13px; color: var(--fgColor-muted); font-weight: 600;") { label }
    dd(style: "margin: 0; font-size: 14px;") { yield }
  end

  def batch_actions
    render Primer::Beta::BorderBox.new(mb: 4) do |box|
      box.with_header do |header|
        header.with_title(tag: :h3) { "Actions" }
      end
      box.with_body do
        div(class: "d-flex gap-2 flex-wrap") do
          if @batch.pdf_label.attached?
            render Primer::Beta::Button.new(
              tag: :a,
              href: rails_blob_path(@batch.pdf_label, disposition: :inline),
              scheme: :primary,
              target: "_blank"
            ) do |btn|
              btn.with_leading_visual_icon(icon: :download)
              "View Labels PDF"
            end
          end

          form(method: :post, action: mark_printed_letter_batch_path(@batch), style: "display: inline;") do
            input(type: :hidden, name: :authenticity_token, value: form_authenticity_token)
            render Primer::Beta::Button.new(type: :submit, scheme: :secondary) do |btn|
              btn.with_leading_visual_icon(icon: :check)
              "Mark All Printed"
            end
          end

          form(method: :post, action: mark_mailed_letter_batch_path(@batch), style: "display: inline;") do
            input(type: :hidden, name: :authenticity_token, value: form_authenticity_token)
            render Primer::Beta::Button.new(type: :submit, scheme: :secondary) do |btn|
              btn.with_leading_visual_icon(icon: :mail)
              "Mark All Mailed"
            end
          end

          render Primer::Beta::Button.new(
            tag: :a,
            href: regen_letter_batch_path(@batch),
            scheme: :secondary
          ) do |btn|
            btn.with_leading_visual_icon(icon: :sync)
            "Regenerate Labels"
          end
        end

        if @batch.processed?
          div(style: "margin-top: 12px; font-size: 13px; color: var(--fgColor-muted);") do
            plain "Total postage: "
            strong { number_to_currency(@batch.postage_cost) }
          end
        end
      end
    end
  end

  def letters_section
    details(style: "margin-bottom: 16px;") do
      summary(style: "cursor: pointer; padding: 12px; background: var(--bgColor-muted); border: 1px solid var(--borderColor-default); border-radius: 6px; font-weight: 600;") do
        "Letters (#{@batch.letters.count})"
      end
      div(style: "border: 1px solid var(--borderColor-default); border-top: none; border-radius: 0 0 6px 6px; overflow-x: auto;") do
        table(style: "width: 100%; border-collapse: collapse; font-size: 13px;") do
          thead do
            tr do
              %w[ID Recipient Status Postage].each do |h|
                th(style: "text-align: left; padding: 8px 12px; background: var(--bgColor-muted); font-weight: 600; border-bottom: 1px solid var(--borderColor-default);") { h }
              end
            end
          end
          tbody do
            @batch.letters.includes(:address).limit(100).each do |letter|
              tr do
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") do
                  a(href: letter_path(letter)) { letter.public_id }
                end
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") do
                  plain "#{letter.address&.first_name} #{letter.address&.last_name}"
                end
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") do
                  render Components::Shared::StatusBadge.new(status: letter.aasm_state, type: :letter)
                end
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") do
                  plain letter.postage_type || "—"
                end
              end
            end
          end
        end
        if @batch.letters.count > 100
          div(style: "padding: 8px 12px; text-align: center; color: var(--fgColor-muted); font-size: 12px;") do
            "Showing first 100 of #{@batch.letters.count} letters"
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
                td(style: "padding: 8px 12px; border-bottom: 1px solid var(--borderColor-muted);") { "#{addr.line_1}#{addr.line_2.present? ? ", #{addr.line_2}" : ""}" }
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
      form(method: :post, action: letter_batch_path(@batch)) do
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
