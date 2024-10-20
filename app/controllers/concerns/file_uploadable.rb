module FileUploadable
  extend ActiveSupport::Concern

  private

  # Don't forget to delete the file after completing the task
  def create_tempfile(file:, unique_id: "#{SecureRandom.uuid}#{Time.zone.now.to_i}")
    original_filename = file.original_filename
    base_name = File.basename(original_filename, File.extname(original_filename))
    extension = File.extname(original_filename)
    unique_path = "#{base_name}_#{unique_id}"
    tempfile  = Tempfile.new([ unique_path, extension ])

    tempfile.write(File.read(file.path))
    tempfile.rewind

    tempfile
  end
end
