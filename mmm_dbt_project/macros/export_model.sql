-- macros/export_model.sql
{% macro export_model(model_name, output_path) %}
    {{ log("Exporting model " ~ model_name ~ " to " ~ output_path, info=True) }}
    {% set sql_statement %}
        COPY (SELECT * FROM {{ ref(model_name) }}) TO '{{ output_path }}' (HEADER, DELIMITER ',');
    {% endset %}
    {% do run_query(sql_statement) %}
    {{ log("Successfully exported model " ~ model_name, info=True) }}
{% endmacro %}