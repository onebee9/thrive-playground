class CompanyDataManager
  attr_reader :user_data, :company_data

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
    active_users
      .select { |user| notification_status(user, company_id) }
      .group_by { |selected_user| selected_user[:company_id] }
      .fetch(company_id, [])
  end

  def email_exclusion_list(company_id)
    active_users
      .reject { |user| notification_status(user, company_id) }
      .group_by { |user| user[:company_id] }
      .fetch(company_id, [])
  end

  # Updates the user's token value
  def user_token_data
    active_users.map do |user|
      top_up_amount = company_data_by_id[user[:company_id]]&.fetch(:top_up, nil)
      token_value = user&.fetch(:tokens, nil)

      next unless top_up_valid?(token_value, top_up_amount)

      {
        id: user[:id],
        company_id: user[:company_id],
        previous_token_balance: user[:tokens],
        new_token_balance: token_value + top_up_amount
      }
    end.compact
  end

  private

  # Validates all attributes required for user token top-up
  def top_up_valid?(token_value, top_up_amount)
    token_value.is_a?(Numeric) && top_up_amount.is_a?(Numeric)
  end

  def generate_report_data
    company_data.map do |company|
      company_id = company[:id]
      {
        company_id: company_id,
        company_name: company[:name],
        users_emailed: email_notification_list(company_id),
        users_not_emailed: email_exclusion_list(company_id),
        total_top_ups: total_top_ups_by_company(company_id)
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

    user[:email_status] == true && company[:email_status] == true
  end

  def company_data_by_id
    company_data.each_with_object({}) do |company, hash|
      hash[company[:id]] = company
    end
  end

  def active_users
    user_data.select { |user| user[:active_status] == true }
  end
end
