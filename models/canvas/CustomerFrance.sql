WITH raw_customer_customer_loyalty AS (
  SELECT
    *
  FROM {{ ref('raw_customer_customer_loyalty') }}
), filter_1 AS (
  SELECT
    *
  FROM raw_customer_customer_loyalty
  WHERE
    COUNTRY = 'France'
), customerfrance_sql AS (
  SELECT
    CUSTOMER_ID,
    FIRST_NAME,
    LAST_NAME,
    CITY,
    COUNTRY,
    POSTAL_CODE,
    PREFERRED_LANGUAGE,
    GENDER,
    FAVOURITE_BRAND,
    MARITAL_STATUS,
    CHILDREN_COUNT,
    SIGN_UP_DATE,
    BIRTHDAY_DATE,
    E_MAIL,
    PHONE_NUMBER
  FROM filter_1
)
SELECT
  *
FROM customerfrance_sql