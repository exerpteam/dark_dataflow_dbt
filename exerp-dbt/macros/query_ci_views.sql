{% macro query_ci_views(relations=none) %}
  {% if execute %}
    {% if relations is none %}
      {% set schema_name = target.schema | replace("'", "''") %}
      {% set views = run_query(
        "select distinct view_schema, view_name "
        ~ "from pg_get_late_binding_view_cols() "
        ~ "cols(view_schema name, view_name name, col_name name, "
        ~ "col_type varchar, col_num int) "
        ~ "where view_schema = '" ~ schema_name ~ "' "
        ~ "order by view_name"
      ) %}
      {% set discovered_relations = [] %}
      {% for row in views.rows %}
        {% do discovered_relations.append(
          adapter.quote(target.database) ~ '.'
          ~ adapter.quote(row[0]) ~ '.' ~ adapter.quote(row[1])
        ) %}
      {% endfor %}
      {% set relations = discovered_relations %}
    {% endif %}
    {% if relations | length == 0 %}
      {{ exceptions.raise_compiler_error("No built views were supplied for query checks") }}
    {% endif %}
    {% for relation in relations %}
      {% do log("Query-checking " ~ relation, info=true) %}
      {% do run_query("select * from " ~ relation ~ " limit 1") %}
    {% endfor %}
    {% do log("Query-checked " ~ (relations | length) ~ " CI view(s)", info=true) %}
  {% endif %}
{% endmacro %}
