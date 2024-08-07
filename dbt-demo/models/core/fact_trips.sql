{{
    config(
        materialized='table'
    )
}}

with green_tripdata as (
    select *,
    'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
),
yellow_tripdata as (
    select *,
    'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
),
union_trips as (
    select * from green_tripdata
    union all 
    select * from yellow_tripdata
),
dim_zones as (
    select * from {{ ref('dim_zones') }} 
    where borough != 'Unknown'
)
select union_trips.tripid,
    union_trips.vendorid,
    union_trips.service_type,
    union_trips.ratecodeid,
    union_trips.pickup_locationid,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    union_trips.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough,
    dropoff_zone.zone as dropoff_zone,
    union_trips.pickup_datetime,
    union_trips.dropoff_datetime,
    union_trips.store_and_fwd_flag,
    union_trips.passenger_count,
    union_trips.trip_distance,
    union_trips.trip_type,
    union_trips.fare_amount,
    union_trips.extra,
    union_trips.mta_tax,
    union_trips.tip_amount,
    union_trips.tolls_amount,
    union_trips.ehail_fee,
    union_trips.improvement_surcharge,
    union_trips.total_amount,
    union_trips.payment_type,
    union_trips.payment_type_description
from union_trips
inner join dim_zones as pickup_zone 
on union_trips.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on union_trips.dropoff_locationid = dropoff_zone.locationid