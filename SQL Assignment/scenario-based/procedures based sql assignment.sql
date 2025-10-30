CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(50),
    salary NUMBER,
    department_id NUMBER,
    job_title VARCHAR2(50),
    hire_date DATE,
    commission NUMBER,
    manager_id NUMBER
);

CREATE TABLE departments (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(50)
);

CREATE TABLE audit_log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    log_date DATE,
    log_message VARCHAR2(200)
);
`

----🔹 1. Insert a new employee record

```sql
CREATE OR REPLACE PROCEDURE insert_employee(
    p_id NUMBER,
    p_name VARCHAR2,
    p_salary NUMBER,
    p_dept NUMBER,
    p_job VARCHAR2
)
AS
BEGIN
    INSERT INTO employees(emp_id, emp_name, salary, department_id, job_title, hire_date)
    VALUES(p_id, p_name, p_salary, p_dept, p_job, SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Employee inserted successfully.');
END;
/


---🔹 2. Update employee’s salary


CREATE OR REPLACE PROCEDURE update_salary(p_id NUMBER, p_new_salary NUMBER)
AS
BEGIN
    UPDATE employees SET salary = p_new_salary WHERE emp_id = p_id;
    DBMS_OUTPUT.PUT_LINE('Salary updated successfully.');
END;
/


---🔹 3. Delete employee by ID

```sql
CREATE OR REPLACE PROCEDURE delete_employee(p_id NUMBER)
AS
BEGIN
    DELETE FROM employees WHERE emp_id = p_id;
    DBMS_OUTPUT.PUT_LINE('Employee deleted.');
END;
/


----🔹 4. Print all employee names


CREATE OR REPLACE PROCEDURE print_all_employees
AS
BEGIN
    FOR r IN (SELECT emp_name FROM employees) LOOP
        DBMS_OUTPUT.PUT_LINE(r.emp_name);
    END LOOP;
END;
/


---🔹 5. Print employee details by ID

```sql
CREATE OR REPLACE PROCEDURE print_employee_details(p_id NUMBER)
AS
    v_emp employees%ROWTYPE;
BEGIN
    SELECT * INTO v_emp FROM employees WHERE emp_id = p_id;
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_emp.emp_id || ', Name: ' || v_emp.emp_name ||
                         ', Salary: ' || v_emp.salary || ', Dept: ' || v_emp.department_id);
END;


----🔹 6. 10% salary hike by department


CREATE OR REPLACE PROCEDURE hike_salary_by_dept(p_dept NUMBER)
AS
BEGIN
    UPDATE employees
    SET salary = salary * 1.10
    WHERE department_id = p_dept;
    DBMS_OUTPUT.PUT_LINE('10% salary hike applied.');
END;
/


--- 🔹 7. Increase salary by input percentage


CREATE OR REPLACE PROCEDURE increase_salary(p_percent NUMBER)
AS
BEGIN
    UPDATE employees SET salary = salary + (salary * p_percent / 100);
    DBMS_OUTPUT.PUT_LINE('Salary increased by ' || p_percent || '%');
END;
/


---🔹 8. Copy data from one table to another


CREATE OR REPLACE PROCEDURE copy_employee_data
AS
BEGIN
    INSERT INTO employees_backup SELECT * FROM employees;
    DBMS_OUTPUT.PUT_LINE('Data copied successfully.');
END;
/


---🔹 9. Delete employees with salary < 3000

```sql
CREATE OR REPLACE PROCEDURE delete_low_salary
AS
BEGIN
    DELETE FROM employees WHERE salary < 3000;
    DBMS_OUTPUT.PUT_LINE('Employees with salary < 3000 deleted.');
END;
/
```



--- 🔹 10. Display total salary per department

```sql
CREATE OR REPLACE PROCEDURE total_salary_per_dept
AS
BEGIN
    FOR r IN (SELECT department_id, SUM(salary) total FROM employees GROUP BY department_id)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Dept ' || r.department_id || ': ' || r.total);
    END LOOP;
END;
/


---🔹 11. Log row count

```sql
CREATE OR REPLACE PROCEDURE log_row_count(p_table_name VARCHAR2)
AS
    v_count NUMBER;
    v_sql   VARCHAR2(1000);
BEGIN
    v_sql := 'SELECT COUNT(*) FROM ' || p_table_name;
    EXECUTE IMMEDIATE v_sql INTO v_count;

    INSERT INTO audit_log(log_date, log_message)
    VALUES(SYSDATE, 'Table ' || p_table_name || ' has ' || v_count || ' rows.');
