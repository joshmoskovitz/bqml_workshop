# If necessary, uncomment the line below to include explore_source.
# include: "bqml_demo.model.lkml"

view: trip_count_input {
  derived_table: {
    explore_source: trip {
      column: start_date {}
      column: humidity { field: daily_weather.humidity }
      column: temperature { field: daily_weather.temperature }
      column: trip_count {}
    }
  }
}

view: trip_count_regression {
  # 2019-08-21 Bruce - Set max iterations down to 50 from 100.  Getting error saying max allowable is 50
  derived_table: {
    datagroup_trigger: sweet_datagroup
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='linear_reg'
        , labels=['trip_count']
        , min_rel_progress = 0.05
        , max_iteration = 50
        ) AS
      SELECT
         * EXCEPT(start_date)
      FROM ${trip_count_input.SQL_TABLE_NAME};;
  }
}

######################## TRAINING INFORMATION #############################
explore:  trip_count_regression_evaluation {}
explore: trip_count_training {}

# VIEWS:
view: trip_count_regression_evaluation {
  derived_table: {
    sql: SELECT * FROM ml.EVALUATE(
          MODEL ${trip_count_regression.SQL_TABLE_NAME},
          (SELECT * FROM ${trip_count_input.SQL_TABLE_NAME})) ;;
  }
  dimension: mean_absolute_error {type: number}
  dimension: mean_squared_error {type: number}
  dimension: mean_squared_log_error {type: number}
  dimension: median_absolute_error {type: number}
  dimension: r2_score {type: number}
  dimension: explained_variance {type: number}
}

view: trip_count_training {
  derived_table: {
    sql: SELECT  * FROM ml.TRAINING_INFO(MODEL ${trip_count_regression.SQL_TABLE_NAME});;
  }
  dimension: training_run {type: number}
  dimension: iteration {type: number}
  dimension: loss {type: number}
  dimension: eval_loss {type: number}
  dimension: duration_ms {label:"Duration (ms)" type: number}
  dimension: learning_rate {type: number}
  measure: iterations {type:count}
  measure: total_loss {
    type: sum
    sql: ${loss} ;;
  }
  measure: total_training_time {
    type: sum
    label:"Total Training Time (sec)"
    sql: ${duration_ms}/1000 ;;
    value_format_name: decimal_1
  }
  measure: average_iteration_time {
    type: average
    label:"Average Iteration Time (sec)"
    sql: ${duration_ms}/1000 ;;
    value_format_name: decimal_1
  }
  set: detail {fields: [training_run,iteration,loss,eval_loss,duration_ms,learning_rate]}
}


################################ TRUE OUTPUTS ############################
explore:  trip_count_prediction {}
view: trip_count_prediction {
  derived_table: {
    sql: SELECT * FROM ml.PREDICT(
    MODEL ${trip_count_regression.SQL_TABLE_NAME},
    (SELECT * FROM ${trip_count_input.SQL_TABLE_NAME}));;
  }

  dimension: predicted_trip_count {
    type: number
  }

  dimension: residual {
    type:  number
    sql: ${predicted_trip_count} - ${trip_count}  ;;
  }
  dimension: residual_percent {
    type:  number
    value_format_name: percent_1
    sql: 1.0 * ${residual}/NULLIF(${trip_count},0)  ;;
  }

  dimension: start_date {
    type: date
    primary_key: yes
  }

  dimension: temperature {
    type: number
  }

  dimension: humidity {
    type: number
  }
  dimension: trip_count {
    type: number
  }
  measure: total_trip_count {
    type: max
    sql: ${predicted_trip_count} ;;
  }
  measure: overall_residual {
    type: max
    sql: ${residual} ;;
  }
  measure: overall_residual_percent {
    type: max
    value_format_name: percent_1
    sql: ${residual_percent} ;;
  }
}
