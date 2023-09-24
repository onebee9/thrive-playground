class CompanyReportGenerator
  attr_reader :company_data

  def initialize(report_data)
    @company_data = report_data
  end

  def generate_output_file
    formatted_company_data = company_data.map { |data| format_output_data(data) }

    begin
      File.open('./lib/fixtures/output.txt', 'a') do |file|
        file.puts(formatted_company_data)
      end

      puts "Output file: './lib/fixtures/output.txt' successfully generated."
    rescue StandardError => e
      puts "Error: Failed to generate output file - #{e.message}"
    end
  end

  private

  def format_output_data(company_data)
    formatted_output = <<~OUTPUT
      Company Id: #{company_data[:company_id]}
      Company Name: #{company_data[:company_name]}

    OUTPUT

    formatted_output += format_email_list('Users Emailed', company_data[:users_emailed])
    formatted_output += format_email_list('Users Not Emailed', company_data[:users_not_emailed])
    formatted_output += "Total amount of top ups for #{company_data[:company_name]}: #{company_data[:total_top_ups]}\n\n"

    formatted_output
  end

  def format_email_list(email_list_type, users)
    return "#{email_list_type}:\n - \n" if users.nil? || users.empty?

    "#{email_list_type}:\n #{users.map { |user| format_user_data(user) }.join}\n"
  end

  def format_user_data(user)
    "#{user[:last_name]}, #{user[:first_name]}, #{user[:email]}\n" \
    "  Previous Token Balance, #{user[:tokens]}\n" \
    "  New Token Balance #{user[:tokens] * 2}\n"
  end
end
