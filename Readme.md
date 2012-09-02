# WhichBus
[![build status](https://secure.travis-ci.org/whichbus/whichbus.png?branch=master)](https://secure.travis-ci.org/whichbus/whichbus)

WhichBus is a simple, _beautiful_ way to navigate public transit.

1. Real-Time Schedules
2. Multi-Modal Trip Planning
3. On all your gadgets

## Install

```bash
bundle install
bundle exec rake db:migrate
```
### Running

```bash
bundle exec rails s
```

### How to add crime data

1. Download to tmp/Seattle_Police_Department_Police_Report_Incident.csv from https://data.seattle.gov/Public-Safety/Seattle-Police-Department-Police-Report-Incident/7ais-f98f
2. Load the crime data
3. Generate db/crime_seed.csv
4. Load Stop Saftey

```bash
cd tmp
curl https://data.seattle.gov/api/views/7ais-f98f/rows.csv\?accessType\=DOWNLOAD | sed -n '/[^,]/p' > Seattle_Police_Department_Police_Report_Incident.csv
bundle exec rake load_crime_csv
bundle exec rake compute_crime_locally
bundle exec rake load_stop_safety_csvx
```

If you already have the updated `db/crime_seed.csv`, then you only need to run `rake load_stop_safety_csv`

## Test

`bundle rake`


## About 

WhichBus was created at the January 2012 Startup Weekend in Seattle where it received the award for “Best Design.” We continued to develop the app at the April 2012 Startup Weekend focused on Seattle Government data where WhichBus received the award for “Best Overall Business.” Since then, we’ve been hard at work building out the site and testing the user experience.

### Team
* Gilad Gray, *Team Lead/Developer*
* Eugeniy Kalinin, *Developer*
* Kim Manis, *UX Design*
* Daniel Miller, *Developer*
* Paige Pauli, *UX/UI Design/Front-End Development*
* Farrin Reid, *Developer
* Dave Rigotti, *Business/Marketing*
* Joe Schulman, *Developer/UX Designer*

[![logo](https://raw.github.com/whichbus/whichbus/master/app/assets/images/logo.png)](http://whichbus.org)
Copyright &copy; 2012 **WhichBus**