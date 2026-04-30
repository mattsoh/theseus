# frozen_string_literal: true

class Views::Letter::Queues::Index < Views::Base
  def initialize(letter_queues:, all_queues:, letter_counts:, user_id: nil, queue_type: nil, users: [])
    @letter_queues = letter_queues
    @all_queues = all_queues
    @letter_counts = letter_counts
    @user_id = user_id
    @queue_type = queue_type
    @users = users
  end

  def view_template
    div(style: "max-width: 1200px; margin: 0 auto; padding: 24px;") do
      header_section
      filters_section
      queue_grid_section
    end
  end

  private

  attr_reader :letter_queues, :all_queues, :letter_counts, :user_id, :queue_type, :users

  def header_section
    div(style: "display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;") do
      div do
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "Queues" }
        p(style: "color: var(--fgColor-muted); margin: 4px 0 0; font-size: 14px;") do
          plain "#{letter_queues.count} #{"queue".pluralize(letter_queues.count)}"
        end
      end

      div(style: "display: flex; gap: 8px; align-items: center;") do
        admin_tool do
          button_to mark_printed_instants_mailed_letter_queues_path, method: :post, style: "padding: 3px 12px; font-size: 12px; border: 1px solid var(--borderColor-danger-emphasis); border-radius: 6px; background: var(--bgColor-danger-emphasis); color: var(--fgColor-onEmphasis); cursor: pointer;" do
            "Mark printed instants mailed"
          end
        end

        render Primer::Alpha::ActionMenu.new do |menu|
          menu.with_show_button(scheme: :primary, size: :medium) do |btn|
            btn.with_leading_visual_icon(icon: :plus)
            "New Queue"
          end
          menu.with_item(label: "Batch queue", href: new_letter_queue_path) do |item|
            item.with_leading_visual_icon(icon: :stack)
          end
          menu.with_item(label: "Instant queue", href: new_letter_instant_queue_path) do |item|
            item.with_leading_visual_icon(icon: :zap)
          end
        end
      end
    end
  end

  def filters_section
    div(style: "display: flex; gap: 12px; margin-bottom: 20px; align-items: center; flex-wrap: wrap;") do
      admin_tool do
        render Components::Shared::UserPicker.new(
          users: users,
          selected_user_id: user_id,
          path_builder: ->(uid) { letter_queues_path(user_id: uid, queue_type: queue_type) }
        )
      end

      type_toggle

      if user_id.present? || queue_type.present?
        render Primer::Beta::Button.new(
          tag: :a,
          href: letter_queues_path,
          scheme: :invisible,
          size: :small
        ) do |btn|
          btn.with_leading_visual_icon(icon: :x)
          "Clear filters"
        end
      end
    end
  end

  def type_toggle
    types = [
      { key: nil, label: "All", icon: :rows },
      { key: "batch", label: "Batch", icon: :stack },
      { key: "instant", label: "Instant", icon: :zap },
    ]

    div(style: "display: flex; gap: 4px;") do
      types.each do |t|
        is_active = queue_type == t[:key]
        render Primer::Beta::Button.new(
          tag: :a,
          href: letter_queues_path(queue_type: t[:key], user_id: user_id),
          scheme: is_active ? :secondary : :invisible,
          size: :medium
        ) do |btn|
          btn.with_leading_visual_icon(icon: t[:icon])
          t[:label]
        end
      end
    end
  end

  def queue_grid_section
    if letter_queues.any?
      div(style: "display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 16px; margin-bottom: 24px;") do
        sorted_queues.each { |q| queue_card(q) }
      end
    else
      blankslate
    end
  end

  def sorted_queues
    letter_queues.sort_by do |q|
      if q.is_a?(::Letter::InstantQueue)
        printed = count_for(q, "printed")
        printed > 0 ? [1, -printed] : [2, q.name.downcase]
      else
        queued = count_for(q, "queued")
        queued > 0 ? [0, -queued] : [2, q.name.downcase]
      end
    end
  end

  def queue_card(queue)
    is_instant = queue.is_a?(::Letter::InstantQueue)
    href = is_instant ? letter_instant_queue_path(queue, status: :printed) : letter_queue_path(queue, status: :queued)
    action = attention_count(queue)

    if action > 0
      bg = is_instant ? "var(--bgColor-done-muted)" : "var(--bgColor-accent-muted)"
      border = is_instant ? "var(--borderColor-done-emphasis)" : "var(--borderColor-accent-emphasis)"
      box_style = "background: #{bg}; border-color: #{border};"
    else
      box_style = nil
    end

    a(href: href, style: "text-decoration: none; color: inherit; display: block;") do
      render Primer::Beta::BorderBox.new(style: box_style) do |box|
        box.with_row do
          div(style: "display: flex; align-items: center; gap: 8px;") do
            span(style: "font-weight: 600; font-size: 15px; flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;") do
              queue.name
            end
            if is_instant
              render(Primer::Beta::Label.new(scheme: :done, size: :medium)) { "Instant" }
            else
              render(Primer::Beta::Label.new(scheme: :accent, size: :medium)) { "Batch" }
            end
          end
        end

        box.with_row do
          if action > 0
            label = is_instant ? "awaiting mail" : "queued"
            div(style: "display: flex; align-items: baseline; gap: 8px;") do
              span(style: "font-size: 32px; font-weight: 700; line-height: 1;") { action.to_s }
              span(style: "font-size: 14px; color: var(--fgColor-muted);") { label }
            end
          else
            div(style: "display: flex; align-items: baseline; gap: 8px;") do
              span(style: "font-size: 32px; font-weight: 700; line-height: 1; color: var(--fgColor-muted);") { "—" }
              span(style: "font-size: 14px; color: var(--fgColor-muted);") { "idle" }
            end
          end
        end

      end
    end
  end

  def blankslate
    render Primer::Beta::Blankslate.new(border: true) do |bs|
      bs.with_visual_icon(icon: :stack)
      bs.with_heading(tag: :h2) { "No queues found" }
      if queue_type.present? || user_id.present?
        bs.with_description { "Try adjusting your filters." }
      else
        bs.with_description { "Create a queue to get started." }
        bs.with_primary_action(href: new_letter_queue_path) { "New Queue" }
      end
    end
  end

  def count_for(queue, state)
    letter_counts[[queue.id, state]] || 0
  end

  def attention_count(queue)
    count_for queue, case queue
                     when ::Letter::InstantQueue
                       "printed"
                     else
                       "queued"
    end
  end

  def state_scheme(state)
    case state
    when "queued" then :secondary
    when "pending" then :attention
    when "printed" then :accent
    when "mailed", "received" then :success
    else :secondary
    end
  end
end
