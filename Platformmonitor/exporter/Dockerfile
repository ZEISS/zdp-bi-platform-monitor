FROM python:3.12

COPY sap_telemetry_exporter.py /exporter/sap_telemetry_exporter.py
COPY requirements.txt /exporter/requirements.txt
COPY config.ini /exporter/config/config.ini
WORKDIR /exporter
RUN pip install -r requirements.txt
CMD ["python3", "/exporter/sap_telemetry_exporter.py"]