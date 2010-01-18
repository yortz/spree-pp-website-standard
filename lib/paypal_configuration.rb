class PaypalConfiguration < Configuration

  # the url parameters should not need to be changed (unless paypal changes the api or something other major change)
  preference :sandbox_url, :string, :default => "https://www.sandbox.paypal.com/cgi-bin/webscr"
  preference :paypal_url, :string, :default => "https://www.paypal.com/cgi-bin/webscr"
  
  # these are just default preferences of course, you'll need to change them to something meaningful
  preference :account, :string, :default => "yortz_1226170417_biz@fastwebnet.it"
  preference :ipn_notify_host, :string, :default => "http://store.colorsoflife.org"
  preference :success_url, :string, :default => "http://store.colorsoflife.org/checkout/success"
  
  validates_presence_of :name
  validates_uniqueness_of :name
end