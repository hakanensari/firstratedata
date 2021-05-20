FROM jupyter/datascience-notebook

ENV JUPYTER_ENABLE_LAB yes

USER root

RUN apt-get update && \
    apt-get install -y -qq \
        libpq-dev

USER $NB_UID

RUN pip install \
        psycopg2

RUN pip install \
    	jupyterlab_code_formatter \
    	black \
    	isort

CMD ["start.sh", "jupyter", "lab"]
