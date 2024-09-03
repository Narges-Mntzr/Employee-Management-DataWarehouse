# Employee Management Data Warehouse

This project implements an Employee Management Data Warehouse, designed to aggregate, clean, and analyze employee data from various sources. The data warehouse can be used for generating reports, performing advanced analytics, and supporting decision-making processes within an organization.

## Project Structure

The repository contains several SQL scripts, Python scripts, and diagram files that together form the backbone of the data warehouse implementation:

1. **SQL Scripts**
    - `1.create_tables.sql`: Contains SQL commands to create the necessary tables for the initial staging area.
    - `2.load_initial_data.py`: A Python script to load the initial batch of data into the staging area tables.
    - `3.load_initial_data.sql`: SQL script to load data into the tables created in the staging area.
    - `4.create_sa_tables.sql`: Defines the structure of the tables within the Staging Area (SA).
    - `5.move_clean_data_to_sa.sql`: SQL commands to clean the data and move it from the initial staging area to the SA tables.
    - `6.create_dw_tables.sql`: Defines the tables in the Data Warehouse (DW).
    - `7.additional_function.sql`: Contains additional SQL functions that may be used within the warehouse for various purposes.
    - `8.first_load_dw.sql`: SQL commands to perform the initial load of data into the data warehouse.
    - `9.load_dw.sql`: Handles the subsequent loads into the DW.

2. **Diagrams**
    - `ER-Diagram.drawio` & `ER-Diagram.png`: Entity-Relationship Diagram illustrating the structure and relationships of the tables within the data warehouse.
    - `Star-Diagram-dim.png` & `Star-Diagram-fact.png`: Diagrams that illustrate the star schema model for the dimensional and fact tables in the data warehouse.

3. **Reports**
    - `Report.pdf`: A comprehensive report detailing the project, its goals, implementation, and results.

## Usage

1. **Creating Tables**: Run the SQL scripts in the order specified to set up the necessary database tables.
2. **Loading Data**: Use the Python and SQL scripts to load initial data into the staging area, clean it, and transfer it to the data warehouse.
3. **Diagrams**: Refer to the ER and star schema diagrams to understand the data structure and relationships.
4. **Analysis and Reporting**: Once the data is loaded, use the data warehouse for reporting and analytics as required.

## Requirements

- Python 3.x
- A SQL-compatible database (e.g., MySQL, PostgreSQL)
- Database client tools to execute the SQL scripts

## Installation

1. Clone this repository:
    ```
    git clone https://github.com/Narges-Mntzr/Employee-Management-DataWarehouse.git
    ```
2. Navigate to the project directory:
    ```
    cd Employee-Management-DataWarehouse
    ```
3. Set up the database using the provided SQL scripts.
