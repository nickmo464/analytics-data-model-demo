# analytics-data-model-demo
demonstration data set showing data model from a transactional system to an analytics system

All sql files are in a Postgres dialect.

1. First run the `analytics_ddl.sql` to create the schemas and tables.  
2. Then run the `transaction_dummy_data.sql` to populate the transactional tables.
3. Finally, explore the `analytics_etl.sql` to get a feel for how ETL jobs can work to populate the dimensional model tables.
