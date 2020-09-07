rules.transit_time_filter_B178NTeTjQ = [==[
(application:"transittimemmapi"
OR
application:"transitimeintl"
OR
application:"transittimemmconsumer"
OR
application:"transittimescheduler"
OR
application:"ttemailnotification"
OR
application:"ttfirstmileapi"
OR
application:"ttlocationclient"
OR
application:"ttnotificationapi"
OR
application:"ttvmmclient"
OR
application:"ttuifirstmile"
OR
application:"ttuifirstmileapi"
OR
application:"transittimeapi")
AND environment == "prod" 
AND container == "app" 
AND level == "ERROR"
AND ! message->include?("sending the shuttleio")
AND ! message->include?("422 Unprocessable Entity")
AND ! message->include?("No Vendor IDs Found from Business Partner API with ID")
]==]
