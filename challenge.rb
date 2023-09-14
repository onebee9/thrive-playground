class CompanyReportGenerator
  def initialize(user_data_file, company_data_file)
    @user_data = JSON.parse(File.read(user_data_file))
    @company_data = JSON.parse(File.read(company_data_file))
  end

  def generate_output_file
    formatted_output = sorted_output_data.map { |data| format_output_data(data) }
    File.open('output.txt', 'a') do |file|
      file.puts(formatted_output)
    end
  end

  def sorted_output_data
    output_data.sort_by do |report|
      [report[:"Company Id"], report&.dig('Users Emailed', :last_name), report&.dig('Users Not Emailed', :last_name)]
    end
  end

  def output_data
    output_data = []
    @company_data.each do |company|
      output_data << {
        "Company Id": company['id'],
        "Company Name": company['name'],
        "Users Emailed": email_notification_list(company['id']),
        "Users Not Emailed": email_exclusion_list(company['id']),
        "Total amount of top ups for #{company['name']}": total_top_ups_by_company(company['id'])
      }
    end
    output_data
  end

  def total_top_ups_by_company(company_id)
    user_top_up_data.select { |user| user[:company_id] == company_id }
                    .sum { |user| user[:"New Token Balance"] - user[:"Previous Token Balance"] }
  end

  def user_top_up_data
    user_token_data = []

    @user_data.each do |user|
      company = company_data_by_id[user['company_id']]
      next unless user['active_status'] && company

      updated_token_balance = user['tokens'].to_i + company['top_up']
      user_token_data << {
        "id": user['id'],
        "company_id": user['company_id'],
        "Previous Token Balance": user['tokens'],
        "New Token Balance": updated_token_balance
      }
    end

    user_token_data
  end

  def email_notification_list(company_id)
    @user_data
      .select { |user| validate_user_email_status(user, company_id) }
      .group_by { |selected_user| selected_user['company_id'] }
      .fetch(company_id, [])
  end

  def email_exclusion_list(company_id)
    @user_data
      .reject { |user| validate_user_email_status(user, company_id) }
      .group_by { |user| user['company_id'] }
      .fetch(company_id, [])
  end

  private

  def format_output_data(company_data)
    formatted_output = <<~OUTPUT
      Company Id: #{company_data[:"Company Id"]}
      Company Name: #{company_data[:"Company Name"]}

    OUTPUT

    formatted_output += format_email_list('Users Emailed', company_data[:"Users Emailed"])
    formatted_output += format_email_list('Users Not Emailed', company_data[:"Users Not Emailed"])
    formatted_output += "Total amount of top ups for #{company_data[:"Company Name"]}: #{company_data[:"Total amount of top ups for #{company_data[:"Company Name"]}"]}\n\n\n"

    formatted_output
  end

  def format_user_data(user)
    "#{user['last_name']}, #{user['first_name']}, #{user['email']}\n" \
    "  Previous Token Balance, #{user['tokens']}\n" \
    "  New Token Balance #{user['tokens'] * 2}\n"
  end

  def format_email_list(email_list_type, users)
    return "#{email_list_type}:\n - \n" if users.nil? || users.empty?

    "#{email_list_type}:\n #{users.map { |user| format_user_data(user) }.join}\n"
  end

  def validate_user_email_status(user, company_id)
    company = @company_data.find { |data| data['id'] == company_id }
    company && company['email_status'] && user['email_status']
  end

  def company_data_by_id
    @company_data.each_with_object({}) do |company, hash|
      hash[company['id']] = company
    end
  end
end

report_generator = CompanyReportGenerator.new('./users.json', './companies.json')
report_generator.generate_output_file
