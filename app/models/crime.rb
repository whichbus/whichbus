class Crime < ActiveRecord::Base
    attr_accessible :latitude, :longitude, :address, :summary_code, :time
    #geocoded_by :address               # can also be an IP address
    def geocoded_by
        "#{latitude}, #{longitude}"
    end
    after_validation :geocode          # auto-fetch coordinates
    reverse_geocoded_by :latitude, :longitude
    after_validation :reverse_geocode  # auto-fetch address
    
    
    #acts_as_mappable :default_units => :miles,
    #:default_formula => :sphere,
    #:distance_field_name => :distance,
    #:lat_column_name => :latitude,
    #:lng_column_name => :longitude
end
