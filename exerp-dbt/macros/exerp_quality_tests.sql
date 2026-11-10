{% test exerp_unique_key(model, column_names) %}
select
    {% for column in column_names %}{{ adapter.quote(column) }}{% if not loop.last %}, {% endif %}{% endfor %},
    count(*) as duplicate_count
from {{ model }}
group by {% for column in column_names %}{{ adapter.quote(column) }}{% if not loop.last %}, {% endif %}{% endfor %}
having count(*) > 1
{% endtest %}

{% test exerp_relationships(model, to, column_names, to_column_names) %}
select child.*
from {{ model }} as child
where
    {% for column in column_names %}child.{{ adapter.quote(column) }} is not null and
    {% endfor %}not exists (
        select 1 from {{ to }} as parent
        where {% for column in column_names %}child.{{ adapter.quote(column) }} = parent.{{ adapter.quote(to_column_names[loop.index0]) }}{% if not loop.last %} and {% endif %}{% endfor %}
    )
{% endtest %}

{% macro exerp_sql_literal(value) -%}
    {%- if value is none -%}null
    {%- elif value is number -%}{{ value }}
    {%- else -%}'{{ value | string | replace("'", "''") }}'
    {%- endif -%}
{%- endmacro %}

{% test exerp_decode_matches(model, column_name, input_column, mapping, default_value=none) %}
with decoded as (
    select {{ adapter.quote(column_name) }} as actual_value,
           case {{ adapter.quote(input_column) }}
               {% for item in mapping %}when {{ exerp_sql_literal(item['code']) }} then {{ exerp_sql_literal(item['label']) }}
               {% endfor %}else {{ exerp_sql_literal(default_value) }}
           end as expected_value
    from {{ model }}
)
select * from decoded
where actual_value <> expected_value
   or (actual_value is null and expected_value is not null)
   or (actual_value is not null and expected_value is null)
{% endtest %}
