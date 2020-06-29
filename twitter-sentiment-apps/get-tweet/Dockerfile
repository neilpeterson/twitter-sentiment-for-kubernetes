FROM python

RUN pip install tweepy && \
    pip install azure-storage-queue==2.1. && \
    pip install requests

ADD ./get-tweet.py /app/get-tweet.py

ENTRYPOINT ["python", "/app/get-tweet.py"]