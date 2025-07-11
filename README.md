# 🚀 Getting Started with dbt on Snowflake

## 📘 Overview

This repository contains a working **dbt project** to help you get started with **dbt on Snowflake** using sample data from the **Tasty Bytes** dataset.

---

## ❄️ Snowflake Setup Script

### 🔐 Prerequisites

Ensure you have the necessary permissions (use a role like `ACCOUNTADMIN`) and an active Snowflake session.

```sql
USE ROLE accountadmin;
```

---

### 🏗️ Create Warehouse, Database, Schema, File Format & Stage

```sql
-- Create Warehouse
CREATE OR REPLACE WAREHOUSE tasty_bytes_dbt_wh
  WAREHOUSE_SIZE = 'small'
  WAREHOUSE_TYPE = 'standard'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'warehouse for tasty bytes dbt demo';

USE WAREHOUSE tasty_bytes_dbt_wh;

-- Create Database & Schema
CREATE DATABASE IF NOT EXISTS tasty_bytes_dbt_db;
CREATE OR REPLACE SCHEMA tasty_bytes_dbt_db.raw;

-- Create File Format & Stage
CREATE OR REPLACE FILE FORMAT tasty_bytes_dbt_db.public.csv_ff TYPE = 'csv';

CREATE OR REPLACE STAGE tasty_bytes_dbt_db.public.s3load
  COMMENT = 'Quickstarts S3 Stage Connection'
  URL = 's3://sfquickstarts/frostbyte_tastybytes/'
  FILE_FORMAT = tasty_bytes_dbt_db.public.csv_ff;
```

---

### 🧱 Create Raw Zone Tables

<details>
<summary><strong>Click to expand raw table DDLs</strong></summary>

```sql
-- Country
CREATE OR REPLACE TABLE tasty_bytes_dbt_db.raw.country (
  country_id NUMBER(18,0),
  country VARCHAR,
  iso_currency VARCHAR(3),
  iso_country VARCHAR(2),
  city_id NUMBER(19,0),
  city VARCHAR,
  city_population VARCHAR
) COMMENT = '{"origin":"sf_sit-is", "name":"tasty-bytes-dbt", "version":{"major":1,"minor":0},"attributes":{"is_quickstart":1,"source":"sql"}}';

-- Franchise
CREATE OR REPLACE TABLE tasty_bytes_dbt_db.raw.franchise (
  franchise_id NUMBER(38,0),
  first_name VARCHAR,
  last_name VARCHAR,
  city VARCHAR,
  country VARCHAR,
  e_mail VARCHAR,
  phone_number VARCHAR
) COMMENT = '{"origin":"sf_sit-is", "name":"tasty-bytes-dbt", ...}';

-- Location
CREATE OR REPLACE TABLE tasty_bytes_dbt_db.raw.location (
  location_id NUMBER(19,0),
  placekey VARCHAR,
  location VARCHAR,
  city VARCHAR,
  region VARCHAR,
  iso_country_code VARCHAR,
  country VARCHAR
) COMMENT = '{"origin":"sf_sit-is", ...}';

-- Menu
CREATE OR REPLACE TABLE tasty_bytes_dbt_db.raw.menu (
  menu_id NUMBER(19,0),
  menu_type_id NUMBER(38,0),
  menu_type VARCHAR,
  truck_brand_name VARCHAR,
  menu_item_id NUMBER(38,0),
  menu_item_name VARCHAR,
  item_category VARCHAR,
  item_subcategory VARCHAR,
  cost_of_goods_usd NUMBER(38,4),
  sale_price_usd NUMBER(38,4),
  menu_item_health_metrics_obj VARIANT
) COMMENT = '{"origin":"sf_sit-is", ...}';

-- Truck
CREATE OR REPLACE TABLE tasty_bytes_dbt_db.raw.truck (
  truck_id NUMBER(38,0),
  menu_type_id NUMBER(38,0),
  primary_city VARCHAR,
  region VARCHAR,
  iso_region VARCHAR,
  country VARCHAR,
  iso_country_code VARCHAR,
  franchise_flag NUMBER,
  year NUMBER,
  make VARCHAR,
  model VARCHAR,
  ev_flag NUMBER,
  franchise_id NUMBER,
  truck_opening_date DATE
) COMMENT = '{"origin":"sf_sit-is", ...}';

-- Order Header
CREATE OR REPLACE TABLE tasty_bytes_dbt_db.raw.order_header (
  order_id NUMBER,
  truck_id NUMBER,
  location_id FLOAT,
  customer_id NUMBER,
  discount_id VARCHAR,
  shift_id NUMBER,
  shift_start_time TIME,
  shift_end_time TIME,
  order_channel VARCHAR,
  order_ts TIMESTAMP_NTZ,
  served_ts VARCHAR,
  order_currency VARCHAR(3),
  order_amount NUMBER(38,4),
  order_tax_amount VARCHAR,
  order_discount_amount VARCHAR,
  order_total NUMBER(38,4)
) COMMENT = '{"origin":"sf_sit-is", ...}';

-- Order Detail
CREATE OR REPLACE TABLE tasty_bytes_dbt_db.raw.order_detail (
  order_detail_id NUMBER,
  order_id NUMBER,
  menu_item_id NUMBER,
  discount_id VARCHAR,
  line_number NUMBER,
  quantity NUMBER(5,0),
  unit_price NUMBER(38,4),
  price NUMBER(38,4),
  order_item_discount_amount VARCHAR
) COMMENT = '{"origin":"sf_sit-is", ...}';

-- Customer Loyalty
CREATE OR REPLACE TABLE tasty_bytes_dbt_db.raw.customer_loyalty (
  customer_id NUMBER,
  first_name VARCHAR,
  last_name VARCHAR,
  city VARCHAR,
  country VARCHAR,
  postal_code VARCHAR,
  preferred_language VARCHAR,
  gender VARCHAR,
  favourite_brand VARCHAR,
  marital_status VARCHAR,
  children_count VARCHAR,
  sign_up_date DATE,
  birthday_date DATE,
  e_mail VARCHAR,
  phone_number VARCHAR
) COMMENT = '{"origin":"sf_sit-is", ...}';
```

