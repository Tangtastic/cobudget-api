require 'playhouse/context'
require 'cobudget/entities/user'

module Cobudget
  module Users
    class Show < Playhouse::Context
      actor :user, repository: User

      def perform
        user.as_json
      end
    end
  end
end
