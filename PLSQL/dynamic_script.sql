DECLARE
    v_rpt_code   NUMBER;
    v_count      NUMBER;
    v_max        NUMBER;
    q_r          VARCHAR2(4000);
BEGIN
    -- 1. CHECK IF REPORT ALREADY EXISTS
    BEGIN
        SELECT COUNT (*)
          INTO v_count
          FROM TQC_SYSTEM_REPORTS
         WHERE RPT_DATA_FILE = 'claims_summary.xml';
    EXCEPTION
        WHEN OTHERS THEN
            v_count := 0;
    END;

    IF v_count = 0 THEN
        -- GET NEW RPT_CODE
        SELECT MAX (rpt_code) INTO v_rpt_code FROM tqc_system_reports;
        v_rpt_code := v_rpt_code + 1;

        -- INSERT REPORT HEADER (Claims Summary Report)
        EXECUTE IMMEDIATE 'Insert into TQC_SYSTEM_REPORTS
            (RPT_CODE, RPT_SYS_CODE, RPT_NAME, RPT_DESCRIPTION, RPT_DATA_FILE, 
             RPT_APPLCTN_LEVEL, RPT_ACTIVE, RPT_RSM_CODE, RPT_ORDER, RPT_PRNT_SRV_APPL, RPT_PRINT_SRVC_APPL)
          Values
            (' || v_rpt_code || ', 37, ''CLAIMS_SUMMARY_RPT'', ''Claims Summary Report'', ''claims_summary.xml'', 
             NULL, ''A'', 14, NULL, ''Y'', ''N'')';

        -- 2. INSERT TEMPLATE
        BEGIN
            SELECT COUNT (*) INTO v_count FROM tqc_sys_rpt_templates WHERE rpt_tmpl_rpt_code = v_rpt_code;
            IF v_count = 0 THEN
                SELECT MAX (rpt_tmpl_code) INTO v_max FROM tqc_sys_rpt_templates;
                v_max := NVL(v_max, 0) + 1;

                EXECUTE IMMEDIATE 'Insert into TQC_SYS_RPT_TEMPLATES
                    (RPT_TMPL_CODE, RPT_TMPL_RPT_CODE, RPT_TMPL_FILE, RPT_TMPL_NAME, RPT_TMPL_DESCRIPTION, 
                     RPT_TMPL_STYLE_FILE, RPT_TMPL_ORG_CODE, RPT_TMPL_ACTIVE)
                  Values
                    (' || v_max || ', ' || v_rpt_code || ', ''claims_summary_template.rtf'', ''CLAIMS_SUMMARY_RPT'', ''Claims Summary Report'', 
                     ''claims_summary_template.xsl'', NULL, ''A'')';
            END IF;
        END;

        -- 3. PARAMETERS SECTION

        -- PARAMETER: FROMDT
        SELECT MAX(RPTP_CODE) INTO v_max FROM TQC_SYS_RPT_PARAMETERS;
        v_max := v_max + 1;
        EXECUTE IMMEDIATE 'INSERT INTO TQC_SYS_RPT_PARAMETERS (RPTP_CODE, RPTP_RPT_CODE, RPTP_PARAM_NAME, RPTP_PARAM_DESC, RPTP_PARAM_PROMPT, RPTP_PARAM_TYPE, RPTP_PARAM_ACTIVE, RPTP_USER_REQUIRED) 
            VALUES (' || v_max || ', ' || v_rpt_code || ', ''FROMDT'', ''FROM DATE'', ''From Date'', ''DATE'', ''A'', ''N'')';

        -- PARAMETER: TODT
        v_max := v_max + 1;
        EXECUTE IMMEDIATE 'INSERT INTO TQC_SYS_RPT_PARAMETERS (RPTP_CODE, RPTP_RPT_CODE, RPTP_PARAM_NAME, RPTP_PARAM_DESC, RPTP_PARAM_PROMPT, RPTP_PARAM_TYPE, RPTP_PARAM_ACTIVE, RPTP_USER_REQUIRED) 
            VALUES (' || v_max || ', ' || v_rpt_code || ', ''TODT'', ''TO DATE'', ''To Date'', ''DATE'', ''A'', ''N'')';

        -- PARAMETER: P_CURRENCY (LOV)
        v_max := v_max + 1;
        q_r := 'INSERT INTO TQC_SYS_RPT_PARAMETERS (RPTP_CODE, RPTP_RPT_CODE, RPTP_PARAM_NAME, RPTP_PARAM_DESC, RPTP_PARAM_PROMPT, RPTP_PARAM_TYPE, RPTP_QUERY, RPTP_PARAM_ACTIVE, RPTP_USER_REQUIRED) 
            VALUES (' || v_max || ', ' || v_rpt_code || ', ''P_CURRENCY'', ''Currency'', ''Currency'', ''LOV'', 
            ''SELECT ''''-2000'''',''''(ALL IN BASE CURRENCY)'''' FROM dual UNION SELECT TO_CHAR(CUR_CODE),CUR_DESC FROM TQC_CURRENCIES ORDER BY 1'', ''A'', ''N'')';
        EXECUTE IMMEDIATE q_r;

        -- PARAMETER: P_SUMM (LOV - Yes/No)
        v_max := v_max + 1;
        q_r := 'INSERT INTO TQC_SYS_RPT_PARAMETERS (RPTP_CODE, RPTP_RPT_CODE, RPTP_PARAM_NAME, RPTP_PARAM_DESC, RPTP_PARAM_PROMPT, RPTP_PARAM_TYPE, RPTP_QUERY, RPTP_PARAM_ACTIVE, RPTP_USER_REQUIRED) 
            VALUES (' || v_max || ', ' || v_rpt_code || ', ''P_SUMM'', ''Report Summary?'', ''Report Summary?'', ''LOV'', 
            ''SELECT ''''Y'''',''''YES'''' FROM dual UNION SELECT ''''N'''',''''NO'''' FROM DUAL ORDER BY 2'', ''A'', ''N'')';
        EXECUTE IMMEDIATE q_r;

        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Report already exists.');
    END IF;
END;