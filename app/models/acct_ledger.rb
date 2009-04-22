class AcctLedger < ActiveRecord::Base
  #
  # These are accounts that get displayed with the ledger.
  # They are really display directives for a particular account balance.
  #
  has_many :accounts, :class_name => "AcctLedgerAccount",
                      :foreign_key => "ledger_id", :dependent => :destroy

  # This is the account we are ledgering.
  belongs_to :target_account, :class_name => "AcctAccount"

  validates_presence_of :name
  validates_presence_of :target_account

  before_save :generate_slug

  #
  # We can find this by the id number or our created slug
  #
  def self.find_by_id_or_slug(id)
    self.find_by_id(id) || self.find_by_slug(id)
  end

  def generate_slug
    if self.slug.empty?
      self.slug = self.name.downcase.gsub(/[^a-z0-9]+/i, '-')
    end
  end

  #
  # params => {
  #     accounts => {
  #         "0" => {
  #             account_id => 1, (will be nil, if not clicked.)
  #             show_if_aero => true,
  #             balances_in => true
  #             label => "Bank" },
  #         "1" => { .... },
  #    },
  #    subtotal_label => "",
  #    total_label => "",
  #    slug => "",
  #    name => ""
  #    target_account_id => "1",
  #    description => "..."
  # }
  def initialize(params = nil)
    if params && params[:accounts]
      # Only select the accounts that were clicked.
      params[:accounts] =
        params[:accounts].select { |k,v| v[:account_id] }
      # Change the params to the actual object.
      params[:accounts] =
        params[:accounts].map {|k,v| AcctLedgerAccount.new(v) }
    end
    super
    self.subtotal_label ||= "Subtotal"
    self.total_label ||= "Total"
    self
  end

  def update_attributes(params)
    if params && params[:accounts]
      # TODO: Find out if we really need this accounts.clear.
      accounts.clear
      # Only select the accounts that were clicked.
      params[:accounts] =
        params[:accounts].select { |k,v| v[:account_id] }
      # Change the params to the actual object.
      params[:accounts] =
        params[:accounts].map {|k,v| AcctLedgerAccount.new(v) }
    end
    super
  end

  #
  # Returns the display frames for the accounts that balance in.
  #
  def balance_accounts
    accounts.select { |x| x.balances_in }
  end

  #
  # Returns the display frames for the accounts that do not balance in.
  #
  def nonbalance_accounts
    accounts.reject { |x| x.balances_in }
  end

  #
  # Returns the "bottom line" of the balance of the ledger, which means
  # the target account and the balance in accounts.
  #
  def ledger_balance
    # Ugg, again, no foldl or reduce
    bal = target_account.balance
    balance_accounts.each { |a| bal += a.account.balance }
    return bal
  end
end
