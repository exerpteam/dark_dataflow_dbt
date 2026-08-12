
{% macro drop_model(model_name, schema_name=target.schema) %}

    {% set sql %}
        drop table if exists {{ target.database }}.{{ schema_name }}.{{ model_name }}
    {% endset %}

    {% do run_query(sql) %}

{% endmacro %}