module Public
  class SettingsController < ApplicationController
    before_action :authenticate_public_user!

    def anonymous_map
    end

    def update_anonymous_map
      current_public_user.update!(opted_out_of_map: params[:opt] == "out")
      flash[:success] = "k, pls wait for the map to recache itself"
      redirect_to anonymous_map_path
    end
  end
end
