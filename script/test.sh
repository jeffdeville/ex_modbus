#!/bin/bash
docker stop modbus-slave
docker run -d --rm --name modbus-slave  -p 5002:502 jeffdeville/modbus_slave_simulator
mix test
# mix test.watch test/ex_modbus_test.exs
docker stop modbus-slave
