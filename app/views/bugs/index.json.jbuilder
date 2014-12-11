json.array!(@bugs) do |bug|
  json.extract! bug, :id, :description, :tags
  json.url bug_url(bug, format: :json)
end
