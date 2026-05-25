CREATE OR REPLACE PROCEDURE create_gin_demo_report_prc (
    v_report_name IN VARCHAR2,
    v_file_name   IN VARCHAR2
)
IS
BEGIN

    INSERT INTO GIN_DEMO_SYSTEM_REPORTS (
        RPT_CODE,
        RPT_NAME,
        RPT_FILE_NAME
    )
    VALUES (
        GIN_DEMO_SYSTEM_REPORTS_SEQ.NEXTVAL,
        v_report_name,
        v_file_name
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Report "' || v_report_name || '" created successfully.'
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        DBMS_OUTPUT.PUT_LINE(
            'Error creating report: ' || SQLERRM
        );
END create_gin_demo_report_prc;
/