--- 1) BEFORE INSERT on EMP to set `CREATED_DATE = SYSDATE`


CREATE OR REPLACE TRIGGER trg_emp_before_insert_created_date
BEFORE INSERT ON emp
FOR EACH ROW
BEGIN
  :NEW.created_date := SYSDATE;
END;
/

--- 2) AFTER INSERT trigger to log new records into `AUDIT_LOG`


CREATE OR REPLACE TRIGGER trg_emp_after_insert_audit
AFTER INSERT ON emp
FOR EACH ROW
BEGIN
  INSERT INTO audit_log(log_date, log_message)
  VALUES(SYSDATE, 'NEW EMP INSERTED: ID='||:NEW.emp_id||', NAME='||:NEW.first_name||' '||:NEW.last_name);
END;
/

---- 3) BEFORE UPDATE trigger to prevent salary reduction


CREATE OR REPLACE TRIGGER trg_emp_before_update_no_salary_reduce
BEFORE UPDATE OF salary ON emp
FOR EACH ROW
BEGIN
  IF :NEW.salary < NVL(:OLD.salary,0) THEN
    RAISE_APPLICATION_ERROR(-20001, 'Salary reduction not allowed.');
  END IF;
END;
/


---4) AFTER DELETE trigger to record deleted rows in another table (`EMP_HISTORY`)


CREATE OR REPLACE TRIGGER trg_emp_after_delete_history
AFTER DELETE ON emp
FOR EACH ROW
BEGIN
  INSERT INTO emp_history(
    emp_id, first_name, last_name, salary, department, job_title, hire_date, deleted_on
  ) VALUES (
    :OLD.emp_id, :OLD.first_name, :OLD.last_name, :OLD.salary, :OLD.department, :OLD.job_title, :OLD.hire_date, SYSDATE
  );
END;
/


---- 5) BEFORE INSERT trigger to assign `EMP_ID` from a sequence `EMP_SEQ`


CREATE OR REPLACE TRIGGER trg_emp_before_insert_seq
BEFORE INSERT ON emp
FOR EACH ROW
BEGIN
  IF :NEW.emp_id IS NULL THEN
    SELECT emp_seq.NEXTVAL INTO :NEW.emp_id FROM DUAL;
  END IF;
END;
/


---- 6) AFTER UPDATE trigger to log old and new salary values (`EMP_SALARY_LOG`)


CREATE OR REPLACE TRIGGER trg_emp_after_update_salary_log
AFTER UPDATE OF salary ON emp
FOR EACH ROW
BEGIN
  INSERT INTO emp_salary_log(emp_id, old_salary, new_salary, changed_by, changed_on)
  VALUES(:OLD.emp_id, :OLD.salary, :NEW.salary, USER, SYSDATE);
END;
/


----7) BEFORE DELETE trigger to prevent deletion of managers (who have direct reports)


CREATE OR REPLACE TRIGGER trg_emp_before_delete_prevent_manager_delete
BEFORE DELETE ON emp
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM emp WHERE manager_id = :OLD.emp_id;
  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Cannot delete: employee is a manager with direct reports.');
  END IF;
END;
/


---8) Trigger that prevents updates on weekends


CREATE OR REPLACE TRIGGER trg_emp_before_update_no_weekend_updates
BEFORE UPDATE ON emp
FOR EACH ROW
BEGIN
  IF TO_CHAR(SYSDATE,'DY','NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT','SUN') THEN
    RAISE_APPLICATION_ERROR(-20003, 'Updates are not allowed on weekends.');
  END IF;
END;
/


---- 9) Trigger to set `LAST_UPDATED_BY = USER` on update


CREATE OR REPLACE TRIGGER trg_emp_before_update_set_last_updated_by
BEFORE UPDATE ON emp
FOR EACH ROW
BEGIN
  :NEW.last_updated_by := USER;
  :NEW.updated_on := SYSDATE;  -- also set timestamp
END;
/

---- 10) Trigger to prevent insertion of duplicate email IDs


CREATE OR REPLACE TRIGGER trg_emp_before_ins_upd_no_dup_email
BEFORE INSERT OR UPDATE ON emp
FOR EACH ROW
DECLARE
  v_cnt NUMBER;
BEGIN
  IF :NEW.email IS NOT NULL THEN
    SELECT COUNT(*) INTO v_cnt FROM emp
    WHERE LOWER(email) = LOWER(:NEW.email)
      AND NVL(emp_id,0) <> NVL(:NEW.emp_id,0);
    IF v_cnt > 0 THEN
      RAISE_APPLICATION_ERROR(-20004, 'Duplicate email not allowed.');
    END IF;
  END IF;
END;
/


---11) Trigger that calculates `ANNUAL_SALARY` after each salary update


