# README

This is a tokenUpdater app that tops off a user's tokens if they meet specific criteria.

## Dependencies

run `gem install rspec`

## Tests

run `rspec spec` in the root folder `thrive-playground`

## Generate file

run `ruby -r ./challenge.rb -e "Challenge.call"` in the root folder `thrive-playground`.

## Structure(Class)

### DataImporter

*Description*

- For parsing files and initial file validation.

*Requirements Covered*

- Import and validate Input files

### CompanyDataManager

*Description*

- Processes application data from external sources, validating it and integrating it into the rest of the application.

*Requirements Covered*

- Generates report data for all companies
- Calculates the total top-up amount for a specific company
- Validate user and company email statuses for notifications
- Generates a list of users to be notified for a specific company based on defined constraints
- Generates a list of users to be excluded from notifications for a specific company
- Validates user and top-up attributes for generating user token data

### CompanyReportGenerator

*Description*

- Generates the required output file

*Requirements Covered*

- Format the report data to match specifications.
- Handles data sorting and presentation
- Creates the output file

### Challenge

*Description*

- Entry point class, injects data and runs the application.

## Possible Improvements

- Extend tests to cover more edge cases and guard clauses
- Batch processing, to optimize file import and processing

