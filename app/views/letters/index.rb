# frozen_string_literal: true

class Views::Letters::Index < Views::Base
  include Phlex::Rails::Helpers::TimeAgoInWords

  def initialize(letters:, all_letters:, search: nil, status: nil, origin: nil, user_id: nil, users: [])
    @letters = letters
    @all_letters = all_letters
    @search = search
    @status = status
    @origin = origin
    @user_id = user_id
    @users = users
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      header_section
      stats_section
      filters_section
      letters_list
      pagination_section
    end
  end

  private

  attr_reader :letters, :all_letters, :search, :status, :origin, :user_id, :users

  def header_section
    div(style: "display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;") do
      div do
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "Letters" }
        p(style: "color: var(--fgColor-muted); margin: 4px 0 0; font-size: 14px;") do
          plain "#{letters.respond_to?(:total_count) ? letters.total_count : letters.count} letters"
        end
      end

      render Primer::Beta::Button.new(tag: :a, href: new_letter_path, scheme: :primary) do |btn|
        btn.with_leading_visual_icon(icon: :plus)
        "Send Letter"
      end
    end
  end

  def stats_section
    counts = {
      pending: all_letters.where(aasm_state: :pending).count,
      printed: all_letters.where(aasm_state: :printed).count,
      mailed: all_letters.where(aasm_state: :mailed).count,
      received: all_letters.where(aasm_state: :received).count
    }

    div(style: "display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap;") do
      stat_pill("Pending", counts[:pending], :attention, "pending")
      stat_pill("Printed", counts[:printed], :secondary, "printed")
      stat_pill("Mailed", counts[:mailed], :accent, "mailed")
      stat_pill("Received", counts[:received], :success, "received")
    end
  end

  def stat_pill(label, count, scheme, filter_status)
    is_active = status == filter_status
    href = if is_active
             letters_path(origin: origin, search: search, user_id: user_id)
           else
             letters_path(origin: origin, search: search, user_id: user_id, status: filter_status)
           end

    schemes = {
      secondary: { bg: "var(--bgColor-muted)", border: "var(--borderColor-default)", active_bg: "#444c56" },
      accent: { bg: "var(--bgColor-accent-muted)", border: "var(--borderColor-accent-muted)", active_bg: "#0969da" },
      success: { bg: "var(--bgColor-success-muted)", border: "var(--borderColor-success-muted)", active_bg: "#238636" },
      attention: { bg: "var(--bgColor-attention-muted)", border: "var(--borderColor-attention-muted)", active_bg: "#9e6a03" }
    }
    s = schemes[scheme]

    a(
      href: href,
      style: "display: flex; align-items: center; gap: 8px; padding: 8px 14px; " \
             "background: #{is_active ? s[:active_bg] : s[:bg]}; " \
             "border: 1px solid #{is_active ? s[:active_bg] : s[:border]}; " \
             "border-radius: 6px; text-decoration: none; " \
             "color: #{is_active ? '#fff' : 'inherit'}; font-size: 14px;"
    ) do
      span(style: "font-weight: 600;") { count.to_s }
      span(style: is_active ? "" : "color: var(--fgColor-muted);") { label }
    end
  end

  def filters_section
    div(style: "display: flex; gap: 12px; margin-bottom: 20px; align-items: center; flex-wrap: wrap;") do
      div(style: "flex: 1; min-width: 200px; max-width: 400px;") do
        form_tag(letters_path, method: :get, style: "display: contents;") do
          hidden_field_tag(:status, status) if status.present?
          hidden_field_tag(:origin, origin) if origin.present?
          hidden_field_tag(:user_id, user_id) if user_id.present?
          render Primer::Alpha::TextField.new(
            name: "search",
            label: "Search",
            visually_hide_label: true,
            placeholder: "Search by recipient, title, or email...",
            value: search,
            leading_visual: { icon: :search },
            full_width: true
          )
        end
      end

      admin_tool do
        render Components::Shared::UserPicker.new(
          users: users,
          selected_user_id: user_id,
          path_builder: ->(uid) { letters_path(search: search, status: status, origin: origin, user_id: uid) }
        )
      end

      origin_filter_section

      has_filters = search.present? || status.present? || origin.present? || user_id.present?
      if has_filters
        render Primer::Beta::Button.new(
          tag: :a,
          href: letters_path,
          scheme: :invisible,
          size: :small
        ) do |btn|
          btn.with_leading_visual_icon(icon: :x)
          "Clear filters"
        end
      end
    end
  end

  def origin_filter_section
    origins = [
      { key: nil, label: "All", icon: :rows },
      { key: "manual", label: "Manual", icon: :pencil },
      { key: "bulk_upload", label: "Bulk upload", icon: :upload },
      { key: "queue", label: "Queue", icon: :stack },
      { key: "api", label: "API", icon: :code },
    ]

    div(style: "display: flex; gap: 4px;") do
      origins.each do |o|
        is_active = origin == o[:key]
        render Primer::Beta::Button.new(
          tag: :a,
          href: letters_path(origin: o[:key], search: search, status: status, user_id: user_id),
          scheme: is_active ? :secondary : :invisible,
          size: :medium
        ) do |btn|
          btn.with_leading_visual_icon(icon: o[:icon])
          o[:label]
        end
      end
    end
  end

  def letters_list
    if letters.any?
      render Primer::Beta::BorderBox.new do |box|
        box.with_header do
          div(style: "display: flex; justify-content: space-between; align-items: center; width: 100%;") do
            span(style: "font-weight: 600;") { "Letter" }
            div(style: "display: flex; gap: 48px;") do
              span(style: "font-weight: 600; min-width: 140px;") { "Recipient" }
              span(style: "font-weight: 600; min-width: 100px; text-align: right;") { "Batch" }
              span(style: "font-weight: 600; min-width: 80px; text-align: right;") { "Status" }
            end
          end
        end

        letters.each do |letter|
          box.with_row do
            render_letter_row(letter)
          end
        end
      end
    else
      render Primer::Beta::Blankslate.new(border: true) do |bs|
        bs.with_visual_icon(icon: :mail)
        bs.with_heading(tag: :h2) { "No letters found" }
        if search.present? || status.present?
          bs.with_description { "Try adjusting your search or filters." }
        else
          bs.with_description { "Send your first letter to get started." }
          bs.with_primary_action(href: new_letter_path) { "Send Letter" }
        end
      end
    end
  end

  def render_letter_row(letter)
    a(
      href: letter_path(letter),
      style: "display: flex; justify-content: space-between; align-items: center; width: 100%; " \
             "text-decoration: none; color: inherit; gap: 16px;"
    ) do
      div(style: "flex: 1; min-width: 0;") do
        div(style: "display: flex; align-items: center; gap: 8px; margin-bottom: 2px;") do
          span(style: "font-weight: 600; font-family: var(--fontStack-monospace); font-size: 13px; color: var(--fgColor-accent);") do
            letter.public_id
          end
          if letter.user_facing_title.present?
            span(style: "color: var(--fgColor-default);") { "·" }
            span(style: "font-size: 14px; color: var(--fgColor-default); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 280px;") do
              letter.user_facing_title
            end
          end
          render_tags(letter.tags.first(2)) if letter.tags.present?
        end
        div(style: "font-size: 12px; color: var(--fgColor-muted); margin-top: 2px;") do
          plain letter.created_at.strftime("%b %d, %Y")
          plain " · #{letter.origin_label}"
          if letter.mailed_at
            plain " · Mailed #{time_ago_in_words(letter.mailed_at)} ago"
          end
        end
      end

      div(style: "display: flex; gap: 48px; align-items: center; flex-shrink: 0;") do
        div(style: "min-width: 140px;") do
          div(style: "font-size: 14px; font-weight: 500;") { letter.address&.name_line || "—" }
          if letter.recipient_email.present?
            div(style: "font-size: 12px; color: var(--fgColor-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 140px;") do
              letter.recipient_email
            end
          end
        end

        div(style: "min-width: 100px; text-align: right;") do
          if letter.batch_id.present?
            render Primer::Beta::Label.new(scheme: :secondary, size: :medium) do
              "Batch ##{letter.batch_id}"
            end
          else
            span(style: "font-size: 13px; color: var(--fgColor-muted);") { "—" }
          end
        end

        div(style: "min-width: 80px; text-align: right;") do
          render Components::Shared::StatusBadge.new(status: letter.aasm_state, type: :letter)
        end
      end
    end
  end

  def render_tags(tags)
    tags.compact_blank.each do |tag|
      render(Primer::Beta::Label.new(scheme: :secondary, size: :medium)) { tag }
    end
  end

  def pagination_section
    return unless letters.respond_to?(:total_pages) && letters.total_pages > 1

    div(style: "margin-top: 24px; display: flex; justify-content: center; gap: 8px; align-items: center;") do
      pagination_info
      pagination_links
    end
  end

  def pagination_info
    current = letters.current_page
    total = letters.total_pages
    total_count = letters.total_count

    span(style: "font-size: 13px; color: var(--fgColor-muted);") do
      plain "Page #{current} of #{total} (#{total_count} letters)"
    end
  end

  def pagination_links
    current = letters.current_page
    total = letters.total_pages

    div(style: "display: flex; gap: 4px;") do
      if current > 1
        render Primer::Beta::Button.new(
          tag: :a,
          href: letters_path(page: current - 1, origin: origin, search: search, status: status, user_id: user_id),
          scheme: :secondary,
          size: :small
        ) { "← Prev" }
      end

      if current < total
        render Primer::Beta::Button.new(
          tag: :a,
          href: letters_path(page: current + 1, origin: origin, search: search, status: status, user_id: user_id),
          scheme: :secondary,
          size: :small
        ) { "Next →" }
      end
    end
  end

  def form_tag(url, method:, style:, &block)
    form(action: url, method: method == :get ? "get" : "post", style: style, &block)
  end

  def hidden_field_tag(name, value)
    input(type: "hidden", name: name, value: value)
  end
end
