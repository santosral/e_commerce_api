json.extract! @import_job, :id, :job_id, :status, :valid_rows, :invalid_rows,  :created_at, :updated_at
json.url import_job_products_url(@import_job, format: :json)
