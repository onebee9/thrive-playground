# Custom exceptions for clearer error handling

module Exceptions
  class DataImportError < StandardError
  end

  class FileNotFoundError < DataImportError
  end
end
