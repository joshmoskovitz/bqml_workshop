view: daily_weather {
  derived_table: {
    datagroup_trigger: sweet_datagroup
    sql:
      (
      SELECT
        weather.date AS weather_weather,
        weather.Events  AS weather_events,
        weather.mean_temperature_f AS weather_temperature,
        weather.mean_humidity AS weather_humidity,
        weather.mean_wind_speed_mph AS weather_wind_speed_mph
      FROM bike_trips.weather  AS weather
      )

      UNION ALL

      (SELECT
        -- weather.forecast_date AS weather_forecast_date
        DATE(timestamp(weather.forecast_date)) AS weather_weather_date,
      -- DATE(timestamp(forecast_date))
        weather.Status  AS weather_status,
        weather.Temperature  AS weather_temperature,
        weather.Humidity  AS weather_humidity,
        weather.Wind  AS weather_wind

      FROM bike_trips.weather_forecast  AS weather
      )
       ;;
  }

  dimension: date {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.weather_weather ;;
  }

  dimension_group: weather {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    sql: timestamp(${date});;
  }

  dimension: events {
    type: string
    sql: ${TABLE}.weather_events ;;
  }

  dimension: has_rained {
    type: number
    sql: IF(${events} LIKE '%Rain%',1,0) ;;
  }

  dimension: temperature {
    label: "Temperature (F)"
    type: number
    sql: ${TABLE}.weather_temperature ;;
  }


  # If there is no value for humidity, then set the humidity to the average value of humidity for seattle.
  dimension: humidity {
    type: number
    sql:  IF (${TABLE}.weather_humidity = 0, 90.0, ${TABLE}.weather_humidity) ;;
  }

  dimension: wind_speed_mph {
    type: number
    sql: ${TABLE}.weather_wind_speed_mph ;;
  }

  set: detail {
    fields: [weather_date, events, temperature, humidity, wind_speed_mph]
  }
}
