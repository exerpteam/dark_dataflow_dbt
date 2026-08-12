SELECT
    SCL.center,
    SCL.id,
    SCL.STATEID,
    scl.BOOK_START_TIME,
        scl.BOOK_end_TIME,
    scl.ENTRY_START_TIME ,
     scl.ENTRY_END_TIME 
FROM
     {{ source('postgres', 'state_change_log') }} scl
WHERE
    scl.ENTRY_TYPE = 1
