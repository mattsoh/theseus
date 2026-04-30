# frozen_string_literal: true

class Components::Shared::PageHeader < Components::Base
  def initialize(title:, subtitle: nil, jumpcode: nil, jumpcode_path: nil)
    @title = title
    @subtitle = subtitle
    @jumpcode = jumpcode
    @jumpcode_path = jumpcode_path
    @actions_block = nil
  end

  def view_template
    div(style: "display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;") do
      div do
        div(style: "display: flex; align-items: center; gap: 8px;") do
          h1(style: "font-size: 24px; font-weight: 600; margin: 0;") { @title }
          if @jumpcode
            render Components::Shared::Jumpcode.new(code: @jumpcode)
          elsif @jumpcode_path
            render Components::Shared::Jumpcode.new(path: @jumpcode_path)
          end
        end
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
