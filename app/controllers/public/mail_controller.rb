module Public
  class MailController < ApplicationController
    include MailQuerying

    before_action :authenticate_public_user!

    def index
      check_the_mail current_public_user.email
    end
  end
end
