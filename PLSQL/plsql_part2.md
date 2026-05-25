# PL/SQL Training Continuation

This training covers important PL/SQL concepts commonly used in enterprise systems such as Insurance, Banking, and ERP applications.

Topics Covered:

1. Dynamic SQL & Migration Scripts  
2. Triggers  
3. Records & Types in Functions & Procedures  
4. Tabs and Objects  
5. PL/SQL Architecture (Where to Add What)  
6. Common PL/SQL Errors and Fixes  

---

# 1. Dynamic SQL & Migration Scripts

## What is Dynamic SQL?

Dynamic SQL is SQL that is constructed and executed **at runtime** instead of being hardcoded.

Dynamic SQL is useful when:

- Table names are dynamic
- Column names are dynamic
- You are executing **DDL statements** (`CREATE`, `ALTER`, `DROP`)
- You are building reusable migration scripts
- You want flexible scripts with validations

Oracle uses:

```sql
EXECUTE IMMEDIATE
```

to execute dynamic SQL.

---

## 1.1 Static SQL Example (Hardcoded)

Below is a **static insert statement** for adding a report.

### Problem with Static SQL

- Hardcoded values
- Can fail during migration if ID already exists
- Difficult to reuse

```sql
INSERT INTO TQ_GIS.TQC_SYSTEM_REPORTS
(
    RPT_CODE,
    RPT_SYS_CODE,
    RPT_NAME,
    RPT_DESCRIPTION,
    RPT_DATA_FILE,
    RPT_APPLCTN_LEVEL,
    RPT_ACTIVE,
    RPT_RSM_CODE,
    RPT_ORDER,
    RPT_PRNT_SRV_APPL,
    RPT_PRINT_SRVC_APPL,
    RPT_SHT_DESC,
    RPT_UPDATE
)
VALUES
(
    113,
    1,
    'RECEIPT_ALLOCATION_BY_PRODUCT_LISTING',
    NULL,
    'FCBALL0C05.xml',
    NULL,
    'A',
    NULL,
    NULL,
    'N',
    'N',
    NULL,
    NULL
);
```

---

## 1.2 Dynamic SQL Example (Better Approach)

Instead of hardcoding `RPT_CODE`, we dynamically generate it.

### Benefits

- No hardcoding
- Safer for migrations
- Reusable
- Flexible

```sql
DECLARE
    v_rpt_code NUMBER;
    v_sql      VARCHAR2(4000);
BEGIN

    -- Get next report code dynamically
    EXECUTE IMMEDIATE '
        SELECT NVL(MAX(RPT_CODE),0) + 1
        FROM TQ_GIS.TQC_SYSTEM_REPORTS
    '
    INTO v_rpt_code;

    -- Build insert statement dynamically
    v_sql :=
        'INSERT INTO TQ_GIS.TQC_SYSTEM_REPORTS
        (
            RPT_CODE,
            RPT_SYS_CODE,
            RPT_NAME,
            RPT_DESCRIPTION,
            RPT_DATA_FILE,
            RPT_APPLCTN_LEVEL,
            RPT_ACTIVE,
            RPT_RSM_CODE,
            RPT_ORDER,
            RPT_PRNT_SRV_APPL,
            RPT_PRINT_SRVC_APPL,
            RPT_SHT_DESC,
            RPT_UPDATE
        )
        VALUES
        (
            ' || v_rpt_code || ',
            1,
            ''RECEIPT_ALLOCATION_BY_PRODUCT_LISTING'',
            NULL,
            ''FCBALL0C05.xml'',
            NULL,
            ''A'',
            NULL,
            NULL,
            ''N'',
            ''N'',
            NULL,
            NULL
        )';

    EXECUTE IMMEDIATE v_sql;

    DBMS_OUTPUT.PUT_LINE(
        'Report inserted successfully. Report Code: '
        || v_rpt_code
    );

END;
/
```

---

## 1.3 Better Dynamic SQL Using Bind Variables (Recommended)

This is cleaner and more secure.

### Why Use Bind Variables?

- Better performance
- Prevent SQL injection
- Cleaner code

```sql
DECLARE
    v_rpt_code NUMBER;
BEGIN

    SELECT NVL(MAX(RPT_CODE),0) + 1
    INTO v_rpt_code
    FROM TQ_GIS.TQC_SYSTEM_REPORTS;

    EXECUTE IMMEDIATE '
        INSERT INTO TQ_GIS.TQC_SYSTEM_REPORTS
        (
            RPT_CODE,
            RPT_SYS_CODE,
            RPT_NAME,
            RPT_DATA_FILE,
            RPT_ACTIVE
        )
        VALUES
        (
            :1,
            :2,
            :3,
            :4,
            :5
        )
    '
    USING
        v_rpt_code,
        1,
        'RECEIPT_ALLOCATION_BY_PRODUCT_LISTING',
        'FCBALL0C05.xml',
        'A';

    DBMS_OUTPUT.PUT_LINE(
        'Inserted Successfully: '
        || v_rpt_code
    );

END;
/
```

