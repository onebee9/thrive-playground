class CompanyDataManager
  def initialize(user_data, company_data)
    @user_data = user_data
    @company_data = company_data
  end

  def report_data
    sort_report_data(generate_report_data)
  end

  def total_top_ups_by_company(company_id)
    user_token_data
      .select { |user| user[:company_id] == company_id }
      .sum { |user| user[:new_token_balance] - user[:previous_token_balance] }
  end

  def email_notification_list(company_id)
    @user_data
      .select { |user| notification_status(user, company_id) }
      .group_by { |selected_user| selected_user['company_id'] }
      .fetch(company_id, [])
  end

  def email_exclusion_list(company_id)
    @user_data
      .reject { |user| notification_status(user, company_id) }
      .group_by { |user| user['company_id'] }
      .fetch(company_id, [])
  end

  def user_token_data
    @user_data.map do |user|
      top_up_amount = company_data_by_id[user['company_id']]&.fetch('top_up', nil)
      token_value = user&.fetch('tokens', nil)

      next unless validate_top_up_attributes(user, token_value, top_up_amount)

      updated_token_balance = token_value + top_up_amount

      {
        id: user['id'],
        company_id: user['company_id'],
        previous_token_balance: user['tokens'],
        new_token_balance: updated_token_balance
      }
    end.compact
  end

  private

  # Validation method
  def validate_top_up_attributes(user, token_value, top_up_amount)
    user['active_status'] && token_value.is_a?(Numeric) && top_up_amount.is_a?(Numeric)
  end

  def generate_report_data
    @company_data.map do |company|
      {
        company_id: company['id'],
        company_name: company['name'],
        users_emailed: email_notification_list(company['id']),
        users_not_emailed: email_exclusion_list(company['id']),
        total_top_ups: total_top_ups_by_company(company['id'])
      }
    end
  end

  def sort_report_data(report_data)
    report_data.sort_by do |report|
      [report[:company_id], report[:users_emailed].last&.dig(:last_name),
       report[:users_not_emailed].last&.dig(:last_name)]
    end
  end

  # enforcing strict conditions for this limited scope,
  # better implementation is to validate the file data upfront.
  def notification_status(user, company_id)
    company = company_data_by_id[company_id]

    user['active_status'] == true && user['email_status'] == true && company['email_status'] == true
  end

  def company_data_by_id
    @company_data.each_with_object({}) do |company, hash|
      hash[company['id']] = company
    end
  end
end
