# Databricks notebook source
# Mount Azure Data Lake Storage
storage_account_name = "airlinedelaylake"
storage_account_key = "YOUR_STORAGE_ACCOUNT_KEY_HERE"  # Store securely, do not commit real keys
container_name = "bronze"

spark.conf.set(
    f"fs.azure.account.key.{storage_account_name}.dfs.core.windows.net",
    storage_account_key
)

# Read all CSV files from Bronze
df = spark.read.csv(
    f"abfss://bronze@{storage_account_name}.dfs.core.windows.net/",
    header=True,
    inferSchema=True
)

print("Total records:", df.count())
df.printSchema()


# COMMAND ----------

from pyspark.sql.functions import col, when, trim, expr

# Fix data types - handle any non-numeric string before casting
def safe_cast(column_name):
    return when(
        trim(col(column_name)).rlike("^-?[0-9]+(\\.[0-9]+)?$"),
        col(column_name).cast("double")
    ).otherwise(None)

# Fix data types - use expr for date parsing to handle malformed dates
df_silver = df \
    .withColumn("FL_DATE", expr("try_to_date(FL_DATE, 'yyyy-MM-dd')")) \
    .withColumn("DEP_DELAY", safe_cast("DEP_DELAY")) \
    .withColumn("ARR_DELAY", safe_cast("ARR_DELAY")) \
    .withColumn("CANCELLED", safe_cast("CANCELLED")) \
    .withColumn("DIVERTED", safe_cast("DIVERTED")) \
    .withColumn("CRS_ELAPSED_TIME", safe_cast("CRS_ELAPSED_TIME")) \
    .withColumn("ACTUAL_ELAPSED_TIME", safe_cast("ACTUAL_ELAPSED_TIME")) \
    .withColumn("AIR_TIME", safe_cast("AIR_TIME")) \
    .withColumn("DISTANCE", safe_cast("DISTANCE"))

# Drop rows where key columns are null
df_silver = df_silver.dropna(subset=["FL_DATE", "OP_CARRIER", "ORIGIN", "DEST"])

# Write to Silver container
df_silver.write.mode("overwrite").parquet(
    f"abfss://silver@{storage_account_name}.dfs.core.windows.net/flights_cleaned"
)

print("Silver layer written successfully!")
print("Total clean records:", df_silver.count())


# COMMAND ----------

from pyspark.sql.functions import col, avg, count, round

# Aggregate by Airline and Date
df_gold = df_silver.groupBy("OP_CARRIER", "FL_DATE") \
    .agg(
        count("*").alias("total_flights"),
        round(avg("DEP_DELAY"), 2).alias("avg_dep_delay"),
        round(avg("ARR_DELAY"), 2).alias("avg_arr_delay"),
        round(avg("CANCELLED"), 4).alias("cancellation_rate"),
        round(avg("DISTANCE"), 2).alias("avg_distance")
    )

# Write to Gold container
df_gold.write.mode("overwrite").parquet(
    f"abfss://gold@{storage_account_name}.dfs.core.windows.net/flights_aggregated"
)

print("Gold layer written successfully!")
print("Total aggregated records:", df_gold.count())