---

## 1.4 Create Table Example

Example demo table:

```sql
CREATE TABLE GIN_DEMO_SYSTEM_REPORTS
(
    RPT_CODE        NUMBER PRIMARY KEY,
    RPT_NAME        VARCHAR2(100),
    RPT_FILE_NAME   VARCHAR2(100),
    CREATED_DATE    DATE,
    CREATED_BY      VARCHAR2(100)
);
```

---

## 1.5 Sequence Creation

Instead of using `MAX + 1`, use sequences.

### Why Sequences?

`MAX + 1` can fail when many users insert at the same time.

Recommended approach:

```sql
CREATE SEQUENCE GIN_DEMO_SYSTEM_REPORTS_SEQ
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;
```

---

## 1.6 Dynamic Insert Using Sequence

```sql
DECLARE
    v_sql VARCHAR2(4000);
BEGIN

    v_sql :=
        'INSERT INTO GIN_DEMO_SYSTEM_REPORTS
        (
            RPT_CODE,
            RPT_NAME,
            RPT_FILE_NAME
        )
        VALUES
        (
            GIN_DEMO_SYSTEM_REPORTS_SEQ.NEXTVAL,
            :1,
            :2
        )';

    EXECUTE IMMEDIATE v_sql
    USING
        'POLICY_REPORT',
        'policy.xml';

    DBMS_OUTPUT.PUT_LINE(
        'Record inserted successfully'
    );

END;
/
```

---

# 1.7 Migration Scripts

Migration scripts are scripts used to:

- Add columns
- Modify columns
- Create tables
- Add indexes
- Add constraints
- Deploy changes safely

Migration scripts should be **rerunnable**.

Meaning:

Running them again should not fail.

---

## Add Column Migration Script

### Problem

This fails if column already exists:

```sql
ALTER TABLE GIN_PRODUCTS
ADD PRO_TRAVEL VARCHAR2(1);
```

### Better Migration Script

```sql
DECLARE
    v_count NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'GIN_PRODUCTS'
    AND COLUMN_NAME = 'PRO_TRAVEL';

    IF v_count = 0 THEN

        EXECUTE IMMEDIATE '
            ALTER TABLE GIN_PRODUCTS
            ADD PRO_TRAVEL VARCHAR2(1)
        ';

        DBMS_OUTPUT.PUT_LINE(
            'Column Added Successfully'
        );

    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Column Already Exists'
        );
    END IF;

END;
/
```

---

## Creating Table Migration Script

```sql
DECLARE
    v_count NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM USER_TABLES
    WHERE TABLE_NAME =
          'GIN_DEMO_SYSTEM_REPORTS';

    IF v_count = 0 THEN

        EXECUTE IMMEDIATE '
            CREATE TABLE
            GIN_DEMO_SYSTEM_REPORTS
            (
                RPT_CODE NUMBER PRIMARY KEY,
                RPT_NAME VARCHAR2(100),
                RPT_FILE_NAME VARCHAR2(100),
                CREATED_DATE DATE,
                CREATED_BY VARCHAR2(100)
            )
        ';

        DBMS_OUTPUT.PUT_LINE(
            'Table Created Successfully'
        );

    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Table Already Exists'
        );
    END IF;

END;
/
```

---

# 2. Triggers

## What is a Trigger?

A trigger is code that executes automatically when an event happens on a table.

Examples:

- INSERT
- UPDATE
- DELETE

### Example:

"When inserting a record, automatically capture:

- Created date
- Logged in user"

---

## Trigger Example

```sql
CREATE OR REPLACE TRIGGER DEMO_TRG_GIN_DEMO_SYSTEM_REPORTS
BEFORE INSERT
ON GIN_DEMO_SYSTEM_REPORTS
FOR EACH ROW
BEGIN

    :NEW.CREATED_DATE := SYSDATE;
    :NEW.CREATED_BY   := USER;

END;
/
```

### Explanation

| Keyword | Meaning |
|----------|----------|
| BEFORE INSERT | Runs before insert |
| FOR EACH ROW | Runs per inserted row |
| :NEW | Refers to new values |
| SYSDATE | Current database date |
| USER | Logged in DB user |

---

## Trigger for Audit Logging

Example:

Track updates.

```sql
CREATE OR REPLACE TRIGGER TRG_POLICY_AUDIT
AFTER UPDATE
ON GIN_POLICIES
FOR EACH ROW
BEGIN

    INSERT INTO POLICY_AUDIT
    (
        POLICY_NO,
        OLD_STATUS,
        NEW_STATUS,
        CHANGED_DATE
    )
    VALUES
    (
        :OLD.POL_NO,
        :OLD.POL_STATUS,
        :NEW.POL_STATUS,
        SYSDATE
    );

END;
/
```

