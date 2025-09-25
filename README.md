# 🚀 Getting Started with dbt Platform on Snowflake

## 📘 Overview

This repository contains a working **dbt project** to help you get started with **dbt Platform on Snowflake** using sample data from the **Tasty Bytes** dataset.

---

## ❄️ Snowflake Setup Script

### 🔐 Prerequisites

First create a Snowflake Trial account and create a new worksheet to start running the following scripts:

```sql
USE ROLE accountadmin;
```

---

### 🏗️ Create Warehouse, Database, Schema, File Format & Stage

```sql
-- Create Warehouse
CREATE OR REPLACE WAREHOUSE tasty_bytes_dbt_wh
  WAREHOUSE_SIZE = 'medium'
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

On the right you will find the **+ New Project** button

<img width="384" height="324" alt="Screenshot 2025-07-11 at 13 53 56" src="https://github.com/user-attachments/assets/ef1015a7-1ada-49e6-bb61-8cdc41530bf6" />

Name your Analytics Project with your **initials** like Analytics_BvD and click continue

<img width="997" height="286" alt="Screenshot 2025-07-11 at 13 55 12" src="https://github.com/user-attachments/assets/4b594a2f-1d3e-4002-b326-6679902d5201" />

Configure your environment, select the drop down box and select **New Connection**

<img width="958" height="434" alt="Screenshot 2025-07-11 at 13 57 15" src="https://github.com/user-attachments/assets/7c019b50-2f91-4002-bdc9-990968975397" />

Select **Snowflake** and name your connection with your **initials** and follow the connection settings like the example Screenshot:

<img width="1064" height="669" alt="Screenshot 2025-07-11 at 14 09 43" src="https://github.com/user-attachments/assets/a13d41cd-32c5-476f-8001-0c77b85473c4" />


For more information check official: [dbt Cloud OAuth setup guide](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth) to securely connect your dbt project to Snowflake.

### ✅ Steps:

1. Copy paste **Account Identifier** from Snowflake, via left bottom corner click profile, than select account **view account details** 

<img width="487" height="458" alt="Screenshot 2025-07-11 at 14 07 03" src="https://github.com/user-attachments/assets/69508134-2783-42b3-83e8-9ef86ed635b8" />
  
2. Database: **tasty_bytes_dbt_db**
3. Warehouse: **tasty_bytes_dbt_wh**
4. Set the OAuth method to **Snowflake SSO**.
5. Copy the **Redirect URI** for the next step.

![Snowflake OAuth UI Example](https://github.com/user-attachments/assets/8be4e95b-4f6a-4cae-a871-9475acbe1fa4)

---

### 🔐 Create a new worksheet in Snowflake and follow the Security Integration scripts

Replace the **<REDIRECT_URI>** in the OAUTH_REDIRECT_URI = ''

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

Copy Paste the Client_ID & Secret in the setting tab

<img width="462" height="105" alt="Screenshot 2025-07-11 at 14 13 14" src="https://github.com/user-attachments/assets/f8c27bc4-db97-47d1-9636-225d8df53a2e" />

Final Step click **Save**

<img width="839" height="200" alt="Screenshot 2025-07-11 at 14 14 24" src="https://github.com/user-attachments/assets/a4f8486e-6c56-42a7-988a-097bf39bae03" />

Click on the left Menu Panel on **Project** and select yours, than continue with the connection setup. Select your new created connection and add your Username and Password

<img width="1242" height="730" alt="Screenshot 2025-07-11 at 14 22 59" src="https://github.com/user-attachments/assets/a7616810-0631-4c34-98f0-97a2cbdea694" />

Test your connection and Save

<img width="894" height="498" alt="Screenshot 2025-07-11 at 14 24 57" src="https://github.com/user-attachments/assets/87e25ad7-7fca-4561-bbba-031db042b51f" />

## 💻 dbt & Github Setup

### In the third and last step of your project is the Github connection

Select Github and click your user

Select the getting-started-with-dbt-on-snowflake repo

<img width="891" height="644" alt="Screenshot 2025-07-11 at 14 32 05" src="https://github.com/user-attachments/assets/5a9f1287-5ac6-4698-b2af-3aeccb2f2c26" />

Your project is ready and start developing in the IDE

In your Project Create Branch and give it a name

<img width="486" height="506" alt="Screenshot 2025-07-11 at 14 55 29" src="https://github.com/user-attachments/assets/0bbff975-8901-4efc-9a67-421d55d08469" />

At the bottom run **dbt build** to run the whole project in your Snowflake environment

After the run succeeded you can review the materialzed data in your Snowflake Schema or check the run status of every test and model

<img width="1173" height="587" alt="Screenshot 2025-07-11 at 15 17 39" src="https://github.com/user-attachments/assets/b0800f2a-f461-4ca7-b697-527980f8ac02" />

*** 👩‍🏫👨‍🏫 After we run the project succesfully we will create a production Run to visualize our project in dbt Catalog

First select on the left side **Orchestration** and than **Environments** 

<img width="432" height="178" alt="Screenshot 2025-07-11 at 15 26 33" src="https://github.com/user-attachments/assets/3cc9cafd-8599-4474-8e1e-a4ad73889e47" />

Select **New Environment**

<img width="1135" height="235" alt="Screenshot 2025-07-11 at 15 27 46" src="https://github.com/user-attachments/assets/8b2d2d59-026b-44da-8ddb-9ec4b9297c8d" />

Adjust the settings like the example

<img width="978" height="669" alt="Screenshot 2025-07-11 at 15 29 55" src="https://github.com/user-attachments/assets/8453865f-ef14-496d-a216-b04999ec72db" />

and Test your connection + save

<img width="1121" height="537" alt="Screenshot 2025-07-11 at 15 31 14" src="https://github.com/user-attachments/assets/375d5e72-d540-4c7f-9a9f-89644ba700f5" />

After you created the Environment you can create a job, select right bottom corner **Create Job**

<img width="1134" height="712" alt="Screenshot 2025-07-11 at 15 32 24" src="https://github.com/user-attachments/assets/677136b2-551a-46f4-bdf8-5a8a67766cc4" />

Create **Deploy Job**

<img width="307" height="197" alt="Screenshot 2025-07-11 at 15 34 33" src="https://github.com/user-attachments/assets/e2340744-a09b-4aaf-943f-0c3a8e4be2b2" />

Adjust the settings like the example and Save the Job

<img width="1133" height="662" alt="Screenshot 2025-07-11 at 15 35 31" src="https://github.com/user-attachments/assets/752f9ade-4e04-42e0-ad1a-00c61e8b4b90" />

and **Run** the job at the right top Corner

<img width="1124" height="532" alt="Screenshot 2025-07-11 at 15 36 23" src="https://github.com/user-attachments/assets/87cabaa1-642e-4b2f-823e-4ba96801fb4d" />

click on the run at the bottom to review the status

<img width="1139" height="165" alt="Screenshot 2025-07-11 at 15 37 05" src="https://github.com/user-attachments/assets/5915f0ef-514a-421b-9fd7-ffa689fbf5cd" />

After the run succeeded we can explore the dbt Catalog

<img width="624" height="379" alt="Screenshot 2025-07-11 at 15 44 47" src="https://github.com/user-attachments/assets/f42188ff-9257-4da4-87cc-1c00288ad202" />

In the left menu Panel select **Catalog**

<img width="1321" height="725" alt="Screenshot 2025-07-11 at 15 46 20" src="https://github.com/user-attachments/assets/d71d70ff-1966-4b59-8e7a-9ce2f90a45c1" />

In the Catalog overview select on the right side **View lineage** to review your Project

<img width="1153" height="715" alt="Screenshot 2025-07-11 at 15 49 05" src="https://github.com/user-attachments/assets/156ef59a-2d85-45af-aea1-c4230142a4c3" />

---

### 📚 What is the dbt Catalog?

The **dbt Catalog** is a centralized, auto-generated documentation system for your dbt project. It includes:

- ✅ **All models and sources** in your project
- 🧾 **Column-level metadata** (name, type, and descriptions)
- 🔍 **Lineage graphs** showing how raw data flows through staging models to final outputs
- 💬 **Documentation strings** written in your `.yml` files for models, tests, and macros

### 🔎 Why it matters

- **For analysts and stakeholders**: The catalog gives transparency into what data is available, where it comes from, and how it's transformed.
- **For data teams**: It reduces tribal knowledge, accelerates onboarding, and ensures that data definitions are consistent across the organization.
- **For governance**: It supports data audits, compliance, and lineage tracking.

💡 After every production job run, the catalog is automatically updated to reflect the latest changes in your dbt project.

---

## 🌱 Where to Go Next — Extend Your dbt Project

### 🧠 1. Add Documentation via dbt Copilot in the Studio
Use the **Documentation** function from Copilot to create documenation of your model in a .yml file:
- Select your model as an example in the marts folder
- Select dbt Copilot on the right, below the editor
- Select Documentation and Copilot will generate the .yml file

<img width="1150" height="681" alt="Screenshot 2025-07-11 at 16 09 30" src="https://github.com/user-attachments/assets/f45d79b1-ee5b-429e-a4d2-840cf0337b03" />


### 📏 2. Define and Run dbt Tests
Use `.yml` configurations for:
- `unique`, `not_null`, `accepted_values`, `relationships`
- Custom logic validations

### 🔨 3. Add Descriptions & Tags
Add metadata in `schema.yml`:
- Model and column descriptions
- Tags like `tier: core`, `owner: finance_team`

### 🧮 4. Build Business Logic Models
Develop `int_`, `fct_`, and `dim_` models for analytics:
- Examples: `dim_customer`, `fct_sales`, `int_order_metrics`

### 📊 5. Integrate with BI Tools
Feed your semantic-ready dbt models into tools like Tableau, Looker, or Power BI.

### ⏱️ 6. Schedule & Monitor Jobs
Use dbt Cloud Jobs to:
- Schedule builds
- Monitor failures
- Integrate via API

### 👥 7. Enable Role-Based Access
Use Snowflake views and row access policies for governed data exposure.

### 🌍 8. Collaborate with Git Workflow
- Use branches and pull requests
- Trigger CI/CD validations
- Promote model changes safely

---

## ✅ Summary

By completing this guide, you have:
- Built a functioning dbt project on Snowflake
- Configured dbt Platform with GitHub and OAuth
- Executed jobs and reviewed models in the dbt Catalog
- Learned how to extend your project with best practices

You're now ready to scale your data transformations with dbt Platform!

---
