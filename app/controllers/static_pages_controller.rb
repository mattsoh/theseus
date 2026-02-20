class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login, :api_docs]
  skip_after_action :verify_authorized

  def index
    @stats = DashboardStats.new(user: current_user)
  end

  def login
    render :login, layout: false
  end

  def api_docs
    respond_to do |format|
      format.html do
        markdown = Rails.root.join("app", "views", "static_pages", "api_docs.md").read
        render Components::StaticPages::APIDocs.new(markdown:)
      end
      format.md do
        llm_markdown = Rails.root.join("app", "views", "static_pages", "api_docs_llm.md").read
        render plain: llm_markdown, content_type: "text/markdown"
      end
    end
  end
end
