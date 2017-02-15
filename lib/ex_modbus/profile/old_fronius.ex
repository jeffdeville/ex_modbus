defmodule ExModbus.Types do
  # def convert_type(data, "uint16"), do: convert_type(data, String.to_atom("unsigned-integer-size(16)"))

  # def convert_type(<<float::>>, "float32"), do: {:ok, float}
  # Eventually, I'll want to look this value up in the bitfield lookups I can define.
  def convert_type(<<bitfield::unsigned-integer-size(32)>>, :bitfield32), do: {:ok, bitfield}
  # Eventually, I'll want to look this value up in the enum blocks I can define.
  def convert_type(<<int::signed-integer-size(16)>>, :int16), do: {:ok, int}
  def convert_type(<<uint::unsigned-integer-size(16)>>, :enum16), do: {:ok, uint}
  def convert_type(<<uint::unsigned-integer-size(16)>>, :uint16), do: {:ok, uint}
  def convert_type(<<uint::unsigned-integer-size(32)>>, :uint32), do: {:ok, uint}
  def convert_type(<<scale_factor::signed-integer-size(16)>>, :sunssf), do: {:ok, scale_factor}

  def convert_type(<<flt::float-size(32)>>, :float32), do: {:ok, flt}
  def convert_type(<<flt::float-size(16)>>, :float16), do: {:ok, flt}

  def convert_type(data, :string32), do: convert_type(data, :string)
  def convert_type(data, :string16), do: convert_type(data, :string)
  def convert_type(data, <<"String", _size::binary>>), do: convert_type(data, :string)
  def convert_type(data, :string) do
    res = data
    |> :binary.bin_to_list
    |> Enum.filter(fn(byte) -> byte != 0 end)
    |> to_string

    {:ok, res}
  end
  def convert_type(data, type), do: {:type_conversion_error, type}

  # ---------------------------------------------

  # ideally, I could have a macro that just mapped :int16 -> unsigned-integer-size INSIDE the binary match
  # def map_data(value, :int16), do: <<resp::unsigned-integer-size(16)>> = value
end

defmodule ExModbus.Fronius do
  alias ExModbus.Client
  # "Start Offset" "End Offset" Size  RW  "Function codes"  Name  Description Type  Units Scale Factor  "Range of values"
  # 1 2 2 R 0x03  SID Well-known value. Uniquely identifies this as a SunSpec Modbus Map  uint32      0x53756e53 ('SunS')
  # 3 3 1 R 0x03  ID  Well-known value. Uniquely identifies this as a SunSpec Common Model block  uint16      1
  # 4 4 1 R 0x03  L Length of Common Model block  uint16  Registers   65
  # 5 20  16  R 0x03  Mn  Manufacturer  String32      Fronius
  # 21  36  16  R 0x03  Md  Device model  String32      z. B. IG+150V [3p]
  # 37  44  8 R 0x03  Opt Options String16      Firmware version of Datamanager
  # 45  52  8 R 0x03  Vr  SW version of inverter  String16
  # 53  68  16  R 0x03  SN  Serialnumber of the inverter  String32
  # 69  69  1 R 0x03  DA  Modbus Device Address uint16
  def sid(pid, slave_id) do
    case Client.read_data(pid, slave_id, 40_004, 16) do
      {:ok, %{data: {:read_holding_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} ->
        with {:ok, value} = data |> ExModbus.Types.convert_type("String32")
        do
          {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
        else
          {:type_conversion_error, type} ->
            require IEx; IEx.pry
            {:type_conversion_error, type}
        end
      other ->
        require IEx; IEx.pry
        IO.puts inspect other
    end
  end

  def ac(pid, slave_id) do
    case Client.read_data(pid, slave_id, 40_072, 2) do
      {:ok, %{data: {:read_holding_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} ->
        with {:ok, value} = data |> ExModbus.Types.convert_type("float32")
        do
          {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
        else
          {:type_conversion_error, type} ->
            require IEx; IEx.pry
            {:type_conversion_error, type}
        end
      other ->
        require IEx; IEx.pry
        IO.puts inspect other
    end
  end

  def power_factor(pid, slave_id) do
    case Client.read_data(pid, slave_id, 40237 + 11 - 1, 1) do
      {:ok, %{data: {:read_holding_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} ->
        with {:ok, value} = data |> ExModbus.Types.convert_type("int16")
        do
          {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
        else
          {:type_conversion_error, type} ->
            require IEx; IEx.pry
            {:type_conversion_error, type}
        end
      other ->
        require IEx; IEx.pry
        IO.puts inspect other
    end
  end

  # power factor needs to be an integer that will be scaled based on the ssf value (+25)
  # so when I do this for real, I'll want to get the sunssf factor, and
  def set_power_factor(pid, slave_id, power_factor) do
    pf = <<power_factor::signed-integer-size(16)>>
    case Client.write_multiple_registers(pid, slave_id, 40237 + 11 - 1, pf) do
      {:ok, %{data: {:write_multiple_registers, data}, transaction_id: transaction_id, unit_id: unit_id}} ->
        {:ok, %{data: data, transaction_id: transaction_id, slave_id: unit_id}}
        # with {:ok, value} = data |> ExModbus.Types.convert_type("int16")
        # do
        #   {:ok, %{data: value, transaction_id: transaction_id, slave_id: unit_id}}
        # else
        #   {:type_conversion_error, type} ->
        #     require IEx; IEx.pry
        #     {:type_conversion_error, type}
        # end
      other ->
        require IEx; IEx.pry
        IO.puts inspect other
    end
  end
end
