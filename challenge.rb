require_relative './lib/data_importer'
require_relative './lib/company_data_manager'
require_relative './lib/company_report_generator'

class Challenge
  class << self
    attr_reader :user_data, :company_data, :report_data

    def call
      import_company_data
      import_user_data
      process_company_data
      generate_report
    end

    private

    def import_company_data
      data_loader = DataImporter.new('./lib/fixtures/companies.json')
      @company_data = data_loader.company_data
    end

    def import_user_data
      data_loader = DataImporter.new('./lib/fixtures/users.json')
      @user_data = data_loader.company_data
    end

    def process_company_data
      company_data_manager = CompanyDataManager.new(user_data, company_data)
      @report_data = company_data_manager.report_data
    end

    def generate_report
      report_generator = CompanyReportGenerator.new(report_data)
      report_generator.generate_output_file
    end
  end
end

Challenge.call
