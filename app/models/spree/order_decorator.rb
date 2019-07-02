module Spree
  module SpreeMailchimpEcommerce
    module OrderDecorator
      def self.prepended(base)
        base.before_update :create_mailchimp_cart, if: proc { email_changed? }
        base.state_machine.after_transition to: :complete, do: :after_create_jobs
        base.state_machine.after_transition to: :canceled, do: :after_cancel_jobs
      end

      def associate_user!(user, override_email = true)
        super
        create_mailchimp_cart unless new_record? || line_items.empty?
        true
      end

      def mailchimp_cart
        ::SpreeMailchimpEcommerce::Presenters::CartMailchimpPresenter.new(self).json
      end

      def mailchimp_order
        ::SpreeMailchimpEcommerce::Presenters::OrderMailchimpPresenter.new(self).json.merge(@notification || {})
      end

      def update_mailchimp_cart
        ::SpreeMailchimpEcommerce::UpdateOrderCartJob.perform_later(mailchimp_cart)
      end

      def create_mailchimp_cart
        return if mailchimp_cart_created

        ::SpreeMailchimpEcommerce::CreateOrderCartJob.perform_later(mailchimp_cart)
        update_column(:mailchimp_cart_created, true)
      end

      def after_ship_jobs
        order_shipped_notification
        update_mailchimp_order
      end

      def after_refund_jobs
        order_refunded_notification
        update_mailchimp_order
      end

      private

      def after_create_jobs
        new_order_notification
        create_mailchimp_order
        delete_mailchimp_cart
      end

      def after_cancel_jobs
        order_canceled_notification
        update_mailchimp_order
      end

      def delete_mailchimp_cart
        ::SpreeMailchimpEcommerce::DeleteCartJob.perform_later(number)
      end

      def create_mailchimp_order
        ::SpreeMailchimpEcommerce::CreateOrderJob.perform_later(mailchimp_order)
      end

      def update_mailchimp_order
        ::SpreeMailchimpEcommerce::UpdateOrderJob.perform_now(self)
      end

      def new_order_notification
        @notification = ::SpreeMailchimpEcommerce::Presenters::OrderNotificationPresenter.new(self).invoice_or_order_confirmation
      end

      def order_canceled_notification
        @notification = ::SpreeMailchimpEcommerce::Presenters::OrderNotificationPresenter.new(self).cancellation_confirmation
      end

      def order_shipped_notification
        @notification = ::SpreeMailchimpEcommerce::Presenters::OrderNotificationPresenter.new(self).shipping_confirmation
      end

      def order_refunded_notification
        @notification = ::SpreeMailchimpEcommerce::Presenters::OrderNotificationPresenter.new(self).refund_confirmation
      end
    end
  end
end
Spree::Order.prepend(Spree::SpreeMailchimpEcommerce::OrderDecorator)
