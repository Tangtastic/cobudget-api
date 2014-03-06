require 'playhouse/context'
require 'cobudget/entities/user'
require 'cobudget/entities/account'
require 'cobudget/composers/money_composer'

module Cobudget
  module Accounts
    class TransferFunds < Playhouse::Context
      actor :current_user
      actor :account, repository: Account, role: EntryCollection
      actor :to_account, repository: Account, role: EntryCollection
      actor :amount_dollars

      def perform
        user = User.find(current_user)
        puts account.inspect
        puts to_account.inspect
        transfer = TransferMoney.new(source_account: account, destination_account: to_account, amount: amount_dollars, creator: user)
        transfer.call
      end
    end
  end
end