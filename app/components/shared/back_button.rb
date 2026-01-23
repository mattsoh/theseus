# frozen_string_literal: true

class Components::Shared::BackButton < Components::Base
  def initialize(href:, label: "Back")
    @href = href
    @label = label
  end

  def view_template
    a(
      href: @href,
      class: "btn btn-secondary"
    ) do
      render Primer::Beta::Octicon.new(icon: :"arrow-left", mr: 1)
      plain @label
    end
  end
end
