
########################## INPUT TABLES
#HISTORICAL DATA
view: start_station_training_input {
    derived_table: {
      datagroup_trigger: sweet_datagroup
      explore_source: trip {
        column: start_date {}
        column: station_id {field:trip.from_station_id}
        column: temperature { field: daily_weather.temperature }
        column: humidity { field: daily_weather.humidity }
        column: trip_count {}
      }
    }
  }
#HISTORICAL DATA
view: end_station_training_input {
  derived_table: {
    datagroup_trigger: sweet_datagroup
    explore_source: trip {
      column: start_date {}
      column: station_id {field:trip.to_station_id}
      column: temperature { field: daily_weather.temperature }
      column: humidity { field: daily_weather.humidity }
      column: trip_count {}
    }
  }
}
#LIVE DATA
view: station_real_input{
  derived_table: {
    datagroup_trigger: sweet_datagroup
    explore_source: station_forecasting {
      column: station_id { field: station.station_id }
      column: forecast_date { field: weather_forecast.forecast_date }
      column: temperature { field: weather_forecast.temperature }
      column: humidity { field: weather_forecast.humidity }
    }
  }
}

########################### MODEL TRAINING ########################
view: start_station_regression {
  derived_table: {
    datagroup_trigger: sweet_datagroup
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='linear_reg'
        , labels=['trip_count']
        , eval_split_method='no_split'
        , max_iteration = 50) AS
      SELECT
         * EXCEPT(start_date)
      FROM ${start_station_training_input.SQL_TABLE_NAME}
      LIMIT 100000;;
  }
}

view: end_station_regression {
  derived_table: {
    datagroup_trigger: sweet_datagroup
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='linear_reg'
        , labels=['trip_count']
        , eval_split_method='no_split'
        , max_iteration = 50) AS
      SELECT
         * EXCEPT(start_date)
      FROM ${end_station_training_input.SQL_TABLE_NAME}
      LIMIT 100000;;
  }
}


############################## MODEL OUTPUTS ####################
view: trip_start_count_prediction {
  derived_table: {
    sql: SELECT * FROM ml.PREDICT(
          MODEL ${start_station_regression.SQL_TABLE_NAME},
          (SELECT * FROM ${forecast_station_weather.SQL_TABLE_NAME}));;
    }
  dimension: predicted_trip_count {
    type: number
  }
  dimension: prim_key {hidden:yes sql:CONCAT(${station_id},${forecast_date}) ;;}
  dimension: station_id {}
  dimension_group: forecast {
    type: time
    timeframes: [raw,date]
    sql: CAST(${TABLE}.forecast_date AS timestamp) ;;
  }
  dimension: temperature {type: number}
  dimension: humidity {type: number}
  measure: predicted_bikes_leaving_station {
    type: max
    value_format_name: decimal_1
    sql: ${predicted_trip_count} ;;
  }

  measure: predicted_bikes_entering_station {
    type: max
    value_format_name: decimal_1
    sql: ${trip_end_count_prediction.predicted_trip_count} ;;
  }

  dimension: predicted_daily_surplus_raw {
    type: number
    hidden: yes
    value_format_name: decimal_1
    sql: ${trip_end_count_prediction.predicted_trip_count} - ${predicted_trip_count}   ;;
  }
  measure: predicted_daily_surplus {
    type: max
    value_format_name: decimal_1
    sql: ${predicted_daily_surplus_raw} ;;
  }
}

view: trip_end_count_prediction {
  derived_table: {
    sql: SELECT * FROM ml.PREDICT(
          MODEL ${end_station_regression.SQL_TABLE_NAME},
          (SELECT * FROM ${forecast_station_weather.SQL_TABLE_NAME}));;
  }
  dimension: predicted_trip_count {type: number}
  dimension: prim_key {hidden:yes sql:CONCAT(${station_id},${forecast_date}) ;;}
  dimension: station_id {hidden:yes}
  dimension: forecast_date {hidden:yes type: date}
#   dimension: temperature {type: number}
#   dimension: humidity {type: number}
  measure: total_predicted_trip_count {
    type: max
    sql: ${predicted_trip_count} ;;
  }
}
