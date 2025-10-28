-- Return the square of a number
CREATE OR REPLACE FUNCTION square_num(n NUMBER)
RETURN NUMBER IS
BEGIN
  RETURN n * n;
END;
/
SELECT square_num(5) FROM dual;


-- 2. Function to return factorial of a number
CREATE OR REPLACE FUNCTION factorial(n NUMBER)
RETURN NUMBER AS
  res NUMBER := 1;
BEGIN
  FOR i IN 1..n LOOP
    res := res * i;
  END LOOP;
  RETURN res;
END;
/
SELECT factorial(5) AS Factorial FROM dual;

--3.Function to return total salary of all employees
CREATE OR REPLACE FUNCTION total_salary
RETURN NUMBER AS
  total NUMBER;
BEGIN
  SELECT SUM(salary) INTO total FROM emp;
  RETURN total;
END;
/
SELECT total_salary() FROM dual;

---4. Function to get employee name by ID
CREATE OR REPLACE FUNCTION get_emp_name(eid NUMBER)
RETURN VARCHAR2 AS
  ename VARCHAR2(50);
BEGIN
  SELECT ename INTO ename FROM emp WHERE empno = eid;
  RETURN ename;
END;
/
SELECT get_emp_name(101) FROM dual;


---5. Function to get department name by department ID
CREATE OR REPLACE FUNCTION get_dept_name(did NUMBER)
RETURN VARCHAR2 AS
  dname VARCHAR2(50);
BEGIN
  SELECT dname INTO dname FROM dept WHERE deptno = did;
  RETURN dname;
END;
/
SELECT get_dept_name(10) FROM dual;

---6. Function to check even or odd
CREATE OR REPLACE FUNCTION even_odd(n NUMBER)
RETURN VARCHAR2 AS
BEGIN
  IF MOD(n,2)=0 THEN
    RETURN 'Even';
  ELSE
    RETURN 'Odd';
  END IF;
END;
/
SELECT even_odd(7) FROM dual;

---7. Function to return current date and time
CREATE OR REPLACE FUNCTION current_datetime
RETURN DATE AS
BEGIN
  RETURN SYSDATE;
END;
/
SELECT current_datetime() FROM dual;


---8. Function to calculate area of circle
CREATE OR REPLACE FUNCTION area_circle(r NUMBER)
RETURN NUMBER AS
BEGIN
  RETURN 3.14159 * r * r;
END;
/
SELECT area_circle(5) FROM dual;

--9. Function to count employees in a department
CREATE OR REPLACE FUNCTION emp_count_dept(did NUMBER)
RETURN NUMBER AS
  cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM emp WHERE deptno = did;
  RETURN cnt;
END;
/
SELECT emp_count_dept(20) FROM dual;

---10. Function to get maximum salary
CREATE OR REPLACE FUNCTION max_salary
RETURN NUMBER AS
  ms NUMBER;
BEGIN
  SELECT MAX(salary) INTO ms FROM emp;
  RETURN ms;
END;
/
SELECT max_salary() FROM dual;

---11. Function to convert Celsius to Fahrenheit
CREATE OR REPLACE FUNCTION c_to_f(c NUMBER)
RETURN NUMBER AS
BEGIN
  RETURN (c * 9/5) + 32;
END;
/
SELECT c_to_f(37) FROM dual;

---12. Function to return commission percentage
CREATE OR REPLACE FUNCTION get_commission(eid NUMBER)
RETURN NUMBER AS
  comm NUMBER;
BEGIN
  SELECT NVL(commission_pct,0) INTO comm FROM emp WHERE empno = eid;
  RETURN comm;
END;
/
SELECT get_commission(102) FROM dual;

----13. Function to count employees with salary > 5000
CREATE OR REPLACE FUNCTION count_high_salary
RETURN NUMBER AS
  cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM emp WHERE salary > 5000;
  RETURN cnt;
END;
/
SELECT count_high_salary() FROM dual;

---14. Function to find nth Fibonacci number
CREATE OR REPLACE FUNCTION fib(n NUMBER)
RETURN NUMBER AS
  a NUMBER := 0;
  b NUMBER := 1;
  c NUMBER;
