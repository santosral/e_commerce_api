module Products
  class ImportJobsController < ApplicationController
    include FileUploadable

    before_action :set_import_job, only: :show

    # POST products/import_jobs
    # POST products/import_jobs.json
    def create
      @import_job = Products::ImportJob.create!(status: "pending")

      raise ActionController::ParameterMissing, "File parameter is required." if import_job_params[:file].blank?
      tempfile = create_tempfile(file: import_job_params[:file])

      job_id = Products::CsvParserJob.perform_async(tempfile.path, @import_job.id.to_s)

      if @import_job.update(job_id: job_id)
        render :show, status: :created
      else
        render json: @import_job.errors.messages, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error("Error: #{e.message}\nBacktrace:\n#{e.backtrace.join("\n")}")
      render json: { errors: e.message }, status: :unprocessable_entity
    end

    # GET products/import_jobs/:id
    # GET products/import_jobs/:id.json
    def show
      @import_job
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_import_job
        @import_job = Products::ImportJob.find(params[:id])
      end

      def import_job_params
        params.require(:import_job).permit(:file)
      end
  end
end
