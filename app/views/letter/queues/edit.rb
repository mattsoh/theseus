# frozen_string_literal: true

class Views::Letter::Queues::Edit < Views::Base
  def initialize(queue:)
    @queue = queue
  end

  def view_template
    div(style: "max-width: 800px; margin: 0 auto; padding: 24px;") do
      div(style: "display: flex; align-items: center; gap: 12px; margin-bottom: 24px;") do
        render Primer::Beta::Button.new(tag: :a, href: letter_queue_path(@queue), scheme: :invisible, size: :small) do |btn|
          btn.with_leading_visual_icon(icon: :"arrow-left")
          "Back"
        end
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { "Edit #{@queue.name}" }
      end

      div(style: "background: var(--bgColor-default); border: 1px solid var(--borderColor-default); border-radius: 6px; padding: 24px;") do
        render Components::Letter::Queues::Form.new(queue: @queue)
      end
    end
  end
end