BEGIN
  IF n = 0 THEN RETURN 0;
  ELSIF n = 1 THEN RETURN 1;
  END IF;
  FOR i IN 2..n LOOP
    c := a + b;
    a := b;
    b := c;
  END LOOP;
  RETURN b;
END;
/
SELECT fib(7) FROM dual;

---15. Function to reverse a string
CREATE OR REPLACE FUNCTION reverse_str(s VARCHAR2)
RETURN VARCHAR2 AS
  rev VARCHAR2(100) := '';
BEGIN
  FOR i IN REVERSE 1..LENGTH(s) LOOP
    rev := rev || SUBSTR(s, i, 1);
  END LOOP;
  RETURN rev;
END;
/
SELECT reverse_str('HELLO') FROM dual;

---16. Function to find string length without LENGTH()
CREATE OR REPLACE FUNCTION str_len(s VARCHAR2)
RETURN NUMBER AS
  i NUMBER := 0;
BEGIN
  LOOP
    i := i + 1;
    EXIT WHEN SUBSTR(s,i,1) IS NULL;
  END LOOP;
  RETURN i - 1;
END;
/
SELECT str_len('SUPRIYA') FROM dual;

---17. Function to calculate compound interest
CREATE OR REPLACE FUNCTION compound_interest(p NUMBER, r NUMBER, t NUMBER)
RETURN NUMBER AS
BEGIN
  RETURN p * POWER((1 + r/100), t) - p;
END;
/
SELECT compound_interest(10000, 5, 2) FROM dual;

---18. Function to return yearly salary
CREATE OR REPLACE FUNCTION yearly_salary(eid NUMBER)
RETURN NUMBER AS
  sal NUMBER;
BEGIN
  SELECT salary*12 INTO sal FROM emp WHERE empno = eid;
  RETURN sal;
END;
/
SELECT yearly_salary(101) FROM dual;


---19. Function to return min salary of a department
CREATE OR REPLACE FUNCTION min_sal_dept(did NUMBER)
RETURN NUMBER AS
  ms NUMBER;
BEGIN
  SELECT MIN(salary) INTO ms FROM emp WHERE deptno = did;
  RETURN ms;
END;
/
SELECT min_sal_dept(20) FROM dual;

---20. Function to check leap year
CREATE OR REPLACE FUNCTION is_leap(yr NUMBER)
RETURN VARCHAR2 AS
BEGIN
  IF MOD(yr,400)=0 OR (MOD(yr,4)=0 AND MOD(yr,100)<>0) THEN
    RETURN 'Leap Year';
  ELSE
    RETURN 'Not Leap Year';
  END IF;
END;
/
SELECT is_leap(2024) FROM dual;

---21. Function to count vowels in a string
CREATE OR REPLACE FUNCTION count_vowels(s VARCHAR2)
RETURN NUMBER AS
  cnt NUMBER := 0;
BEGIN
  FOR i IN 1..LENGTH(s) LOOP
    IF INSTR('AEIOUaeiou', SUBSTR(s,i,1)) > 0 THEN
      cnt := cnt + 1;
    END IF;
  END LOOP;
  RETURN cnt;
END;
/
SELECT count_vowels('SUPRIYA') FROM dual;


---22. Function to find greater of two numbers
CREATE OR REPLACE FUNCTION greater(a NUMBER, b NUMBER)
RETURN NUMBER AS
BEGIN
  RETURN CASE WHEN a > b THEN a ELSE b END;
END;
/
SELECT greater(10,20) FROM dual;


---23. Function to count total departments
CREATE OR REPLACE FUNCTION dept_count
RETURN NUMBER AS
  cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM dept;
  RETURN cnt;
END;
/
SELECT dept_count() FROM dual;


----24. Function to return last hired employee name
CREATE OR REPLACE FUNCTION last_hired_emp
RETURN VARCHAR2 AS
  en VARCHAR2(50);
BEGIN
  SELECT ename INTO en FROM emp
  WHERE hiredate = (SELECT MAX(hiredate) FROM emp);
  RETURN en;
END;
/
SELECT last_hired_emp() FROM dual;


