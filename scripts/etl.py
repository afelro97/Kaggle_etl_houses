from statistics import mean

import findspark
findspark.init()

import pyspark
from pyspark.sql.functions import col
from pyspark.sql import SparkSession

# Initialize SparkSession
spark = SparkSession.builder.appName("KaggleHousesETL").getOrCreate()

# Load the dataset into a DataFrame
df = spark.read.format("csv").option("header", "true").load("/home/jovyan/work/data/housing.csv")

# Drop columns that are not useful for analysis
df = df.drop("Id", "Alley", "FireplaceQu", "PoolQC", "Fence", "MiscFeature")

# Verificar si hay columnas con tipos de datos "int" o "double"
int_double_cols = [c for c, t in df.dtypes if t in ["integer", "double"]]

if int_double_cols:
    # Construir lista de expresiones para la agregación
    mean_exprs = [round(col(c).mean(), 2).alias(c) for c in int_double_cols]
    # Agregar la agregación al DataFrame
    mean_values = df.agg(*mean_exprs).toDict()
    # Rellenar los valores faltantes con la media
    df = df.fillna(mean_values)
else:
    print("No hay columnas con tipos de datos 'int' o 'double'")


# Fill in missing values with the mean of the column
#mean_values = df.select([col(c).alias(c+"_mean") for c in df.columns if df.select([col(c)]).dtypes[0][1] == "int" or df.select([col(c)]).dtypes[0][1] == "double"]).agg(*[(round(mean(c), 2)).alias(c) for c in df.columns if df.select([col(c)]).dtypes[0][1] == "int" or df.select([col(c)]).dtypes[0][1] == "double"]).toDict()
#df = df.fillna(mean_values)


# Fill in missing values with the mean of the column
for col_name in df.columns:
    if df.select(col_name).dtypes[0][1] in ["int", "double"]:
        mean_value = df.select(col_name).agg({"*": "avg"}).collect()[0][0]
        df = df.na.fill(mean_value, subset=[col_name])



# Write the cleaned dataset to a new CSV file
df.write.format("csv").option("header", "true").mode("overwrite").save("/home/jovyan/work/data/cleaned_train.csv")
