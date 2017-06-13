defmodule Modbus.Rtu do
  @moduledoc """
  Wrap and parse Modbus RTU packets.
  """

  alias Modbus.Crc16

  # reading functions
  @function_read_coil_status 0x01
  @function_read_input_status 0x02
  @function_read_holding_registers 0x03
  @function_read_input_registers 0x04

  # writing functions
  @function_force_single_coil 0x05
  @function_preset_single_register 0x06
  @function_force_multiple_coils 0x0f
  @function_preset_multiple_registers 0x10

  @doc """
  Wrap `packet` in the Modbus Application Header appropriate for TCP/IP transport.
  """
  def wrap_packet(packet, slave_id) do
    packet_with_slave = <<slave_id::size(8), packet::binary>>
    <<slave_id::size(8), packet::binary, Crc16.crc_16(packet_with_slave)::size(16)-little>>
  end

  @doc """
  Remove formatting around a "Read Coil Status" call (modbus func 01)
  """
  def unwrap_packet(<<slave_id::size(8), @function_read_coil_status, length::size(8), packet::binary>>) do
    packet_without_crc = Kernel.binary_part(packet, 0, length)
    %{content_length: length, slave_id: slave_id, packet: packet_without_crc}
  end

  @doc """
  Remove formatting around a "Read Input Status" call (modbus func 02)
  """
  def unwrap_packet(<<slave_id::size(8), @function_read_input_status, length::size(8), packet::binary>>) do
    packet_without_crc = Kernel.binary_part(packet, 0, length)
    %{content_length: length, slave_id: slave_id, packet: packet_without_crc}
  end

  @doc """
  Remove formatting around a "Read Multiple Holding Registers" call (modbus func 03)
  """
  def unwrap_packet(<<slave_id::size(8), @function_read_holding_registers, _length::size(8), _rest_of_packet::binary>>=packet) do
    length = byte_size(packet)-3 # minus 3 to remove slave ID and CRC16
    packet_without_crc = Kernel.binary_part(packet, 1, length)
    %{content_length: length, slave_id: slave_id, packet: packet_without_crc}
  end

  @doc """
  Remove formatting around a "Read Input Registers" call (modbus func 04)
  """
  def unwrap_packet(<<slave_id::size(8), @function_read_input_registers, length::size(8), packet::binary>>) do
    packet_without_crc = Kernel.binary_part(packet, 0, length) # +2 because this includes the command and length bytes, plus our data length
    %{content_length: length, slave_id: slave_id, packet: packet_without_crc}
  end

  @doc """
  Remove formatting around a "Force Single Coil" call (modbus func 05)
  """
  def unwrap_packet(<<slave_id::size(8), @function_force_single_coil, _rest_of_packet::binary>>=packet) do
    length = byte_size(packet)-3 # minus 3 to remove slave ID and CRC16
    packet_without_crc = Kernel.binary_part(packet, 1, length) # -2 because to remove length of the CRC16
    %{content_length: length, slave_id: slave_id, packet: packet_without_crc}
  end

  @doc """
  Remove formatting around a "Preset Single Register" call (modbus func 06)
  """
  def unwrap_packet(<<slave_id::size(8), @function_preset_single_register, _rest_of_packet::binary>>=packet) do
    length = byte_size(packet)-3 # minus 3 to remove slave ID and CRC16
    packet_without_crc = Kernel.binary_part(packet, 1, length) # -2 because to remove length of the CRC16
    %{content_length: length, slave_id: slave_id, packet: packet_without_crc}
  end

  @doc """
  Remove formatting around a "Force Multiple Coils" call (modbus func 15)
  """
  def unwrap_packet(<<slave_id::size(8), @function_force_multiple_coils, _rest_of_packet::binary>>=packet) do
    length = byte_size(packet)-3 # minus 3 to remove slave ID and CRC16
    packet_without_crc = Kernel.binary_part(packet, 1, length) # -2 because to remove length of the CRC16
    %{content_length: length, slave_id: slave_id, packet: packet_without_crc}
  end

  @doc """
  Remove formatting around a "Preset Multiple Registers" call (modbus func 16)
  """
  def unwrap_packet(<<slave_id::size(8), @function_preset_multiple_registers, _rest_of_packet::binary>>=packet) do
    length = byte_size(packet)-3 # minus 3 to remove slave ID and CRC16
    packet_without_crc = Kernel.binary_part(packet, 1, length)
    %{content_length: length, slave_id: slave_id, packet: packet_without_crc}
  end

end