----25. Function to return employee name in uppercase
CREATE OR REPLACE FUNCTION emp_upper(eid NUMBER)
RETURN VARCHAR2 AS
  en VARCHAR2(50);
BEGIN
  SELECT UPPER(ename) INTO en FROM emp WHERE empno = eid;
  RETURN en;
END;
/
SELECT emp_upper(101) FROM dual;

---26. Function to return grade based on salary
CREATE OR REPLACE FUNCTION grade_by_salary(s NUMBER)
RETURN CHAR AS
BEGIN
  IF s >= 10000 THEN
    RETURN 'A';
  ELSIF s >= 5000 THEN
    RETURN 'B';
  ELSE
    RETURN 'C';
  END IF;
END;
/
SELECT grade_by_salary(7500) FROM dual;


----27. Function to sum digits of a number
CREATE OR REPLACE FUNCTION sum_digits(n NUMBER)
RETURN NUMBER AS
  s NUMBER := 0;
  rem NUMBER;
BEGIN
  WHILE n > 0 LOOP
    rem := MOD(n,10);
    s := s + rem;
    n := FLOOR(n/10);
  END LOOP;
  RETURN s;
END;
/
SELECT sum_digits(1234) FROM dual;

----28. Function to find square root
CREATE OR REPLACE FUNCTION sqrt_num(n NUMBER)
RETURN NUMBER AS
BEGIN
  RETURN SQRT(n);
END;
/
SELECT sqrt_num(49) FROM dual;


----29. Function to count employees joined in a year
CREATE OR REPLACE FUNCTION count_emp_year(yr NUMBER)
RETURN NUMBER AS
  cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM emp WHERE EXTRACT(YEAR FROM hiredate)=yr;
  RETURN cnt;
END;
/
SELECT count_emp_year(2024) FROM dual;


-----30. Function to return job title by employee ID
CREATE OR REPLACE FUNCTION get_job(eid NUMBER)
RETURN VARCHAR2 AS
  jobt VARCHAR2(30);
BEGIN
  SELECT job INTO jobt FROM emp WHERE empno = eid;
  RETURN jobt;
END;
/
SELECT get_job(101) FROM dual;


----31. Function to return average of two numbers
CREATE OR REPLACE FUNCTION avg_two(a NUMBER, b NUMBER)
RETURN NUMBER AS
BEGIN
  RETURN (a + b)/2;
END;
/
SELECT avg_two(10,20) FROM dual;

----32. Function to check if a string is palindrome
CREATE OR REPLACE FUNCTION is_palindrome(s VARCHAR2)
RETURN VARCHAR2 AS
  rev VARCHAR2(100) := '';
BEGIN
  FOR i IN REVERSE 1..LENGTH(s) LOOP
    rev := rev || SUBSTR(s,i,1);
  END LOOP;
  IF LOWER(s) = LOWER(rev) THEN
    RETURN 'Palindrome';
  ELSE
    RETURN 'Not Palindrome';
  END IF;
END;
/
SELECT is_palindrome('madam') FROM dual;

----33. Function to find number of days between two dates
CREATE OR REPLACE FUNCTION days_between(d1 DATE, d2 DATE)
RETURN NUMBER AS
BEGIN
  RETURN ABS(d2 - d1);
END;
/
SELECT days_between(TO_DATE('2025-10-28','YYYY-MM-DD'), TO_DATE('2025-11-05','YYYY-MM-DD')) FROM dual;


----34. Function to return domain part of email
CREATE OR REPLACE FUNCTION email_domain(email VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
  RETURN SUBSTR(email, INSTR(email,'@')+1);
END;
/
SELECT email_domain('ravi@gmail.com') FROM dual;

-----35. Function to classify salary as HIGH / MEDIUM / LOW
CREATE OR REPLACE FUNCTION salary_level(s NUMBER)
RETURN VARCHAR2 AS
BEGIN
  IF s > 10000 THEN
    RETURN 'HIGH';
  ELSIF s BETWEEN 5000 AND 10000 THEN
    RETURN 'MEDIUM';
  ELSE
    RETURN 'LOW';
  END IF;
END;
/
SELECT salary_level(4500) FROM dual;