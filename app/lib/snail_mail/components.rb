require_relative "components/base_component"
require_relative "components/page_component"
require_relative "components/template_base"
require_relative "components/half_letter_component"

# Individual render components
require_relative "components/return_address_component"
require_relative "components/destination_address_component"
require_relative "components/imb_component"
require_relative "components/qr_code_component"
require_relative "components/letter_id_component"
require_relative "components/postage_component"
require_relative "components/speech_bubble_component"

require_relative "components/registry"

module SnailMail
  module Components
    # This module serves as the entry point for all Phlex::PDF components
  end
end
