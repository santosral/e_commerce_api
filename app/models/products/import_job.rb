module Products
  class ImportJob
    include Mongoid::Document
    include Mongoid::Timestamps

    STATUSES = [ "pending", "processing", "success", "error" ]

    field :job_id, type: String
    field :status, type: String, default: "pending"
    field :valid_rows, type: Array, default: []
    field :invalid_rows, type: Array, default: []

    validates :status, inclusion: { in: STATUSES, message: "%{value} is not a valid status" }
  end
end
