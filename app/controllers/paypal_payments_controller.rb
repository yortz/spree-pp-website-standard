class PaypalPaymentsController < Spree::BaseController
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :verify_authenticity_token      
  before_filter :load_object, :only => :successful
  # Added by me to the default extension this way the filter before successfull action can associate current_user.email to order.email 
  # so that the state machine hook in site extension Order class_eval can send email to the user currently paying (logged in)
  before_filter :add_email, :only => :successful
  layout 'application'
  
  resource_controller
  belongs_to :order

  # NOTE: The Paypal Instant Payment Notification (IPN) results in the creation of a PaypalPayment
  create.after do
    # mark the checkout process as complete (even if the ipn results in a failure - no point in letting the user 
    # edit the order now) 
    @order.update_attribute("checkout_complete", true)              
    object.update_attributes(:email => params[:payer_email], :payer_id => params[:payer_id])
    ipn = Paypal::Notification.new(request.raw_post)

    # create a transaction which records the details of the notification
    object.txns.create(:transaction_id => ipn.transaction_id, 
                       :amount => ipn.gross, 
                       :fee => ipn.fee,
                       :currency_type => ipn.currency, 
                       :status => ipn.status, 
                       :received_at => ipn.received_at)
    if ipn.acknowledge
      case ipn.status
      when "Completed"
        if ipn.gross.to_d == @order.total
          @order.pay!
          @order.update_attribute("tax_amount", params[:tax].to_d) if params[:tax]
          @order.update_attribute("ship_amount", params[:mc_shipping].to_d) if params[:mc_shipping]          
        else
          @order.fail_payment!
          logger.error("Incorrect order total during Paypal's notification, please investigate (Paypal processed #{ipn.gross}, and order total is #{@order.total})")
        end
      when "Pending"
        @order.fail_payment!
        logger.info("Received an unexpected pending status for order: #{@order.number}")
      else
        @order.fail_payment!
        logger.info("Received an unexpected status for order: #{@order.number}")
      end
    else
      @order.fail_payment!
      logger.info("Failed to acknowledge Paypal's notification, please investigate [order: #{@order.number}]")
    end
  end

  create.response do |wants|
    wants.html do 
      render :nothing => true    
    end
  end

   # This is my addition to the default code it sets a filter before successfull so it adds the current_user.email
   def add_email
     @order.update_attribute("email", current_user.email)     
   end
   
  # Action for handling the "return to site" link after user completes the transaction on the Paypal website.  
  def successful 
    @order.update_attribute("ip_address", request.env['REMOTE_ADDR'] || "unknown")
    # its possible that the IPN has already been received at this point so that
    if @order.paypal_payments.empty?
      # create a payment and record the successful transaction
      paypal_payment = @order.paypal_payments.create(:email => params[:payer_email], :payer_id => params[:payer_id])
      paypal_payment.txns.create(:amount => params[:mc_gross].to_d, 
                                 :status => "Processed",
                                 :transaction_id => params[:txn_id],
                                 :fee => params[:payment_fee],
                                 :currency_type => params[:mc_currency],
                                 :received_at => params[:payment_date])
                                 # EXTRA FIELDS FOR SHIPMENT
                                 # :name => params[:address_name],
                                 #                                  :country => params[:address_country],
                                 #                                  :city => params[:address_city],
                                 #                                  :state => params[:address_state],
                                 #                                  :zip => params[:address_zip],
                                 #                                  :street => params[:address_street],
                                 #                                  :country_code => params[:address_country_code])
                                 # Added this so that it updates taxes in order and it then spits out correct values with updated total in order dertails
                                 @order.update_attribute("tax_amount", params[:payment_fee] )
                                 
                                 # COMMENTED THOSE OUT SINCE I AM NOT DOING ANY SHIPMENT FOR SUBSCRIPTIONS HERE
                                 # @order.update_attribute("ship_amount", params[:mc_shipping] )
                                 # @order.update_attribute("shipment_method", params[:shipping_method] )
                                 # @order.update_attribute("shipment_name", params[:address_name] )
                                 # @order.update_attribute("shipment_country", params[:address_country] )
                                 # @order.update_attribute("shipment_city", params[:address_city] )
                                 # @order.update_attribute("shipment_state", params[:address_state] )
                                 # @order.update_attribute("shipment_zip", params[:address_zip] )
                                 # @order.update_attribute("shipment_street", params[:address_street] )
                                 # @order.update_attribute("shipment_country_code", params[:address_country_code] )
                                 
      # advance the state
      @order.pend_payment! 
      
      # Addition to subscription, in this way I mark the current_user as subscribed once he pays for a virtual
      # product aka a subscriptions, so that I can then implement my own logic when he log in and try to buy another one.
      # current_user.update_attribute("subscribed", true)
       
    else
      paypal_payment = @order.paypal_payments.last
    end
    
    # remove order from the session (its not really practical to allow the user to edit the session anymore)
    session[:order_id] = nil
    
    if logged_in?
      @order.update_attribute("user", current_user)     
      redirect_to order_url(@order) and return
    else
      flash[:notice] = "Please create an account or login so we can associate this order with an account"
      session[:return_to] = "#{order_url(@order)}?payer_id=#{paypal_payment.payer_id}"
      redirect_to signup_path
    end
  end
end