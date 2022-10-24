FROM python

RUN pip install azure-servicebus

ADD ./load-sb.py /app/load-sb.py

ENTRYPOINT ["python", "/app/load-sb.py"]