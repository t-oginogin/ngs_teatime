json.array!(@jobs) do |job|
  json.extract! job, :id, :tool, :target_file_1, :target_file_2, :reference_genome, :comment, :status
  json.url job_url(job, format: :json)
end