### Special Keywords

```sql
:NEW
```

New value after change.

```sql
:OLD
```

Old value before change.

---

# 3. Records & Types Used in Functions & Procedures

## What is a Record?

A record stores multiple related fields.

Like a Java DTO or Object.

Instead of:

```sql
v_code NUMBER;
v_value NUMBER;
v_level VARCHAR2(20);
```

Use a record.

---

## Package Specification

```sql
CREATE OR REPLACE PACKAGE GIN_SAMPLE_PKG AS

    TYPE policies_rec IS RECORD
    (
        nrr_code      NUMBER,
        nrr_value     NUMBER,
        nrr_app_level VARCHAR2(20)
    );

    TYPE policies_ref
    IS REF CURSOR
    RETURN policies_rec;

    FUNCTION get_sample_data
    RETURN policies_ref;

END;
/
```

---

## Package Body

```sql
CREATE OR REPLACE PACKAGE BODY GIN_SAMPLE_PKG AS

    FUNCTION get_sample_data
    RETURN policies_ref
    IS
        v_cursor policies_ref;
    BEGIN

        OPEN v_cursor FOR
            SELECT
                nrr_code,
                nrr_value,
                nrr_app_level
            FROM
                GIN_NOT_RECOVERING_REASONS
            WHERE
                nrr_value IS NULL
            ORDER BY
                nrr_code DESC;

        RETURN v_cursor;

    END;

END;
/
```

### Why Use REF CURSOR?

Useful when:

- Returning multiple rows
- APIs
- Oracle ADF
- Reporting systems

---

# 4. Tabs and Objects

Common Objects in Oracle:

| Object | Purpose |
|---------|----------|
| Table | Store data |
| View | Virtual table |
| Procedure | Execute logic |
| Function | Return value |
| Package | Group logic |
| Trigger | Event-based automation |
| Sequence | Generate IDs |
| Cursor | Fetch records |

---

# 5. PL/SQL Architecture (Where to Add What)

A good project structure:

## Package Specification

Contains:

- Function declarations
- Procedure declarations
- Types
- Constants

Example:

```sql
CREATE OR REPLACE PACKAGE GIN_POLICY_PKG AS

    PROCEDURE create_policy;

    FUNCTION get_policy
    RETURN VARCHAR2;

END;
/
```

---

## Package Body

Contains actual implementation.

```sql
CREATE OR REPLACE PACKAGE BODY GIN_POLICY_PKG AS

    PROCEDURE create_policy
    IS
    BEGIN
        NULL;
    END;

    FUNCTION get_policy
    RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Success';
    END;

END;
/
```

---

## Naming Convention

### `_PKG`

Used for:

- Inserts
- Updates
- Deletes
- Business logic

Example:

```sql
GIN_POLICY_PKG
```

---

### `_CURSOR`

Used for:

- Fetching data
- Queries only

Example:

```sql
GIN_POLICY_CURSOR
```

---

# 6. Common PL/SQL Errors

## ORA-06553 / PLS-306

### Error

```text
wrong number or types of arguments
```

### Cause

Mismatch in:

- Procedure parameters
- Function arguments

Example:

```sql
get_revamped_prod_total(
    1,
    'ABC'
);
```

But function expects:

```sql
(
    NUMBER,
    NUMBER
)
```

### Fix

Verify parameter count and types.

---

## Invalid Column Index

### Cause

Wrong bind variable count.

Example (Error):

```sql
EXECUTE IMMEDIATE v_sql
USING 1;
```

But SQL expects:

```sql
VALUES (:1,:2)
```

### Fix

Pass correct bind count.

```sql
EXECUTE IMMEDIATE v_sql
USING
    1,
    'Test';
```

---

## NO_DATA_FOUND

### Cause

No record returned.

Example Fix:

```sql
BEGIN

    SELECT username
    INTO v_username
    FROM users
    WHERE id = 100;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(
            'No Record Found'
        );
END;
/
```

---

## TOO_MANY_ROWS

### Cause

Your query returns multiple rows.

Bad:

```sql
SELECT username
INTO v_username
FROM users;
```

### Fix

Filter properly.

```sql
SELECT username
INTO v_username
FROM users
WHERE user_id = 1;
```

---

## OTHERS Exception

Catch unexpected errors.

```sql
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            SQLERRM
        );
```

---

# Best Practices

1. Avoid hardcoding values  
2. Use sequences instead of `MAX + 1`  
3. Use bind variables with `EXECUTE IMMEDIATE`  
4. Write rerunnable migration scripts  
5. Always handle exceptions  
6. Use packages for reusable logic  
7. Use triggers carefully (avoid too much business logic)  
8. Keep SELECT logic in `_CURSOR` packages  
9. Use meaningful naming conventions  
10. Add comments in scripts

---