FROM python

RUN pip install pydocumentdb && \
    pip install azure-servicebus && \
    pip install requests

ADD ./sb-process-tweet.py /app/sb-process-tweet.py

# CMD ["/bin/sh", "-c", "python -u /app/process-tweet.py > kubelog.log 2>&1"]
CMD ["/bin/sh", "-c", "python -u /app/sb-process-tweet.py"]