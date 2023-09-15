require 'spec_helper'
require 'stringio'
require_relative '../lib/challenge'

RSpec.describe CompanyReportGenerator do
  let(:report_data) do
    [
      {
        company_id: 1,
        company_name: 'Amanda Clearfield Flowers',
        users_emailed: [],
        users_not_emailed: [],
        total_top_ups: 100
      }
    ]
  end
  subject(:report_generator) { described_class.new(report_data) }

  describe '#generate_output_file' do
    it 'generates the output file with formatted data' do
      # Create a StringIO object to capture the file content
      output = StringIO.new

      # Stub File.open to use StringIO instead of creating a real file
      allow(File).to receive(:open).with('./fixtures/output.txt', 'a').and_yield(output)
      # Call the method being tested
      report_generator.generate_output_file

      # Ensure that File.open was called with the correct arguments
      expect(File).to have_received(:open).with('./fixtures/output.txt', 'a')

      # Define the expected formatted data
      expected_output = <<~EXPECTED
        Company Id: 1
        Company Name: Amanda Clearfield Flowers

        Users Emailed:
         -#{' '}
        Users Not Emailed:
         -#{' '}
        Total amount of top ups for Amanda Clearfield Flowers: 100

      EXPECTED

      # Check if the captured output matches the expected output
      expect(output.string).to eq(expected_output)
    end
  end
end
