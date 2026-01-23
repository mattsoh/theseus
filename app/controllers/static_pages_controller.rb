class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login]
  skip_after_action :verify_authorized

  def index
    @stats = DashboardStats.new(user: current_user)
  end

  def login
    render :login, layout: false
  end
end
