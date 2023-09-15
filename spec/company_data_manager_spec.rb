require 'spec_helper'
require_relative '../lib/company_data_manager'

RSpec.describe CompanyDataManager do
  let(:user_data) do
    [
      { 'id' => 1, 'first_name' => 'Bob', 'last_name' => 'Boberson', 'email' => 'bob.boberson@test.com',
        'company_id' => 2, 'email_status' => false, 'active_status' => true, 'tokens' => 23 },
      { 'id' => 2, 'first_name' => 'John', 'last_name' => 'Boberson', 'email' => 'john.boberson@test.com', 'company_id' => 2,
        'email_status' => false, 'active_status' => false, 'tokens' => 15 },
      { 'id' => 3, 'first_name' => 'Paul', 'last_name' => 'Berry', 'email' => 'paul.berry@notreal.com', 'company_id' => 1,
        'email_status' => true, 'active_status' => true, 'tokens' => 19 },
      { 'id' => 4, 'first_name' => 'Jim', 'last_name' => 'Jimerson', 'email' => 'jim.jimerson@test.com', 'company_id' => 1,
        'email_status' => true, 'active_status' => false, 'tokens' => 10 },
      { 'id' => 5, 'first_name' => 'Genesis', 'last_name' => 'Carr', 'email' => 'genesis.carr@demo.com', 'company_id' => 1,
        'email_status' => 'maybe', 'active_status' => true, 'tokens' => 71 },
      { 'id' => 6, 'first_name' => 'Yvonne', 'last_name' => 'Perkins', 'email' => 'yvonne.perkins@notreal.com',
        'company_id' => 4, 'email_status' => false, 'active_status' => false, 'tokens' => 'twenty' },
      { 'id' => 7, 'first_name' => 'Yvonne', 'last_name' => 'Perkins', 'email' => 'yvonne.perkins@notreal.com',
        'company_id' => 10, 'email_status' => false, 'active_status' => false, 'tokens' => 3 },
      { 'id' => 8, 'first_name' => 'Bobby', 'last_name' => 'fay', 'email' => 'bob.boberson2@test.com',
        'company_id' => 2, 'email_status' => false, 'active_status' => true }
    ]
  end

  let(:company_data) do
    [
      { 'id' => 1, 'name' => 'Company A', 'email_status' => true, 'top_up' => 20 },
      { 'id' => 2, 'name' => 'Company B', 'email_status' => false, 'top_up' => 40 },
      { 'id' => 3, 'name' => 'Company C', 'email_status' => true, 'top_up' => 10 }
    ]
  end

  subject(:company_data_manager) { described_class.new(user_data, company_data) }

  describe '#total_top_ups_by_company' do
    it 'calculates the total top-ups per company correctly' do
      total_top_ups = company_data_manager.total_top_ups_by_company(2)

      expect(total_top_ups).to eq(40)
    end
  end

  describe '#email_notification_list' do
    it 'returns a list of users on the companys email notification list' do
      notification_list = company_data_manager.email_notification_list(1)

      expect(notification_list).to be_an(Array)
      expect(notification_list.count).to eq 1
    end
  end

  describe '#email_exclusion_list' do
    it 'returns a list of users on the companys email exclusion list' do
      exclusion_list = company_data_manager.email_exclusion_list(1)

      expect(exclusion_list).to be_an(Array)
      expect(exclusion_list.count).to eq 2
    end
  end

  describe '#user_top_up_data' do
    it 'correctly calculates user token top_ups' do
      user_token_data = company_data_manager.user_token_data

      expect(user_token_data).to be_an(Array)
      expect(user_token_data[0][:new_token_balance]).to eq 63
    end

    it 'does not top up users with an inactive status' do
      user_token_data = company_data_manager.user_token_data
      expect(user_token_data.count).to eq 3
    end
  end

  describe '#notification status validation' do
    it 'returns false for users with no email status && no active status in the company' do
      user = { 'id' => 2, 'company_id' => 1, 'email_status' => false }
      company_id = 1

      result = company_data_manager.send(:notification_status, user, company_id)

      expect(result).to be false
    end
  end
end
