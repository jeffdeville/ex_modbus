#!/bin/bash
docker run -d --rm --name modbus-slave  -p 5002:502 jeffdeville/modbus_slave_simulator
mix test
docker stop modbus-slave
