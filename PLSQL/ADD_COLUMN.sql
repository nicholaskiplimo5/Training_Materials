DECLARE
    v_count NUMBER;
BEGIN
    ------------------------------------------------------------
    -- CHECK IF COLUMN EXISTS
    ------------------------------------------------------------
    SELECT COUNT(*)
    INTO v_count
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'GIN_DEMO_SYSTEM_REPORTS'
    AND COLUMN_NAME = 'RPT_CREATED_AT';

    ------------------------------------------------------------
    -- ADD COLUMN IF IT DOES NOT EXIST
    ------------------------------------------------------------
    IF v_count = 0 THEN

        EXECUTE IMMEDIATE '
            ALTER TABLE GIN_DEMO_SYSTEM_REPORTS
            ADD RPT_CREATED_AT DATE
        ';

        DBMS_OUTPUT.PUT_LINE(
            'Column RPT_CREATED_AT added successfully.'
        );

    ELSE

        DBMS_OUTPUT.PUT_LINE(
            'Column RPT_CREATED_AT already exists.'
        );

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'Error adding column: ' || SQLERRM
        );
END;
/