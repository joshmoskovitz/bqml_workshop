view: weather_forecast {
  sql_table_name: bike_trips.weather_forecast ;;

  dimension_group: forecast {
    type: time
    timeframes: [
      raw,
      date
    ]
    sql: CAST(${TABLE}.forecast_date AS timestamp) ;;
  }

  dimension: humidity {
    type: number
    sql: ${TABLE}.Humidity ;;
  }

  dimension_group: snapshot {
    type: time
    timeframes: [
      raw,
      date
    ]
    sql: ${TABLE}.snapshot_time ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.Status ;;
  }

  dimension: temperature {
    type: number
    sql: ${TABLE}.Temperature ;;
  }

  dimension: wind {
    type: number
    sql: ${TABLE}.Wind ;;
  }
}
