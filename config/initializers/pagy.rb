# config/initializers/pagy.rb
# Require data_hash helper for rendering metadata hashes in APIs
require "pagy/toolbox/helpers/data_hash"

# Set default page limit to 25
Pagy::OPTIONS[:limit] = 25
