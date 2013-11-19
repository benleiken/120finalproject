json.array!(@messages) do |message|
  json.extract! message, :content, :username, :created_at, :app_id, :active

end