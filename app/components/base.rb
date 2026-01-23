# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Components
  register_value_helper :current_user

  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Routes

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
