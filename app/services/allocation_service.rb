class AllocationService
  def self.check_csv_for_errors(csv: , group:)
    errors = []
    if csv.nil? || csv.empty?
      errors << "csv is empty"
    else
      errors << "too many columns" if csv.first.length > 2

      csv.each_with_index do |row, index|
        email = row[0].downcase
        allocation_amount = row[1]
        errors << "malformed email address: #{email}" unless /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/.match(email)
        errors << "non-number allocation amount '#{allocation_amount}' for email: #{email}" unless is_number?(allocation_amount)
        if allocation_amount_overdrafts_member?(amount: allocation_amount, group: group, email: email)
          membership = membership_for(group: group, email: email)
          balance = membership ? membership.raw_balance : 0
          errors << "allocation amount of #{Money.new(allocation_amount * 100, group.currency_code).format} would overdraft member with email address #{email}, who currently has #{Money.new(balance * 100, group.currency_code).format}"
        end
      end
    end
    errors if errors.any?
  end

  def self.generate_csv_upload_preview(csv:, group:)
    csv.group_by { |row| row[0].downcase }.map do |email, rows|
      allocation_amount = rows.sum { |row| row[1].to_f }
      user = User.find_by_email(email)
      {
        id: user && user.is_member_of?(group) ? user.id : "",
        email: email,
        name: user && user.is_member_of?(group) ? user.name : "",
        allocation_amount: allocation_amount.round(2),
        new_member: !user || !user.is_member_of?(group)
      }
    end
  end

  private
    def self.is_number?(string)
      true if Float(string) rescue false
    end

    def self.membership_for(group:, email:)
      if user = User.find_by_email(email) && membership = Membership.find_by(member: user, group: group)
        membership
      end
    end

    def self.allocation_amount_overdrafts_member?(amount:, group:, email:)
      amount = amount.to_f
      if membership = membership_for(group: group, email: email)
        membership.raw_balance + amount < 0
      else
        amount < 0
      end
    end
end
