FROM python

RUN pip install pydocumentdb && \
    pip install azure-storage && \
    pip install requests

ADD ./process-tweet.py /app/process-tweet.py

ENTRYPOINT ["python", "/app/process-tweet.py"]