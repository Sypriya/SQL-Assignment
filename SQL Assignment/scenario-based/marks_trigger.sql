CREATE TABLE student_audit (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id NUMBER,
    old_grade VARCHAR2(2),
    new_grade VARCHAR2(2),
    operation_type VARCHAR2(10),
    operation_date DATE DEFAULT SYSDATE
);
CREATE TABLE student_audit (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id NUMBER,
    old_grade VARCHAR2(2),
    new_grade VARCHAR2(2),
    operation_type VARCHAR2(10),
    operation_date DATE DEFAULT SYSDATE
);
CREATE OR REPLACE TRIGGER trg_student_grade
AFTER INSERT OR UPDATE ON students
FOR EACH ROW
DECLARE
    v_new_grade VARCHAR2(2);
BEGIN
    -- 1️⃣ Calculate grade based on marks
    IF :NEW.marks >= 90 THEN
        v_new_grade := 'A';
    ELSIF :NEW.marks >= 75 THEN
        v_new_grade := 'B';
    ELSIF :NEW.marks >= 60 THEN
        v_new_grade := 'C';
    ELSE
        v_new_grade := 'F';
    END IF;

    -- 2️⃣ Update grade if changed or not set
    UPDATE students
    SET grade = v_new_grade
    WHERE student_id = :NEW.student_id;

    -- 3️⃣ Insert into audit log
    INSERT INTO student_audit(student_id, old_grade, new_grade, operation_type)
    VALUES(:NEW.student_id, :OLD.grade, v_new_grade,
           CASE
               WHEN INSERTING THEN 'INSERT'
               WHEN UPDATING THEN 'UPDATE'
           END);
END;
/
INSERT INTO students (student_id, student_name, marks)
VALUES (1, 'Ravi', 92);

INSERT INTO students (student_id, student_name, marks)
VALUES (2, 'Sneha', 78);

INSERT INTO students (student_id, student_name, marks)
VALUES (3, 'Kiran', 55);