</details>

---

### 📥 Load Data into Raw Tables

```sql
-- Country
COPY INTO tasty_bytes_dbt_db.raw.country FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/country/;

-- Franchise
COPY INTO tasty_bytes_dbt_db.raw.franchise FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/franchise/;

-- Location
COPY INTO tasty_bytes_dbt_db.raw.location FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/location/;

-- Menu
COPY INTO tasty_bytes_dbt_db.raw.menu FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/menu/;

-- Truck
COPY INTO tasty_bytes_dbt_db.raw.truck FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/truck/;

-- Customer Loyalty
COPY INTO tasty_bytes_dbt_db.raw.customer_loyalty FROM @tasty_bytes_dbt_db.public.s3load/raw_customer/customer_loyalty/;

-- Order Header
COPY INTO tasty_bytes_dbt_db.raw.order_header FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/order_header/;

-- Order Detail
COPY INTO tasty_bytes_dbt_db.raw.order_detail FROM @tasty_bytes_dbt_db.public.s3load/raw_pos/order_detail/;

-- Setup Completion Check
SELECT 'tasty_bytes_dbt_db setup is now complete' AS note;
```

---

## 🔄 dbt & Snowflake Integration Setup

First create a new project via the "Account Home" page

<img width="1302" height="730" alt="Screenshot 2025-07-11 at 13 52 00" src="https://github.com/user-attachments/assets/1920af9c-328d-4113-bdda-c1c30f8dd3ba" />

On the right you will find the + New Project button

<img width="384" height="324" alt="Screenshot 2025-07-11 at 13 53 56" src="https://github.com/user-attachments/assets/ef1015a7-1ada-49e6-bb61-8cdc41530bf6" />

Name your Analytics Project with your initials like Analytics_BvD and click continue

<img width="997" height="286" alt="Screenshot 2025-07-11 at 13 55 12" src="https://github.com/user-attachments/assets/4b594a2f-1d3e-4002-b326-6679902d5201" />

Configure your environment, select the drop down box and select New Connection

<img width="958" height="434" alt="Screenshot 2025-07-11 at 13 57 15" src="https://github.com/user-attachments/assets/7c019b50-2f91-4002-bdc9-990968975397" />

Select Snowflake and Follow the steps 

For more information check official: [dbt Cloud OAuth setup guide](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth) to securely connect your dbt project to Snowflake.

Example Screenshot:

<img width="1335" height="730" alt="Screenshot 2025-07-11 at 13 47 47" src="https://github.com/user-attachments/assets/d009db1e-aecc-459f-be22-8da9eebf3713" />


### ✅ Steps:

1. Navigate to **Account Settings** in dbt Cloud.
2. Select **Projects**, then choose your project.
3. Click the **Development Connection** field.
4. Set the OAuth method to **Snowflake SSO**.
5. Copy the **Redirect URI** for the next step.

![Snowflake OAuth UI Example](https://github.com/user-attachments/assets/8be4e95b-4f6a-4cae-a871-9475acbe1fa4)

---

### 🔐 Create Snowflake Security Integration

```sql
CREATE OR REPLACE SECURITY INTEGRATION DBT_CLOUD
  TYPE = OAUTH
  ENABLED = TRUE
  OAUTH_CLIENT = CUSTOM
  OAUTH_CLIENT_TYPE = 'CONFIDENTIAL'
  OAUTH_REDIRECT_URI = '<REDIRECT_URI>'
  OAUTH_ISSUE_REFRESH_TOKENS = TRUE
  OAUTH_REFRESH_TOKEN_VALIDITY = 7776000
  OAUTH_USE_SECONDARY_ROLES = 'IMPLICIT';
```

---

### 🔑 Retrieve OAuth Client ID & Secret

```sql
WITH integration_secrets AS (
  SELECT PARSE_JSON(SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('DBT_CLOUD')) AS secrets
)
SELECT
  secrets:"OAUTH_CLIENT_ID"::STRING     AS client_id,
  secrets:"OAUTH_CLIENT_SECRET"::STRING AS client_secret
FROM integration_secrets;
```

---
