select * from sh.customers;
-- # 25 Questions on WHERE

-- 1. Find customers born after the year 1990.

select * from sh.customers where CUST_YEAR_OF_BIRTH > 1990;

-- 2. List all male customers (`CUST_GENDER = 'M'`)

select * from sh.customers where CUST_GENDER = 'M';

-- 3. Retrieve all female customers (`CUST_GENDER = 'F'`) living in Sydney.

SELECT * FROM sh.customers WHERE CUST_GENDER = 'F' AND CUST_CITY = 'Sydney';

-- 4. Find customers with income level `"G: 130,000 - 149,999"`.

select * from sh.customers where CUST_INCOME_LEVEL = 'G: 130,000 - 149,999';

-- 5. Get all customers with a credit limit above 10,000.

select * from sh.customers where CUST_CREDIT_LIMIT > 10000;

-- 6. Retrieve customers from the state "California".

select * from sh.customers where cust_state_province = 'CA';

-- 7. Find customers who have provided an email address.

select * from sh.customers where cust_email is not null;

-- 8. List customers with missing marital status.

select * from sh.customers where cust_marital_status is null;

-- 9. Find customers whose postal code starts with "53".

select * from sh.customers where cust_postal_code LIKE '53%';

-- 10. Get customers born before 1980 with a credit limit above 5,000.

select * from sh.customers where CUST_YEAR_OF_BIRTH < 1980 AND CUST_CREDIT_LIMIT > 5000;

-- 11. Retrieve customers from Almere or Amersfoort.

select * from sh.customers where cust_city in ('Almere', 'Amersfoort');

select * from sh.customers where cust_city = 'Almere' OR cust_city = 'Amersfoort';

-- 12. Find customers who do not have a credit limit.

select * from sh.customers where cust_credit_limit is null;

-- 13. List customers whose phone number starts with "487".

select * from sh.customers where CUST_MAIN_PHONE_NUMBER like '487%';

-- 14. Find married customers with income level `"Medium"`.

select * from sh.customers where CUST_MARITAL_STATUS = 'married' AND cust_income_level LIKE 'G%' or cust_income_level LIKE 'H%';

-- 15. Get customers whose last name starts with "G".

select * from sh.customers where CUST_LAST_NAME LIKE 'G%';

-- 16. Find customers with city_id = 51057.

select * from sh.customers where CUST_CITY_ID = 51057;

-- 17. Retrieve all customers who are valid (`CUST_VALID = 'A'`).

select * from sh.customers where CUST_VALID = 'A';

-- 18. Find customers whose effective start date (`CUST_EFF_FROM`) is after 2020.

select * from sh.customers where CUST_EFF_FROM > TO_DATE ('31-12-2020','DD-MM-YYYY');

-- 19. Retrieve customers whose effective end date (`CUST_EFF_TO`) is before 2021.

select * from sh.customers where CUST_EFF_TO < TO_DATE('01-01-2021', 'DD_MM_YYYY');

-- 20. Find customers with credit limit between 5,000 and 9,000.

select * from sh.customers where CUST_CREDIT_LIMIT BETWEEN 5000 AND 9000;

-- 21. Get all customers from country_id = 101.

select * from sh.customers where COUNTRY_ID = 101;

-- 22. Find customers whose email ends with `"@company.example.com"`.

select * from sh.customers where CUST_EMAIL LIKE '%@company.example.com';

-- 23. List customers with `CUST_TOTAL_ID = 52772`.

select * from sh.customers where CUST_TOTAL_ID = 52772;

-- 24. Find customers with `CUST_SRC_ID` in (10, 20, 30).

select * from sh.customers where CUST_SRC_ID in (10,20,30);

-- 25. Retrieve customers who either do not have email or do not have a credit limit.

select * from sh.CUSTOMERS where CUST_EMAIL is NULL OR CUST_CREDIT_LIMIT is null;