{% macro expect_column_values_to_be_positive(model, column_name) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} < 0
{% endmacro %} 