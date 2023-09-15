# README

This is a tokenUpdater app, that tops off a users tokens if they meet specific criteria.

## Dependencies

run `bundle install`

## Tests

run `rspec spec` in the root folder `thrive-playground`.

## Quick Setup

Place the code block below in challenge.rb.

```data_loader = DataImporter.new('./fixtures/users.json')
user_data = data_loader.company_data

data_loader = DataImporter.new('./fixtures/companies.json')
company_data = data_loader.company_data

company_data_manager = CompanyDataManager.new(user_data, company_data)
report_data = company_data_manager.report_data

report_generator = CompanyReportGenerator.new(report_data)
report_generator.generate_output_file

```

cd `lib` and run `ruby challenge.rb`

The output file will be created in _/lib/fixtures_

## Structure(Class)

### DataImporter

Description

- For parsing files and initial file validation.

Requirements Covered

- Import and validate Input files

### CompanyDataManager

Description

- Processes application data from external sources, validating it, and integrating it into the rest of the application.

Requirements Covered

- Generates report data for all companies
- Calculates the total top-up amount for a specific company
- Validates user and company email statuses for notifications
- Generates a list of users to be notified for a specific company, based on defined constraints
- Generates a list of users to be excluded from notifications for a specific company
- Validates user and top-up attributes for generating user token data

### CompanyReportGenerator

Description

- Generates the required output file

Requirements Covered

- Formats the report data to match specification.
- Handles data sorting and presentation
- Creates the output file

## Possible Improvements

- Extend tests to cover more edge cases and guard clauses
- Fully set up test environment so we don't have to comment out the `quick set up` code block to run tests
- Batch processing, to optimize file import and processing
- Code clarity (suggestions are welcome!)
