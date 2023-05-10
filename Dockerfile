FROM ubuntu:latest

# Instalar dependencias
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget curl && \
    rm -rf /var/lib/apt/lists/*

# Descargar e instalar Spark
RUN wget -q https://downloads.apache.org/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz && \
    tar xf spark-3.2.0-bin-hadoop3.2.tgz && \
    mv spark-3.2.0-bin-hadoop3.2 /usr/local/spark && \
    rm spark-3.2.0-bin-hadoop3.2.tgz

# Instalar el cliente de Postgres
RUN apt-get update && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Establecer variables de entorno para Spark y Java
ENV SPARK_HOME=/usr/local/spark
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Agregar la ruta de Spark y Postgres al PATH
ENV PATH=$PATH:$SPARK_HOME/bin:/usr/lib/postgresql/13/bin/

# Copiar los archivos de configuración de Spark al contenedor
COPY spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf
COPY log4j.properties $SPARK_HOME/conf/log4j.properties

# Copiar el script de ETL y los archivos de datos al contenedor
COPY scripts/etl.py /home/jovyan/work/etl.py
COPY data/ /home/jovyan/work/data/

# Exponer los puertos de Spark
EXPOSE 4040 7077 8080 8081

# Ejecutar el script de ETL
CMD ["spark-submit", "--master", "spark://spark-master:7077", "/home/jovyan/work/etl.py"]
