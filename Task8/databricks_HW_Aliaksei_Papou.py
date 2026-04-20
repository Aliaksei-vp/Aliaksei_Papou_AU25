# Databricks notebook source
# MAGIC %md
# MAGIC ## Databricks Homework
# MAGIC Since in July 2025 Databricks Community Edition was deprecated and instead of creating separate cluster they are being provided in serverless mode it will be easier for you to work with data - since all the data and tables will be saving not only when cluster as active.
# MAGIC
# MAGIC So, no separate activities for cluser creating should be executed - it will be autoattached/started when you will execute any of the cells below.
# MAGIC
# MAGIC
# MAGIC Please, create table in the default schema using file Sales_December_2019.csv. On the left found Catalog => Add Data => Drop files to upload, or click to browse => Sales_December_2019.csv After file will be uploaded, just need to confirm that table should be uploaded.
# MAGIC
# MAGIC  Make sure that the first row is header selected => Create Table. Table will be created with name that you specified (sales_december_2019 by default) You will be able to change the table name later if needed.

# COMMAND ----------

# MAGIC %md
# MAGIC PySpark can process SQL queries as a text. In other words you don't need to switch cell language to SQL.
# MAGIC 1. Write data from table that you created into the dataframe using PySpark with SQL query. Show data in the dataframe

# COMMAND ----------

# Create DataFrame from SQL query
df = spark.sql("SELECT * FROM sales_december_2019")

display(df) 


# COMMAND ----------

# MAGIC %md
# MAGIC Any notebook can be parameterized using dbutils.widgets. Try to add one parameter "Product_name" and select data from dataframe filtered by value from this parameter. 
# MAGIC
# MAGIC 2. Select data where product = "product_name" from dataframe using PySpark

# COMMAND ----------

dbutils.widgets.text("Product_name", "USB-C Charging Cable")

product_filter = dbutils.widgets.get("Product_name")

filtered_df = df.filter(df["Product"] == product_filter)

display(filtered_df)

# COMMAND ----------

# MAGIC %md
# MAGIC As well as in SQL, in PySpark you can use aggregate functions. Package pyspark.sql.functions contains all aggregated function from SQL. Try to perform simple aggregation with dataframe. Don't forget, that column types, which you want to calculate, shoud be numerical.  
# MAGIC 3. Calculate the sales for each product, including the number of products sold

# COMMAND ----------

from pyspark.sql.functions import col, sum, count

sales_df = df.filter(col("Quantity Ordered") != "Quantity Ordered") \
             .withColumn("Quantity Ordered", col("Quantity Ordered").cast("int")) \
             .withColumn("Price Each", col("Price Each").cast("float"))

product_sales = sales_df.groupBy("Product").agg(
    count("Quantity Ordered").alias("Units_Sold_Count"),
    sum(col("Quantity Ordered") * col("Price Each")).alias("Total_Revenue")
)

display(product_sales)



# COMMAND ----------

# MAGIC %md
# MAGIC In the PySpark you can perform dataframe profiling using one of two special commands or simple aggregated functions. Try to find special commands to complete this task or just use aggregated functions. Hint: please, сhange the column data types based on the data in them
# MAGIC
# MAGIC 4. Show data profiles output for the new dataframe of table sales_december_2019_csv: row count, min and max value for each column

# COMMAND ----------

display(sales_df.summary("count", "min", "max"))

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC 5. Add new column to the dataframe from previous task with any default value that you want

# COMMAND ----------

from pyspark.sql.functions import lit

final_df = sales_df.withColumn("Status", lit("Processed"))

display(final_df)

# COMMAND ----------

# MAGIC %md
# MAGIC Temporary views are processed by cluster and always dropped when the session ends (when the cluster turns off).
# MAGIC
# MAGIC 6. Create temporary view from task 4 dataframe using PySpark and perform any select using SQL

# COMMAND ----------

final_df.createOrReplaceTempView("v_sales_final")


# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT Product, SUM(`Quantity Ordered`) as total_qty
# MAGIC FROM v_sales_final
# MAGIC GROUP BY Product
# MAGIC ORDER BY total_qty DESC
# MAGIC LIMIT 10