class OrderNotifier < ActionMailer::Base
   helper "spree/base"

   def pending(order, resend = false)
     @subject    = (resend ? "[RESEND] " : "") 
     @subject    += Spree::Config[:site_name] + ' Payment Processing' + 'Order Confirmation #' + order.number
     @body       = {"order" => order}
     @recipients = order.email
     @from       = Spree::Config[:order_from]
     @bcc        = order_bcc
     @sent_on    = Time.now
   end

   def payment(order, resend = false)
     @subject    = (resend ? "[RESEND] " : "")
     @subject    += Spree::Config[:site_name] + ' Shipping Notification' + 'Order Confirmation #' + order.number 
     @body       = {"order" => order}
     @recipients = order.email
     @from       = Spree::Config[:order_from]
     @bcc        = order_bcc
     @sent_on    = Time.now
   end  
   
   def failure(order, resend = false)
      @subject    = (resend ? "[RESEND] " : "")
      @subject    += Spree::Config[:site_name] + ' ' + 'Payment Failure Order #' + order.number
      @body       = {"order" => order}
      @recipients = order.email
      @from       = Spree::Config[:order_from]
      @bcc        = order_bcc
      @sent_on    = Time.now
    end

   private
   def order_bcc
     [Spree::Config[:order_bcc], Spree::Config[:mail_bcc]].delete_if { |email| email.blank? }.uniq
   end
end