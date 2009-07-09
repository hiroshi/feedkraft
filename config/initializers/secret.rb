Dir[Rails.root.join("../../shared/secret/initializers/*.rb")].sort.each do |path|
  load path
end
