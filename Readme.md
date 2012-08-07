== WhichBus
!(Travis-CI Status)[https://secure.travis-ci.org/whichbus/whichbus.png?branch=master]
1. Real-Time Schedules
2. Multi-Modal Trip Planning
3. On all your gadgets


=== How to add crime data

1. Download to tmp/Seattle_Police_Department_Police_Report_Incident.csv from https://data.seattle.gov/Public-Safety/Seattle-Police-Department-Police-Report-Incident/7ais-f98f
  cd tmp
  curl https://data.seattle.gov/api/views/7ais-f98f/rows.csv\?accessType\=DOWNLOAD | sed -n '/[^,]/p' > Seattle_Police_Department_Police_Report_Incident.csv
2. load the crime data <code>rake load_crime_csv</code>
3. <code>rake compute_crime_locally</code> -> generate db/crime_seed.csv
4. <code>rake load_stop_safety_csvx</code>

If you already have the updated db/crime_seed.csv, then you only need to run <code>rake load_stop_safety_csv</code>