{% macro reset_ci_schema() %}
  {% if execute %}
    {% if modules.re.fullmatch('ci_pr_[0-9]+', target.schema) is none %}
      {{ exceptions.raise_compiler_error(
        'Refusing to reset non-CI schema: ' ~ target.schema
      ) }}
    {% endif %}

    {% set schema = adapter.quote(target.schema) %}
    {% do log('Resetting CI schema ' ~ schema, info=true) %}
    {% do run_query('drop schema if exists ' ~ schema ~ ' cascade') %}
    {% do run_query('create schema ' ~ schema) %}
  {% endif %}
{% endmacro %}
