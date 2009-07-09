Dir[Rails.root.join("../../shared/system/initializers/*.rb")].sort.each do |path|
  load path
end
