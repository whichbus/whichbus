require "net/http"
require "uri"
require "json"
require "csv"

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
## View data in browser: https://data.seattle.gov/Public-Safety/Seattle-Police-Department-Police-Report-Incident/7ais-f98f
## Original query: http://data.seattle.gov/resource/7ais-f98f.json?$where=within_circle(location,"+params[:latitude ].to_s+","+params[:longitude].to_s+","+params[:distance ].to_s+")"
## Example that they've turned off... http://data.seattle.gov/resource/7ais-f98f.json?$where=within_circle(location,47.5463409,-122.285454,100)


# Crimes worth reporting:
## 900 - homicide
## 1300 - assault (aggressive)
## 3500 - narcotics
# Spot-checking spots:
## North Seattle 47.7159996, -122.334221
## South Seattle 47.5463409, -122.285454
# Documentation:
## http://dev.socrata.com/querying-datasets
## Now need to post query... using the get request is no longer sufficient

task :load_safety_data => :environment do
  puts "Pulling crime data from socrata"
  
  Stop.all.each do |s|
    # If I wasn't lazy I'd wrap the request into a proper object...
    # but I am, and people don't use HEREDOCs enough :)
    # old id: 2648915 
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
          "columnId": 12108611
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
    uri = URI("https://data.seattle.gov/api/views/INLINE/rows.json?app_token=GaRYpsMwwlN2XduxIm9Ki09WE&method=getRows&start=0&length=50")
    req = Net::HTTP::Post.new(uri.path)
    
    req.body = post_query
    req['Content-type'] = "application/json"
    req['X-App-Token'] = 'GaRYpsMwwlN2XduxIm9Ki09WE'

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end
      
    data = JSON.parse(res.body)
    if(data["error"])
      puts data["message"]
      exit
    end
    puts data
    s.safety = 0
    data.each do |crime|
      # this is where you would change the code for a better fitness function
      # i.e. we may want to weight murder more than car theft...
      if crime["12108599"].to_s =~ /900|1300|3500/
          # removed 2400 - car theft - because it is too common
        puts "hit " + crime["12108599"].to_s + ", " + s.safety.to_s + ": " + crime["id"].to_s + " " +crime["12108610"].to_s + ", " + crime["12108609"]
        s.safety += 1
      end
    end
    puts " safety => #{s.safety}"
    s.save
  end
end

task :load_crime_csv => :environment do
    puts "Deleting existing crimes"
    Crime.delete_all()
    
    ## Note, the policy incident report is 60 MB so... you need to download it locally to temp
    ## URL: https://data.seattle.gov/Public-Safety/Seattle-Police-Department-Police-Report-Incident/7ais-f98f
    ## Then download as CSV to the tmp folder... and you're good to go!
    csv_text = File.read('tmp/Seattle_Police_Department_Police_Report_Incident.csv')
    csv = CSV.parse(csv_text, :headers => true)
    puts "Loaded police csv"
    
    csv.each do |row|
        puts "Creating new crime record - " + row['Summary Offense Code'] + " at " + row['Latitude'] + ", " + row['Longitude']
        c = Crime.new(:latitude=> row["Latitude"], :longitude=> row["Longitude"], :address=>row["Hundred Block Location"], :summary_code=>row["Summary Offense Code"])
        c.save
    end
    puts "DONEZO!"
end

task :load_stop_safety_csv => :environment do
    csv_text = File.read('db/crime_seed.csv')
    csv = CSV.parse(csv_text, :headers => false)
    puts "Loaded safety csv"
    
    csv.each do |row|
        s = Stop.where(:oba_id => row[0]).first
        s.safety = row[1]
        puts "Updating #{s.oba_id.to_s} with safety = #{s.safety.to_s}"
        s.save
    end
    puts "DONEZO!"
end


task :compute_crime_locally => :environment do
    puts "Finding matching stops"
    histogram = Array.new(12)
    
    csv_text = File.read('tmp/Seattle_Police_Department_Police_Report_Incident.csv')
    csv = CSV.parse(csv_text, :headers => true)
    puts "Loaded police csv"
    
    allCrime = Array.new()
    
    csv.each do |row|
        puts "Creating new crime record - " + row['Summary Offense Code'] + " at " + row['Latitude'] + ", " + row['Longitude']
        c = Crime.new(:latitude=> row["Latitude"], :longitude=> row["Longitude"], :address=>row["Hundred Block Location"], :summary_code=>row["Summary Offense Code"])
    end

    
    out_csv_text = File.open('db/crime_seed.csv', 'w')

    Stop.all.each do |s|
        s.safety = 0
        puts "Looking for crime near #{s.lat}, #{s.lon}"
        Crime.near([s.lat, s.lon], 0.12).each do |found|
        #Crime.find_within(0.25, :origin => [s.lat, s.lon]).each do |found|
            if(found.summary_code.to_s =~ /900|1300|3500/)
                puts "Hit " + found.summary_code.to_s + " near " + s.oba_id.to_s
                s.safety+=1
            else
                puts "No hit - summary code is " + found.summary_code.to_s
            end
        end
        
        histosave = s.safety
        if s.safety > 10 then histosave = 11
        end
        if(histogram[histosave] == nil) then histogram[histosave] = 0
        end
        histogram[histosave] += 1
        ## Saving the record is commented out since the goal of this task is to generate the csv file
        #s.save
        out_csv_text.write("#{s.oba_id.to_s},#{s.safety.to_s}\n")
    end
    
    out_csv_text.close()
    
    puts "Histogram Results:"
    histogram.each do |hist|
        puts hist.to_s
    end
    puts "DONEZO!"
end