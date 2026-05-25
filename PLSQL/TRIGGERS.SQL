CREATE OR REPLACE TRIGGER test_triigger_training
BEFORE INSERT OR UPDATE
ON GIN_DEMO_SYSTEM_REPORTS
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
BEGIN
   :NEW.RPT_CREATED_AT := SYSDATE;
   
   raise_error(':NEW.RPT_CREATED_AT======' || :NEW.RPT_CREATED_AT);

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;
END test_triigger_training;
/






============================================

select * from GIN_DEMO_SYSTEM_REPORTS;

begin
 create_gin_demo_report_prc('DEMO1', 'DEMO_FIL1E');
end;




CREATE OR REPLACE PROCEDURE create_gin_demo_report_prc (
    v_report_name IN VARCHAR2,
    v_file_name   IN VARCHAR2
)
IS
BEGIN

    INSERT INTO GIN_DEMO_SYSTEM_REPORTS (
        RPT_CODE,
        RPT_NAME,
        RPT_FILE_NAME,
        RPT_CREATED_BY
    )
    VALUES (
        GIN_DEMO_SYSTEM_REPORTS_SEQ.NEXTVAL,
        v_report_name,
        v_file_name,
        'EMMANUEL'
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