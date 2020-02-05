view: zipcode_station {
  sql_table_name: bike_trips.zipcode_station ;;

  dimension: forecast_date {
    type: string
    sql: ${TABLE}.forecast_date ;;
  }

  dimension: humidity {
    type: number
    sql: ${TABLE}.Humidity ;;
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

  measure: count {
    type: count
    drill_fields: []
  }
}
