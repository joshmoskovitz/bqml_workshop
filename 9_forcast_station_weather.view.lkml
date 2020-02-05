view: forecast_station_weather {
  derived_table: {
    explore_source: station_weather_forecast {
      column: station_id { field: station.station_id }
      column: forecast_date { field: weather_forecast.forecast_date }
      column: humidity { field: weather_forecast.humidity }
      column: temperature { field: weather_forecast.temperature }
      filters: {
        field: weather_forecast.forecast_date
        value: "2018/06/16"
      }
      filters: {
        field: weather_forecast.snapshot_date
        value: "2018/06/15"
      }
    }
  }
  dimension: station_id {}
  dimension_group: forecast {
    timeframes: [raw,date]
    type: time
    sql: CAST(${TABLE}.forecast_date AS timestamp) ;;
  }
  dimension: humidity {
    type: number
  }
  dimension: temperature {
    type: number
  }
}