CREATE OR REPLACE TRIGGER trg_emp_before_update_calc_annual
BEFORE UPDATE OF salary ON emp
FOR EACH ROW
BEGIN
  :NEW.annual_salary := NVL(:NEW.salary,0) * 12;
END;
/


---12) Trigger to allow inserts only during office hours (9–17)


CREATE OR REPLACE TRIGGER trg_emp_before_insert_office_hours
BEFORE INSERT ON emp
FOR EACH ROW
DECLARE
  v_hour NUMBER := TO_NUMBER(TO_CHAR(SYSDATE,'HH24'));
BEGIN
  IF v_hour < 9 OR v_hour >= 17 THEN
    RAISE_APPLICATION_ERROR(-20005, 'Inserts allowed only during office hours (09:00 - 17:00).');
  END IF;
END;
/


----13) Trigger that logs login attempts in a `LOGIN_LOG` table


CREATE OR REPLACE TRIGGER trg_login_after_insert_log
AFTER INSERT ON login_attempt -- replace with actual table used to capture attempts
FOR EACH ROW
BEGIN
  INSERT INTO login_log(attempt_time, username, success, client_info)
  VALUES(SYSDATE, :NEW.username, :NEW.success, :NEW.client_info);
END;
/


--- 14) Trigger that sets default `DEPARTMENT = 'GENERAL'` if NULL


CREATE OR REPLACE TRIGGER trg_emp_before_ins_upd_default_dept
BEFORE INSERT OR UPDATE ON emp
FOR EACH ROW
BEGIN
  IF :NEW.department IS NULL THEN
    :NEW.department := 'GENERAL';
  END IF;
END;
/


---15) Trigger that prevents deletion of rows from the `DEPARTMENT` table


CREATE OR REPLACE TRIGGER trg_dept_before_delete_prevent
BEFORE DELETE ON departments
FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20006, 'Deletion of departments is not allowed.');
END;
/

---16) Trigger to prevent updating the primary key of `EMP` (`EMP_ID`)
CREATE OR REPLACE TRIGGER trg_emp_before_update_no_pk_change
BEFORE UPDATE OF emp_id ON emp
FOR EACH ROW
BEGIN
  IF :OLD.emp_id IS NOT NULL AND :OLD.emp_id != :NEW.emp_id THEN
    RAISE_APPLICATION_ERROR(-20007, 'Primary key (EMP_ID) cannot be modified.');
  END IF;
END;
/


--- 17) Trigger that updates audit columns (`UPDATED_BY`, `UPDATED_ON`) automatically


CREATE OR REPLACE TRIGGER trg_emp_before_ins_upd_audit_cols
BEFORE INSERT OR UPDATE ON emp
FOR EACH ROW
BEGIN
  :NEW.updated_by := USER;
  :NEW.updated_on := SYSDATE;
  IF INSERTING THEN
    :NEW.created_date := NVL(:NEW.created_date, SYSDATE);
  END IF;
END;
/


---18) Trigger that restricts inserting records if total count exceeds 1000


CREATE OR REPLACE TRIGGER trg_emp_before_insert_limit_1000
BEFORE INSERT ON emp
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM emp;
  IF v_cnt >= 1000 THEN
    RAISE_APPLICATION_ERROR(-20008, 'Table emp row limit (1000) reached. Insert not allowed.');
  END IF;
END;
/


----19) Trigger that fires when a table is truncated


CREATE OR REPLACE TRIGGER trg_schema_after_truncate
AFTER TRUNCATE ON SCHEMA
DECLARE
  v_user VARCHAR2(30) := SYS_CONTEXT('USERENV','SESSION_USER');
BEGIN
  INSERT INTO audit_log(log_date, log_message)
  VALUES(SYSDATE, 'TRUNCATE executed in schema by '||v_user||' - check object via ORACLE dictionary.');
END;
/


--- 20) Trigger to stop inserts if `SALARY > 100000`

CREATE OR REPLACE TRIGGER trg_emp_before_ins_upd_salary_max
BEFORE INSERT OR UPDATE OF salary ON emp
FOR EACH ROW
BEGIN
  IF :NEW.salary IS NOT NULL AND :NEW.salary > 100000 THEN
    RAISE_APPLICATION_ERROR(-20009, 'Salary cannot exceed 100,000.');
  END IF;
END;
/


----21) Trigger that automatically populates `FULL_NAME` = `FIRST_NAME || ' ' || LAST_NAME`


CREATE OR REPLACE TRIGGER trg_emp_before_ins_upd_fullname
BEFORE INSERT OR UPDATE ON emp
FOR EACH ROW
BEGIN
  :NEW.full_name := NVL(:NEW.first_name,'') || ' ' || NVL(:NEW.last_name,'');
