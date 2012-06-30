require "net/http"
require "uri"
require "json"

desc "Populate the crime data from socrata and randomly"

# To immediately unblock everyone with crime data
task :load_random_safety_data => :environment do
  puts "Assigning random safety data to all stops"
  Stop.all.each do |s|
    new_safety = rand(10)
    puts "#{s.oba_id} -> #{new_safety}"
    s.safety = new_safety
    s.save
  end
end

# This actually loads from socrata
## City of Seattle crime view is 7ais-f98f
## Base url = data.seattle.gov
## Original query: http://data.seattle.gov/resource/7ais-f98f.json?$where=within_circle(location,"+params[:latitude ].to_s+","+params[:longitude].to_s+","+params[:distance ].to_s+")"
# Crimes worth reporting:
## 900 - homicide
## 1300 - assault (aggressive)
## 3500 - narcotics
## 2400 - vehicle theft
# Spot-checking spots:
## North Seattle 47.7159996, -122.334221
## South Seattle 47.5463409, -122.285454
# Documentation:
## http://dev.socrata.com/querying-datasets
## Now need to post query... using the get request is no longer sufficient

task :load_safety_data => :environment do
  puts "Pulling crime data from socrata"
  
  http = Net::HTTP.new("data.seattle.gov")
  
  Stop.all.each do |s|
    # If I wasn't lazy I'd wrap the request into a proper object...
    # but I am, and people don't use HEREDOCs enough...
    post_query = <<HEREDOC
{
  "originalViewId": "7ais-f98f",
  "name": "Nearby Crimes",
  "query": {
    "filterCondition": {
      "type": "operator",
      "value": "within_circle",
      "children": [
        {
          "type": "column",
          "columnId": 2648915
        },
        {
          "type": "literal",
          "value": #{s.lat}
        },
        {
          "type": "literal",
          "value":  #{s.lon}
        },
        {
          "type": "literal",
          "value": 100
        }
      ]
    }
  }
}
HEREDOC
   
    puts "Processing stop #{s.oba_id} at #{s.lat},#{s.lon}"
    
    ## limiting to first 50 results
    request = Net::HTTP::Post.new("/api/views/7ais-f98f/rows.json?method=getRows&start=0&length=50")
    request.set_form_data(JSON.parse(post_query))
    response = http.request(request)
    
    data = JSON.parse(response.body)
    s.safety = 0
    data.each do |crime|
      # this is where you would change the code for a better fitness function
      # i.e. we may want to weight murder more than car theft...
      if crime["12108599"] =~ /900|1300|3500|2400/
        s.safety += 1
      end
    end
    puts " safety => #{s.safety}"
    s.save
  end
end