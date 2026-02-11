# frozen_string_literal: true

class Components::Shared::PageHeader < Components::Base
  def initialize(title:, subtitle: nil)
    @title = title
    @subtitle = subtitle
    @actions_block = nil
  end

  def view_template
    div(style: "display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;") do
      div do
        h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { @title }
        if @subtitle
          p(style: "color: var(--fgColor-muted); margin: 4px 0 0; font-size: 14px;") { @subtitle }
        end
      end
      if @actions_block
        div(style: "display: flex; gap: 8px; align-items: center;") do
          @actions_block.call
        end
      end
    end
  end

  def with_actions(&block)
    @actions_block = block
    self
  end
end
