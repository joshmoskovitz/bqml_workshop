view: weather {
  sql_table_name: bike_trips.weather ;;

  dimension_group: date {
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
    datatype: date
    sql: ${TABLE}.Date ;;
  }

  dimension: events {
    type: string
    sql: ${TABLE}.Events ;;
  }

  dimension: max_humidity {
    type: number
    sql: ${TABLE}.Max_Humidity ;;
  }

  dimension: max_temperature_f {
    type: number
    sql: ${TABLE}.Max_Temperature_F ;;
  }

  dimension: max_wind_speed_mph {
    type: number
    sql: ${TABLE}.Max_Wind_Speed_MPH ;;
  }

  dimension: mean_humidity {
    type: number
    sql: ${TABLE}.Mean_Humidity ;;
  }

  dimension: mean_temperature_f {
    type: number
    sql: ${TABLE}.Mean_Temperature_F ;;
  }

  dimension: mean_wind_speed_mph {
    type: number
    sql: ${TABLE}.Mean_Wind_Speed_MPH ;;
  }

  dimension: min_humidity {
    type: number
    sql: ${TABLE}.Min_Humidity ;;
  }

  dimension: min_temperature_f {
    type: number
    sql: ${TABLE}.Min_TemperatureF ;;
  }

  dimension: precipitation_in {
    type: number
    sql: ${TABLE}.Precipitation_In ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
