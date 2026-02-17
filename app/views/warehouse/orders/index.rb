# frozen_string_literal: true

class Views::Warehouse::Orders::Index < Views::Base
  def initialize(warehouse_orders:, all_orders:, origin: nil, search: nil, state: nil, user_id: nil, users: [])
    @warehouse_orders = warehouse_orders
    @all_orders = all_orders
    @origin = origin
    @search = search
    @state = state
    @user_id = user_id
    @users = users
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      header_section
      stats_section
      filters_section
      orders_list
      pagination_section
    end
  end

  private

  attr_reader :warehouse_orders, :all_orders, :origin, :search, :state, :user_id, :users

  def header_section
    div(style: "display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;") do
      div do
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "Orders" }
        p(style: "color: var(--fgColor-muted); margin: 4px 0 0; font-size: 14px;") do
          plain "#{warehouse_orders.respond_to?(:total_count) ? warehouse_orders.total_count : warehouse_orders.count} orders"
        end
      end

      render Primer::Beta::Button.new(tag: :a, href: new_warehouse_order_path, scheme: :primary) do |btn|
        btn.with_leading_visual_icon(icon: :plus)
        "New Order"
      end
    end
  end

  def stats_section
    counts = {
      draft: all_orders.where(aasm_state: :draft).count,
      dispatched: all_orders.where(aasm_state: :dispatched).count,
      mailed: all_orders.where(aasm_state: :mailed).count,
      canceled: all_orders.where(aasm_state: :canceled).count
    }

    div(style: "display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap;") do
      stat_pill("Draft", counts[:draft], :secondary, "draft")
      stat_pill("At Warehouse", counts[:dispatched], :accent, "dispatched")
      stat_pill("Shipped", counts[:mailed], :success, "mailed")
      stat_pill("Canceled", counts[:canceled], :attention, "canceled") if counts[:canceled] > 0
    end
  end

  def stat_pill(label, count, scheme, filter_state)
    is_active = state == filter_state
    href = if is_active
             warehouse_orders_path(origin: origin, search: search)
           else
             warehouse_orders_path(origin: origin, search: search, state: filter_state)
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
        form_tag(warehouse_orders_path, method: :get, style: "display: contents;") do
          hidden_field_tag(:origin, origin) if origin.present?
          hidden_field_tag(:state, state) if state.present?
          hidden_field_tag(:user_id, user_id) if user_id.present?
          render Primer::Alpha::TextField.new(
            name: "search",
            label: "Search",
            visually_hide_label: true,
            placeholder: "Search by ID, email, name, or title...",
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
          path_builder: ->(uid) { warehouse_orders_path(origin: origin, search: search, state: state, user_id: uid) }
        )
      end

      origin_filter_section

      has_filters = search.present? || state.present? || user_id.present? || origin.present?
      if has_filters
        render Primer::Beta::Button.new(
          tag: :a,
          href: warehouse_orders_path,
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
      { key: "api", label: "API", icon: :code },
    ]

    div(style: "display: flex; gap: 4px;") do
      origins.each do |o|
        is_active = origin == o[:key]
        render Primer::Beta::Button.new(
          tag: :a,
          href: warehouse_orders_path(origin: o[:key], search: search, state: state, user_id: user_id),
          scheme: is_active ? :secondary : :invisible,
          size: :medium
        ) do |btn|
          btn.with_leading_visual_icon(icon: o[:icon])
          o[:label]
        end
      end
    end
  end

  def orders_list
    if warehouse_orders.any?
      render Primer::Beta::BorderBox.new do |box|
        box.with_header do
          div(style: "display: flex; justify-content: space-between; align-items: center; width: 100%;") do
            span(style: "font-weight: 600;") { "Order" }
            div(style: "display: flex; gap: 48px;") do
              span(style: "font-weight: 600; min-width: 140px;") { "Recipient" }
              span(style: "font-weight: 600; min-width: 100px; text-align: right;") { "Items" }
              span(style: "font-weight: 600; min-width: 80px; text-align: right;") { "Status" }
            end
          end
        end

        warehouse_orders.each do |order|
          box.with_row do
            render_order_row(order)
          end
        end
      end
    else
      render Primer::Beta::Blankslate.new(border: true) do |bs|
        bs.with_visual_icon(icon: :package)
        bs.with_heading(tag: :h2) { "No orders found" }
        if search.present? || state.present?
          bs.with_description { "Try adjusting your search or filters." }
        else
          bs.with_description { "Create your first order to get started." }
          bs.with_primary_action(href: new_warehouse_order_path) { "New Order" }
        end
      end
    end
  end

  def render_order_row(order)
    a(
      href: warehouse_order_path(order),
      style: "display: flex; justify-content: space-between; align-items: center; width: 100%; " \
             "text-decoration: none; color: inherit; gap: 16px;"
    ) do
      div(style: "flex: 1; min-width: 0;") do
        div(style: "display: flex; align-items: center; gap: 8px; margin-bottom: 2px;") do
          span(style: "font-weight: 600; font-family: var(--fontStack-monospace); font-size: 13px; color: var(--fgColor-accent);") do
            order.hc_id
          end
          if order.user_facing_title.present?
            span(style: "color: var(--fgColor-default);") { "·" }
            span(style: "font-size: 14px; color: var(--fgColor-default); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 280px;") do
              order.user_facing_title
            end
          end
          render_tags(order.tags.first(2)) if order.tags.present?
        end
        div(style: "font-size: 12px; color: var(--fgColor-muted); margin-top: 2px;") do
          plain order.created_at.strftime("%b %d, %Y")
          plain " · #{order.origin_label}"
          if order.source_tag&.name.present?
            plain " · #{order.source_tag.name}"
          end
        end
      end

      div(style: "display: flex; gap: 48px; align-items: center; flex-shrink: 0;") do
        div(style: "min-width: 140px;") do
          div(style: "font-size: 14px; font-weight: 500;") { order.address&.name_line || "—" }
          div(style: "font-size: 12px; color: var(--fgColor-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 140px;") do
            order.recipient_email
          end
        end

        div(style: "min-width: 100px; text-align: right;", title: order.line_items.map { |li| "#{li.quantity}× #{li.sku.name}" }.join(", ")) do
          span(style: "font-weight: 600;") { order.line_items.sum(&:quantity).to_s }
          span(style: "color: var(--fgColor-muted); margin-left: 4px;") { "items" }
        end

        div(style: "min-width: 80px; text-align: right;") do
          status_label(order)
        end
      end
    end
  end

  def render_tags(tags)
    tags.compact_blank.each do |tag|
      render(Primer::Beta::Label.new(scheme: :secondary, size: :medium)) { tag }
    end
  end

  def status_label(order)
    scheme = case order.aasm_state.to_sym
             when :draft then :secondary
             when :dispatched then :accent
             when :mailed then :success
             when :errored then :danger
             when :canceled then :attention
             else :secondary
             end

    render(Primer::Beta::Label.new(scheme: scheme, size: :medium)) { order.humanized_state }
  end

  def pagination_section
    render Components::Shared::Pagination.new(
      collection: warehouse_orders,
      base_path: method(:warehouse_orders_path),
      filter_params: { origin: origin, search: search, state: state, user_id: user_id }
    )
  end

  def form_tag(url, method:, style:, &block)
    form(action: url, method: method == :get ? "get" : "post", style: style, &block)
  end

  def hidden_field_tag(name, value)
    input(type: "hidden", name: name, value: value)
  end
end
