FROM jupyter/pyspark-notebook:latest

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql \
        postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install findspark

#USER $NB_UID
USER root

# Copiar los archivos de datos al contenedor
COPY data/ /home/jovyan/work/data/

# Copiar el script de ETL al contenedor
COPY scripts/etl.py /home/jovyan/work/etl.py

# Instalar librerías adicionales
RUN pip install pandas

# Ejecutar el proceso de ETL
RUN python /home/jovyan/work/etl.py

# Cambiar permisos del directorio de trabajo y archivos de entrada/salida
RUN chown -R 1000:1000 /home/jovyan/work
RUN chmod -R 777 /home/jovyan/work/data
RUN chmod -R 777 /home/jovyan/work/etl.py

EXPOSE 8888
