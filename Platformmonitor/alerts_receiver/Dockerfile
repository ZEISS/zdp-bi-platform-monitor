FROM python:3.12

COPY ./webhookproxy.py /alerts_receiver/webhookproxy.py
COPY ./requirements.txt /alerts_receiver/requirements.txt
WORKDIR /alerts_receiver
RUN pip install -r requirements.txt
CMD ["python3", "/alerts_receiver/webhookproxy.py"]