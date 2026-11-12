{% macro query_ci_views() %}
  {% if execute %}
    {% set schema_name = target.schema | replace("'", "''") %}
    {% set views = run_query(
      "select view_name from svv_all_views "
      ~ "where database_name = current_database() "
      ~ "and schema_name = '" ~ schema_name ~ "' "
      ~ "order by view_name"
    ) %}
    {% for row in views.rows %}
      {% set relation = adapter.get_relation(
        database=target.database, schema=target.schema, identifier=row[0]
      ) %}
      {% do log("Query-checking " ~ relation, info=true) %}
      {% do run_query("select * from " ~ relation ~ " limit 1") %}
    {% endfor %}
    {% do log("Query-checked " ~ (views.rows | length) ~ " CI view(s)", info=true) %}
  {% endif %}
{% endmacro %}
