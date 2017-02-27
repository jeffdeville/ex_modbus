FROM python:2.7-alpine
MAINTAINER Jeff Deville

RUN apk --update add alpine-sdk
EXPOSE 502
ENV REFRESHED_AT 2017-02-16_17:38

# Download and run modsim
RUN mkdir /app
RUN git clone https://github.com/jeffdeville/device-webprobe.git -b dockerize /app
WORKDIR /app
RUN git pull
WORKDIR /app/modsim
RUN pip install -r requirements.txt
CMD ["python", "modsim.py", "-m", "tcp", "mbmap_test_device.xml"]
