# frozen_string_literal: true

class Components::Shared::Nav < Components::Base
  include Phlex::Rails::Helpers::LinkTo
  register_value_helper :request

  def view_template
    render Primer::Beta::NavList.new do |list|
      list.with_heading title: "Theseus"
      list.with_group do |group|
        group.with_heading(title: "Navigation")

        group.with_item(label: "Home", href: root_path)

        group.with_item(label: "Warehouse") do |item|
          item.with_item(label: "Batches", href: warehouse_batches_path)
          item.with_item(label: "SKUs", href: warehouse_skus_path)
          item.with_item(label: "Orders", href: warehouse_orders_path)
          item.with_item(label: "Purchase Orders", href: warehouse_purchase_orders_path)
          item.with_item(label: "Order templates", href: warehouse_templates_path)
        end

        group.with_item(label: "Mail") do |item|
          item.with_item(label: "Letters", href: letters_path)
          item.with_item(label: "Letter batches", href: letter_batches_path)
          item.with_item(label: "Return Addresses", href: return_addresses_path)
        end

        group.with_item(label: "Accounting") do |item|
          item.with_item(label: "Tags", href: tags_path)
        end

        group.with_item(label: "API") do |item|
          item.with_item(label: "API keys", href: api_keys_path)
          item.with_item(label: "Letter queues", href: letter_queues_path)
        end

        group.with_item(label: "Settings") do |item|
          item.with_item(label: "Print settings", href: settings_qz_tray_path)
          item.with_item(label: "HCB payment", href: hcb_payment_accounts_path)
        end

        if current_user&.admin?
          group.with_item(label: "Admin") do |item|
            item.with_item(label: "Good job, #{current_user.username}!", href: good_job_path)
            item.with_item(label: "Admin panel", href: admin_root_path)
            item.with_item(label: "Blaze it", href: blazer_path)
          end
        end

        if Rails.env.development?
          group.with_item(label: "Developer Tools") do |item|
            item.with_item(label: "Mail (not the real kind)", href: letter_opener_web_path, target: "_blank")
          end
        end
      end
    end
  end
end
