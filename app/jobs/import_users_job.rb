class ImportUsersJob < ApplicationJob
  queue_as :default

  def perform(user_import_id)
    user_import = UserImport.find(user_import_id)
    user_import.update!(status: :processing, processed_count: 0, error_log: "")

    user_import.broadcast_replace_to user_import, target: "user_import_status"

    errors = []
    processed = 0

    begin
      spreadsheet = Roo::Spreadsheet.open(user_import.file.download, extension: :xlsx) # or :csv
      user_import.update!(total_count: spreadsheet.last_row - 1) # -1 for header

      spreadsheet.each_with_index do |row, idx|
        next if idx == 0 # Skip header row

        full_name, email = row[0], row[1] # Assuming Col A = Name, Col B = Email

        user = User.new(
          full_name: full_name,
          email: email,
          password: SecureRandom.hex(10) # Assign a random password
        )

        if user.save
          processed += 1
        else
          errors << "Row #{idx + 1}: #{user.errors.full_messages.join(', ')}"
        end

        if processed % 10 == 0 || idx == spreadsheet.last_row - 1
          user_import.update!(processed_count: processed)
          user_import.broadcast_update_to(
            user_import,
            target: "import_progress_bar",
            partial: "admin/user_imports/progress",
            locals: { import: user_import }
          )
        end
      end

      user_import.update!(status: :completed, error_log: errors.join("\n"))
    rescue => e
      user_import.update!(status: :failed, error_log: "Fatal error: #{e.message}")
    end

    user_import.broadcast_replace_to user_import, target: "user_import_status"
  end
end
