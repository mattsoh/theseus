module Public
  module MailQuerying
    extend ActiveSupport::Concern

    def check_the_mail(email)
      @mail =
        Warehouse::Order.where(recipient_email: email) +
          Letter.where(recipient_email: email)
      unless params[:no_load_lsv]
        @mail += LSV::TYPES.map { |type| type.find_by_email(email) }.flatten
      end
      @mail.sort_by!(&:created_at).reverse!
    end
  end
end
