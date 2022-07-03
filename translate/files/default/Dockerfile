FROM python:3-slim

RUN apt-get update && apt-get install -y --no-install-recommends git && \
    git clone "https://codeberg.org/SimpleWeb/SimplyTranslate-Engines" engines && \
    git clone "https://codeberg.org/SimpleWeb/SimplyTranslate-Web" web && \
    # apt-get purge -y --auto-remove git && \  # needed in pip install requirements
    rm -rf /var/lib/apt/lists/*

WORKDIR /engines
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        automake libtool g++-multilib-i686-linux-gnu zlib1g-dev \
        build-essential gcc g++ libxml2 libxml2-dev libxslt1.1 libxslt1-dev && \
    sed -i 's/"aiohttp"/"aiohttp<4"/g' setup.py && \
    python3 setup.py install && \
    pip install -r requirements.txt && \
    apt-get purge -y --auto-remove \
        automake libtool g++-multilib-i686-linux-gnu zlib1g-dev \
        build-essential gcc g++ libxml2 libxml2-dev libxslt1.1 libxslt1-dev && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /web
RUN pip install -r requirements.txt

EXPOSE 5000
CMD ["python3", "main.py"]