END;
/


🔹 12. Return department ID via OUT parameter


CREATE OR REPLACE PROCEDURE get_dept_id(
    p_name VARCHAR2,
    p_id OUT NUMBER
)
AS
BEGIN
    SELECT dept_id INTO p_id FROM departments WHERE dept_name = p_name;
END;
/
`

--- 🔹 13. Truncate table dynamically

CREATE OR REPLACE PROCEDURE truncate_table(p_table VARCHAR2)
AS
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || p_table;
    DBMS_OUTPUT.PUT_LINE('Table ' || p_table || ' truncated.');
END;
/
```

---

---🔹 14. Employees whose name starts with ‘A’


CREATE OR REPLACE PROCEDURE employees_starting_with_A
AS
BEGIN
    FOR r IN (SELECT emp_name FROM employees WHERE emp_name LIKE 'A%') LOOP
        DBMS_OUTPUT.PUT_LINE(r.emp_name);
    END LOOP;
END;
/

--- 🔹 15. Highest-paid employee

CREATE OR REPLACE PROCEDURE highest_paid_employee
AS
    v_name employees.emp_name%TYPE;
    v_sal  employees.salary%TYPE;
BEGIN
    SELECT emp_name, salary INTO v_name, v_sal
    FROM employees
    WHERE salary = (SELECT MAX(salary) FROM employees);
    DBMS_OUTPUT.PUT_LINE('Highest Paid: ' || v_name || ' (' || v_sal || ')');
END;
/


---🔹 16. Update job title based on salary range


CREATE OR REPLACE PROCEDURE update_job_title
AS
BEGIN
    UPDATE employees
    SET job_title = CASE
        WHEN salary < 4000 THEN 'Junior'
        WHEN salary BETWEEN 4000 AND 7000 THEN 'Mid-Level'
        ELSE 'Senior'
    END;
    DBMS_OUTPUT.PUT_LINE('Job titles updated.');
END;
/


-- 🔹 17. Insert multiple records using loop


CREATE OR REPLACE PROCEDURE insert_multiple
AS
BEGIN
    FOR i IN 1..5 LOOP
        INSERT INTO employees(emp_id, emp_name, salary, department_id, job_title, hire_date)
        VALUES(1000 + i, 'Emp' || i, 3000 + i*500, 10, 'Analyst', SYSDATE);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('5 employees inserted.');
END;
/

--- 🔹 18. Print all department names


CREATE OR REPLACE PROCEDURE print_departments
AS
BEGIN
    FOR r IN (SELECT dept_name FROM departments) LOOP
        DBMS_OUTPUT.PUT_LINE(r.dept_name);
    END LOOP;
END;
/


---🔹 19. Employees without commission

```sql
CREATE OR REPLACE PROCEDURE no_commission_employees
AS
BEGIN
    FOR r IN (SELECT emp_name FROM employees WHERE commission IS NULL) LOOP
        DBMS_OUTPUT.PUT_LINE(r.emp_name);
    END LOOP;
END;
/


---🔹 20. Employees hired between two dates

```sql
CREATE OR REPLACE PROCEDURE hired_between(p_start DATE, p_end DATE)
AS
BEGIN
    FOR r IN (SELECT emp_name, hire_date FROM employees WHERE hire_date BETWEEN p_start AND p_end) LOOP
        DBMS_OUTPUT.PUT_LINE(r.emp_name || ' hired on ' || r.hire_date);
    END LOOP;
END;
/


---🔹 21. Transfer employees to another department

```sql
CREATE OR REPLACE PROCEDURE transfer_employees(p_from NUMBER, p_to NUMBER)
AS
BEGIN
    UPDATE employees SET department_id = p_to WHERE department_id = p_from;
    DBMS_OUTPUT.PUT_LINE('Employees transferred.');
END;
/


---🔹 22. Log audit data

```sql
CREATE OR REPLACE PROCEDURE log_audit(p_message VARCHAR2)
AS
BEGIN
    INSERT INTO audit_log(log_date, log_message)
    VALUES(SYSDATE, p_message);
END;
/


---🔹 23. Delete duplicate employees


CREATE OR REPLACE PROCEDURE delete_duplicates
AS
BEGIN
    DELETE FROM employees e
    WHERE ROWID NOT IN (
        SELECT MIN(ROWID)
        FROM employees
        GROUP BY emp_name, department_id
    );
END;
/


--- 🔹 24. Print even numbers 1–50


