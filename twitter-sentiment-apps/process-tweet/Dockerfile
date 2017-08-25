FROM python

RUN pip install pydocumentdb && \
    pip install azure-storage && \
    pip install requests

ADD ./process-tweet.py /app/process-tweet.py

CMD ["/bin/sh", "-c", "python -u /app/process-tweet.py > kubelog.log 2>&1"]