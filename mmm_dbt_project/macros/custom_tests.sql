-- mmm_dbt_project/macros/custom_tests.sql

{% macro test_expect_column_values_to_be_positive(model, column_name) %}
-- This custom test checks if all values in a column are >= 0.
-- It will return the rows that fail this check (i.e., where column_name < 0).
select
    *
from {{ model }}
where {{ column_name }} < 0

{% endmacro %}