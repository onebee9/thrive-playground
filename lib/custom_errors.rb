# Custom exception classes for better error handling
class DataImportError < StandardError; end
class FileNotFoundError < DataImportError; end
class FileGenerationFailed < StandardError; end
