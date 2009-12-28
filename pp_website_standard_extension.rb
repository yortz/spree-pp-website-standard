# Uncomment this if you reference any of your controllers in activate
require 'pluginaweek-state_machine'
require_dependency 'application_controller'

=begin
unless RAILS_ENV == 'production'
  PAYPAL_ACCOUNT = 'joe@bidness.com'
  ActiveMerchant::Billing::Base.mode = :test
else
  PAYPAL_ACCOUNT = 'Gregg@railsenvy.com'
end
=end
class PpWebsiteStandardExtension < Spree::Extension
  version "0.6.x"
  description "Describe your extension here"
  url "http://github.com/Gregg/spree-pp-website-standard/tree/master"
  
  def activate
    
    ApplicationController.class_eval do
    
      # ADDED THIS METHOD SINCE IT WAS COMPLAINING IN PAYPAL PAYMENTS CONTROLLER (PP PAYMENT STANDARD EXTENSION)
      def logged_in?
              session = UserSession.find
              session && session.record
      end
    
    end

    # Add a partial for PaypalPayment txns
    Admin::OrdersController.class_eval do
      before_filter :add_pp_standard_txns, :only => :show
      
      def add_pp_standard_txns
        @txn_partials << 'pp_standard_txns'
      end
    end
    
    # Add a filter to the OrdersController so that if user is reaching us from an email link we can 
    # associate the order with the user (once they log in)
    OrdersController.class_eval do
      before_filter :associate_order, :only => :show
      # before_filter :find_order, :only => :create
      private
      def associate_order  
        return unless payer_id = params[:payer_id]
        orders = Order.find(:all, :include => :paypal_payments, :conditions => ['payments.payer_id = ? AND orders.user_id is null', payer_id])
        orders.each do |order|
          order.update_attribute("user", current_user)
        end
      end
      
      # def find_order
      # @order = Order.find_by_user_id(params[:current_user])
      # if @order
      #   flash[:notice] = "You already got an order"
      #   redirect_back_or_default
      # else
      #   @order.save
      #   flash[:notice] = "this is your first order"
      # end
      # end
    end

    # add new events and states to the FSM
    fsm = Order.state_machines[:state]  
    fsm.events["fail_payment"] = PluginAWeek::StateMachine::Event.new(fsm, "fail_payment")
    fsm.events["fail_payment"].transition(:to => 'payment_failure', :from => ['in_progress', 'payment_pending'])

    fsm.events["pend_payment"] = PluginAWeek::StateMachine::Event.new(fsm, "pend_payment")
    fsm.events["pend_payment"].transition(:to => 'payment_pending', :from => 'in_progress')    
    fsm.after_transition :to => 'payment_pending', :do => lambda {|order| order.update_attribute(:checkout_complete, true)}  

    fsm.events["pay"].transition(:to => 'paid', :from => ['payment_pending', 'in_progress'])
                                  
    Order.class_eval do 
      has_many :paypal_payments
    end
  end
  
  def deactivate
    # admin.tabs.remove "Spree Pp Website Standard"
  end
  
end