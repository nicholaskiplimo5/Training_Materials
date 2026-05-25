DECLARE
    v_count NUMBER;
BEGIN
    ------------------------------------------------------------
    -- 1. CREATE TABLE
    ------------------------------------------------------------
    SELECT COUNT(*)
    INTO v_count
    FROM USER_TABLES
    WHERE TABLE_NAME = 'GIN_DEMO_SYSTEM_REPORTS';

    IF v_count = 0 THEN

        EXECUTE IMMEDIATE '
            CREATE TABLE GIN_DEMO_SYSTEM_REPORTS (
                RPT_CODE         NUMBER PRIMARY KEY,
                RPT_NAME         VARCHAR2(100),
                RPT_FILE_NAME    VARCHAR2(100),
                RPT_CREATED_BY       VARCHAR2(100)
            )';

        DBMS_OUTPUT.PUT_LINE(
            'Table GIN_DEMO_SYSTEM_REPORTS created successfully.'
        );

    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Table GIN_DEMO_SYSTEM_REPORTS already exists.'
        );
    END IF;


    ------------------------------------------------------------
    -- 2. CREATE SEQUENCE
    ------------------------------------------------------------
    SELECT COUNT(*)
    INTO v_count
    FROM USER_SEQUENCES
    WHERE SEQUENCE_NAME = 'GIN_DEMO_SYSTEM_REPORTS_SEQ';

    IF v_count = 0 THEN

        EXECUTE IMMEDIATE '
            CREATE SEQUENCE GIN_DEMO_SYSTEM_REPORTS_SEQ
            START WITH 1
            INCREMENT BY 1
            NOCACHE
            NOCYCLE';

        DBMS_OUTPUT.PUT_LINE(
            'Sequence GIN_DEMO_SYSTEM_REPORTS_SEQ created successfully.'
        );

    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Sequence GIN_DEMO_SYSTEM_REPORTS_SEQ already exists.'
        );
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE(
            'Error: ' || SQLERRM
        );
END;
/