END;
/


---22) Trigger that records the time difference between insert and update


CREATE OR REPLACE TRIGGER trg_emp_after_update_record_time_diff
AFTER UPDATE ON emp
FOR EACH ROW
BEGIN
  -- assumes created_date exists and that we want seconds difference
  IF :OLD.created_date IS NOT NULL THEN
    INSERT INTO audit_log(log_date, log_message)
    VALUES(SYSDATE,
      'Emp '||:NEW.emp_id||' time between insert and update = '||
      ROUND((SYSDATE - :OLD.created_date) * 24 * 60 * 60)||' seconds');
  END IF;
END;
/

---- 23) Trigger that prevents inserting rows with `NULL` email


CREATE OR REPLACE TRIGGER trg_emp_before_ins_no_null_email
BEFORE INSERT ON emp
FOR EACH ROW
BEGIN
  IF :NEW.email IS NULL THEN
    RAISE_APPLICATION_ERROR(-20010, 'Email cannot be NULL.');
  END IF;
END;
/


----24) Trigger that copies deleted employee data into a `HISTORY` table


CREATE OR REPLACE TRIGGER trg_emp_after_delete_to_history
AFTER DELETE ON emp
FOR EACH ROW
BEGIN
  INSERT INTO emp_history(
    emp_id, first_name, last_name, salary, department, job_title, manager_id, deleted_on
  )
  VALUES(
    :OLD.emp_id, :OLD.first_name, :OLD.last_name, :OLD.salary, :OLD.department, :OLD.job_title, :OLD.manager_id, SYSDATE
  );
END;
/


----25) Trigger that fires before an UPDATE on `DEPT` and raises error if `dept_name` changes


CREATE OR REPLACE TRIGGER trg_dept_before_update_no_name_change
BEFORE UPDATE ON departments
FOR EACH ROW
BEGIN
  IF :OLD.dept_name IS NOT NULL AND :OLD.dept_name <> :NEW.dept_name THEN
    RAISE_APPLICATION_ERROR(-20011, 'Changing department name is not allowed.');
  END IF;
END;
/


----26) Trigger to maintain a row count in another table after each insert/delete

CREATE OR REPLACE TRIGGER trg_emp_after_ins_del_maint_rowcount
AFTER INSERT OR DELETE ON emp
DECLARE
  v_delta NUMBER;
BEGIN
  IF INSERTING THEN
    v_delta := 1;
  ELSIF DELETING THEN
    v_delta := -1;
  END IF;

  UPDATE row_count_table SET cnt = cnt + v_delta WHERE obj_name = 'EMP';
  -- if no row exists, insert one
  IF SQL%ROWCOUNT = 0 THEN
    INSERT INTO row_count_table(obj_name, cnt) VALUES ('EMP', GREATEST(0, v_delta));
  END IF;
END;
/


--- 27) Trigger that prevents modification of system admin accounts


CREATE OR REPLACE TRIGGER trg_users_before_upd_del_protect_admin
BEFORE UPDATE OR DELETE ON users
FOR EACH ROW
BEGIN
  IF UPPER(:OLD.username) IN ('SYSADMIN','ADMIN') THEN
    RAISE_APPLICATION_ERROR(-20012, 'Modification of system admin accounts is not allowed.');
  END IF;
END;
/


---- 28) Trigger that sets `BONUS = 0` if `SALARY < 5000`

CREATE OR REPLACE TRIGGER trg_emp_before_ins_upd_bonus_default
BEFORE INSERT OR UPDATE ON emp
FOR EACH ROW
BEGIN
  IF :NEW.salary IS NOT NULL AND :NEW.salary < 5000 THEN
    :NEW.bonus := 0;
  END IF;
END;
/


----29) Trigger that logs username and date whenever salary is modified


CREATE OR REPLACE TRIGGER trg_emp_after_update_salary_user_log
AFTER UPDATE OF salary ON emp
FOR EACH ROW
BEGIN
  INSERT INTO salary_change_log(emp_id, old_salary, new_salary, changed_by, changed_on)
  VALUES(:OLD.emp_id, :OLD.salary, :NEW.salary, USER, SYSDATE);
END;
/


---- 30) Trigger that disables inserts into `EMP` table on Sundays
CREATE OR REPLACE TRIGGER trg_emp_before_insert_no_sunday
BEFORE INSERT ON emp
FOR EACH ROW
BEGIN
  IF TO_CHAR(SYSDATE,'DY','NLS_DATE_LANGUAGE=ENGLISH') = 'SUN' THEN
    RAISE_APPLICATION_ERROR(-20013, 'Inserts into EMP are disabled on Sundays.');
  END IF;
END;
/
```

---