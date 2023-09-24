require 'json'
require 'pry-byebug'
require_relative './custom_errors'

class DataImporter
  attr_reader :company_data

  def initialize(file_path)
    raise ArgumentError, 'File path is required' if file_path.nil? || file_path.empty?

    begin
      @company_data = load_json(file_path)
      puts "File '#{file_path}' successfully loaded and parsed."
    rescue JSON::ParserError => e
      raise DataImportError, "Error: File parsing failed - #{e.message}"
    rescue Errno::ENOENT => e
      raise FileNotFoundError, "Error: The file '#{e.path}' was not found."
    end
  end

  private

  def load_json(file_path)
    File.open(file_path, 'r') do |file|
      JSON.parse(file.read, symbolize_names: true)
      # JSON.parse(file.read)
    end
  rescue JSON::ParserError => e
    raise JSONParsingError, "Error: File parsing failed - #{e.message}"
  end
end