CREATE OR REPLACE PROCEDURE print_even_numbers
AS
BEGIN
    FOR i IN 1..50 LOOP
        IF MOD(i,2)=0 THEN
            DBMS_OUTPUT.PUT_LINE(i);
        END IF;
    END LOOP;
END;
/


--- 🔹 25. Fibonacci series up to N terms


CREATE OR REPLACE PROCEDURE fibonacci(p_n NUMBER)
AS
    a NUMBER := 0;
    b NUMBER := 1;
    c NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE(a);
    DBMS_OUTPUT.PUT_LINE(b);
    FOR i IN 3..p_n LOOP
        c := a + b;
        DBMS_OUTPUT.PUT_LINE(c);
        a := b;
        b := c;
    END LOOP;
END;
/


---🔹 26. Reverse a given string


CREATE OR REPLACE PROCEDURE reverse_string(p_str VARCHAR2)
AS
    v_rev VARCHAR2(100) := '';
BEGIN
    FOR i IN REVERSE 1..LENGTH(p_str) LOOP
        v_rev := v_rev || SUBSTR(p_str, i, 1);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Reversed: ' || v_rev);
END;
/


---🔹 27. Prime numbers 1–100


CREATE OR REPLACE PROCEDURE print_primes
AS
    flag BOOLEAN;
BEGIN
    FOR i IN 2..100 LOOP
        flag := TRUE;
        FOR j IN 2..FLOOR(SQRT(i)) LOOP
            IF MOD(i,j)=0 THEN
                flag := FALSE;
                EXIT;
            END IF;
        END LOOP;
        IF flag THEN
            DBMS_OUTPUT.PUT_LINE(i);
        END IF;
    END LOOP;
END;
/


---🔹 28. Factorial of a number

```sql
CREATE OR REPLACE PROCEDURE factorial(p_num NUMBER)
AS
    fact NUMBER := 1;
BEGIN
    FOR i IN 1..p_num LOOP
        fact := fact * i;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Factorial: ' || fact);
END;
/


---🔹 29. Dynamic row count by table

```sql
CREATE OR REPLACE PROCEDURE dynamic_row_count(p_table VARCHAR2)
AS
    v_count NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_table INTO v_count;
    DBMS_OUTPUT.PUT_LINE('Rows in ' || p_table || ': ' || v_count);
END;
/


---

--🔹 30. Employees with NULL manager ID

CREATE OR REPLACE PROCEDURE null_manager_employees
AS
BEGIN
    FOR r IN (SELECT emp_name FROM employees WHERE manager_id IS NULL) LOOP
        DBMS_OUTPUT.PUT_LINE(r.emp_name);
    END LOOP;
END;
/


--🔹 31. Update salaries hired before 2010

```sql
CREATE OR REPLACE PROCEDURE update_old_hires
AS
BEGIN
    UPDATE employees SET salary = salary * 1.05 WHERE hire_date < TO_DATE('01-JAN-2010', 'DD-MON-YYYY');
    DBMS_OUTPUT.PUT_LINE('Old hire salaries updated.');
END;
/


--🔹 32. Delete log rows older than 30 days


CREATE OR REPLACE PROCEDURE delete_old_logs
AS
BEGIN
    DELETE FROM audit_log WHERE log_date < SYSDATE - 30;
    DBMS_OUTPUT.PUT_LINE('Old logs deleted.');
END;
/


-- 🔹 33. Show department and job by employee ID

CREATE OR REPLACE PROCEDURE emp_dept_job(p_id NUMBER)
AS
    v_dept NUMBER;
    v_job VARCHAR2(50);
BEGIN
    SELECT department_id, job_title INTO v_dept, v_job
    FROM employees WHERE emp_id = p_id;
    DBMS_OUTPUT.PUT_LINE('Dept: ' || v_dept || ', Job: ' || v_job);
END;
/


 ---🔹 34. Insert today’s date and username into log

CREATE OR REPLACE PROCEDURE log_user
AS
BEGIN
    INSERT INTO audit_log(log_date, log_message)
    VALUES(SYSDATE, USER || ' logged in.');
END;

 ---🔹 35. Print number of days in current month

CREATE OR REPLACE PROCEDURE days_in_current_month
AS
    v_days NUMBER;
BEGIN
    v_days := TO_NUMBER(TO_CHAR(LAST_DAY(SYSDATE), 'DD'));
    DBMS_OUTPUT.PUT_LINE('Days in current month: ' || v_days);
END;