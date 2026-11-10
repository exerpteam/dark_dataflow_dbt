{% macro exerp_epoch_milliseconds_to_timestamp(epoch_milliseconds, time_zone="'UTC'") %}
    convert_timezone(
        'UTC',
        coalesce({{ time_zone }}, 'UTC'),
        dateadd(
            millisecond,
            mod({{ epoch_milliseconds }}, 1000)::integer,
            dateadd(
                second,
                ({{ epoch_milliseconds }} / 1000)::integer,
                timestamp '1970-01-01 00:00:00'
            )
        )
    )
{% endmacro %}

{% macro exerp_epoch_milliseconds_to_date(epoch_milliseconds) %}
    ({{ exerp_epoch_milliseconds_to_timestamp(epoch_milliseconds) }})::date
{% endmacro %}
