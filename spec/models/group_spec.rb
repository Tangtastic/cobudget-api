require 'rails_helper'

RSpec.describe Group, :type => :model do
	describe "#add_admin(user)" do
		it "adds user as an admin to the group" do
			group = create(:group)
			user = create(:user)
			group.add_admin(user)
			expect(group.memberships.find_by(member: user, is_admin: true)).to be_truthy
		end
	end

  describe "#balance" do
    context "if no allocations or contributions" do
      it "returns 0" do
        group = create(:group)
        expect(group.balance).to eq(0)
      end
    end
  end
end