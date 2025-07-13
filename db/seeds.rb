# Clear existing data if needed (optional)
# Property.destroy_all
# ConsultationRequest.destroy_all

# Create admin user
AdminUser.find_or_create_by!(email: "admin@hamaragroup.in") do |admin|
  admin.password = "password"
  admin.password_confirmation = "password"
end

admin = User.find_or_create_by!(email: "admin@hamaragroup.in")
admin.update(password: "password", role: "admin")

# Member user - changed role to 'owner' to match enum
member = User.find_or_create_by!(email: "member@hamaragroup.in")
member.update(password: "password", role: "owner")

# Create dummy properties
5.times do |i|
  Property.find_or_create_by!(title: "Sample Property #{i+1}") do |property|
    property.description = "This is a dummy description for property #{i+1}."
    property.price = (10 + i) * 10_00_000
    property.location = "Delhi NCR"
    property.property_type = "Residential"
    property.user = admin
  end
end

# Create dummy consultation requests
3.times do |i|
  ConsultationRequest.find_or_create_by!(summary: "Need consultation for property purchase support #{i+1}.") do |request|
    request.full_name = "User #{i+1}"
    request.phone_number = "98765432#{i}"
    request.service_type = "Property Purchase Support"
    request.status = "pending"
    request.user = member
    request.property = Property.first
    request.supporting_document = nil
  end
end

puts "✅ Seeded dummy users, properties, and consultation requests safely."
