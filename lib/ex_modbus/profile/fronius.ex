defmodule ExModbus.Profiles.Fronius do
  @moduledoc """
  Fronius client in Floating Point mode
  """
  use ExModbus
  # C001, Common
  field :manufacturer,   :string32, 40005, 16, :r, "(Mn Units:  SF: ) Manufacturer - Range: Fronius"
  field :model,          :string32, 40021, 16, :r, "(Md Units:  SF: ) Device model - Range: z. B. IG+150V [3p]"
  field :options,        :string16, 40037,  8, :r, "(Opt Units:  SF: ) Options - Range: Firmware version of Datamanager"
  field :version,        :string16, 40045,  8, :r, "(Vr Units:  SF: ) SW version of inverter - Range:"
  field :serial,         :string32, 40053, 16, :r, "(SN Units:  SF: ) Serialnumber of the inverter - Range:"
  field :device_address, :uint16,   40069,  1, :r, "(DA Units:  SF: ) Modbus Device Address - Range: 1-247"

  # Inverter Model - Float
  field :ac,                :float32, 40072, 2, :r,  "(A) AC total current value"
  field :aph_a,             :float32, 40074, 2, :r,  "(A) AC phase A current val- ue"
  field :aph_b,             :float32, 40076, 2, :r,  "(A) AC phase B current val- ue"
  field :aph_c,             :float32, 40078, 2, :r,  "(A) AC phase C current val- ue"
  field :ppv_ph_ab,         :float32, 40080, 2, :r,  "(V) AC voltage phase AB value"
  field :ppv_ph_bc,         :float32, 40082, 2, :r,  "(V) AC voltage phase BC value"
  field :ppv_ph_ca,         :float32, 40084, 2, :r,  "(V) AC voltage phase CA value"
  field :ph_vph_a,          :float32, 40086, 2, :r,  "(V) AC voltage phase-A-to- neutral value"
  field :ph_vph_b,          :float32, 40088, 2, :r,  "(V) AC voltage phase-B-to- neutral value"
  field :ph_vph_c,          :float32, 40090, 2, :r,  "(V) AC voltage phase-C-to- neutral value"
  field :w,                 :float32, 40092, 2, :r,  "(W) AC power value"
  field :hz,                :float32, 40094, 2, :r,  "(Hz) AC frequency value"
  field :va,                :float32, 40096, 2, :r,  "(VA) Apparent power"
  field :v_ar,              :float32, 40098, 2, :r,  "(VAr) Reactive power"
  field :pf,                :float32, 40100, 2, :r,  "(%) Power factor"
  field :wh,                :float32, 40102, 2, :r,  "(Wh) AC lifetime energy pro- duction"
  field :dca,               :float32, 40104, 2, :r,  "(A) DC current value - DC current only if one MPPT available; with multiple MPPT 'not implemented'"
  field :dcv,               :float32, 40106, 2, :r,  "V DC voltage value DC voltage only if one MPPT avail- able; with multiple MPPT “not implement- ed”"
  field :dcw,               :float32, 40108, 2, :r,  "W DC power value Total DC power of all available MPPT"
  field :temp_cabinet,      :float32, 40110, 2, :r,  "°C Cabinet temperature"
  field :temp_heat_sink,    :float32, 40112, 2, :r,  "°C Coolant or heat sink temperature"
  field :temp_transformer,  :float32, 40114, 2, :r,  "°C Transformer tempera- ture"
  field :temp_other,        :float32, 40116, 2, :r,  "°C Other temperature"
  # SunSpec State Codes
  # Name                  Value  Description
  # I_STATUS_OFF            1    Inverter is off
  # I_STATUS_SLEEPING       2    Auto shutdown
  # I_STATUS_STARTING       3    Inverter starting
  # I_STATUS_MPPT           4    Inverter working normally
  # I_STATUS_THROTTLED      5    Power reduction active
  # I_STATUS_SHUTTING_DOWN  6    Inverter shutting down
  # I_STATUS_FAULT          7    One or more faults present, see St*or Evt* register
  # I_STATUS_STANDBY        8    Standby
  field :st,                :enum16,  40118, 1, :r, "Enumerated Operating state (see SunSpec State Codes)",
        ~w(nil off sleeping starting mppt throttled shutting_down fault standby)a


  # Fronius State Codes
  # Name                  Value Description
  # I_STATUS_OFF            1   Inverter is off
  # I_STATUS_SLEEPING       2   Auto shutdown
  # I_STATUS_STARTING       3   Inverter starting
  # I_STATUS_MPPT           4   Inverter working normally
  # I_STATUS_THROTTLED      5   Power reduction active
  # I_STATUS_SHUTTING_DOWN  6   Inverter shutting down
  # I_STATUS_FAULT          7   One or more faults present, see St*or Evt* register
  # I_STATUS_STANDBY        8   Standby
  # I_STATUS_NO_BUSINIT     9   No SolarNet communication
  # I_STATUS_NO_COMM_INV    10  No communication with inverter possible
  # I_STATUS_SN_OVERCURRENT 11  Overcurrent detected on SolarNet plug
  # I_STATUS_BOOTLOAD       12  Inverter is currently being updated
  # I_STATUS_AFCI           13  AFCI event arcdetection
  field :st_vnd, :enum16, 40119, 1, :r, "Enumerated Vendor defined operating state (See Fronius State Codes))",
    ~w(nil off sleeping starting mppt throttled shutting_down fault standby no_businit no_comm_inv sn_overcurrent bootload afci)a
  field :evt1,              :uint32,  40120, 2, :r, "Bit field Event flags (bits 0–31) (custom - can be downloaded from Fronius website)"
  field :evt2,              :uint32,  40122, 2, :r, "Bit field Event flags (bits 32–63) (custom - can be downloaded from Fronius website)"
  field :evt_vnd1,          :uint32,  40124, 2, :r, "Bit field Vendor defined event flags (bits 0–31) (custom - can be downloaded from Fronius website)"
  field :evt_vnd2,          :uint32,  40126, 2, :r, "Bit field Vendor defined event flags (bits 32–63) (custom - can be downloaded from Fronius website)"
  field :evt_vnd3,          :uint32,  40128, 2, :r, "Bit field Vendor defined event flags (bits 64–95) (custom - can be downloaded from Fronius website)"
  field :evt_vnd4,          :uint32,  40130, 2, :r, "Bit field Vendor defined event flags (bits 96–127) (custom - can be downloaded from Fronius website)"

  # Nameplate Model (IC120)
  field :id,              :uint16, 40132, 1, :r, "A well-known value 120. Uniquely identifies this as a SunSpec Nameplate Model 120"
  field :l,               :uint16, 40133, 1, :r, "Registers Length of Nameplate Model 26"
  field :der_type,        :uint16, 40134, 1, :r, "Type of DER device. Default value is 4 to indicate PV device"
  field :w_rtg,           :uint16, 40135, 1, :r, "W WRtg_SF Continuous power output capability of the inverter"
  field :w_rtg_sf,        :sunssf, 40136, 1, :r, "Scale factor 1"
  field :vartg,           :uint16, 40137, 1, :r, "VA VARtg_SF Continuous volt-ampere capability of the inverter"
  field :vartg_sf,        :sunssf, 40138, 1, :r, "Scale factor 1"
  field :var_rtg_q1,      :int16,  40139, 1, :r, "var VArRtg_SF Continuous VAR capability of the inverter in quadrant 1"
  field :var_rtg_q2,      :int16,  40140, 1, :r, "var VArRtg_SF Continuous VAR capability of the inverter in quadrant 2 Not supported"
  field :var_rtg_q3,      :int16,  40141, 1, :r, "var VArRtg_SF Continuous VAR capability of the inverter in quadrant 3 Not supported 96"
  field :VArRtgQ4,        :int16,  40142, 1, :r, "var VArRt- g_SF Continuous VAR capa- bility of the inverter in quadrant 4"
  field :VArRtg_SF,       :sunssf, 40143, 1, :r, "Scale factor 1"
  field :ARtg,            :uint16, 40144, 1, :r, "A ARtg_SF Maximum RMS AC current level capability of the inverter"
  field :ARtg_SF,         :sunssf, 40145, 1, :r, "Scale factor -2"
  field :PFRtgQ1,         :int16,  40146, 1, :r, "cos() PFRtg_SF Minimum power factor capability of the inverter in quadrant 1"
  field :PFRtgQ2,         :int16,  40147, 1, :r, "cos() PFRtg_SF Minimum power factor capability of the inverter in quadrant 2 Not supported"
  field :PFRtgQ3,         :int16,  40148, 1, :r, "cos() PFRtg_SF Minimum power factor capability of the inverter in quadrant 3 Not supported"
  field :PFRtgQ4,         :int16,  40149, 1, :r, "cos() PFRtg_SF Minimum power factor capability of the inverter in quadrant 4"
  field :PFRtg_SF,        :sunssf, 40150, 1, :r, "Scale factor -3"
  field :WHRtg,           :uint16, 40151, 1, :r, "Wh WHRtg_SF Nominal energy rating of storage device Not supported"
  field :WHRtg_SF,        :sunssf, 40152, 1, :r, "Scale factor Not supported"
  field :AhrRtg,          :uint16, 40153, 1, :r, "AH AhrRtg_SF The usable capacity of the battery. Maximum charge minus minimum charge from a technology capability perspective (amp-hour capacity rating) Not supported"
  field :AhrRtg_SF,       :sunssf, 40154, 1, :r, "Scale factor for amphour rating Not supported"
  field :MaxChaRte,       :uint16, 40155, 1, :r, "W MaxChaRte _SF Maximum rate of energy transfer into the storage device Not supported"
  field :MaxChaRte_SF,    :sunssf, 40156, 1, :r, "Scale factor Not supported"
  field :MaxDisChaRte,    :uint16, 40157, 1, :r, "W MaxDisChaRte _SF Maximum rate of energy transfer out of the storage device Not supported"
  field :MaxDisChaRte_SF, :sunssf, 40158, 1, :r, "Scale factor Not supported"

  # Basic Settings (IC121)
  field :pf_min_q1,      :int16,   40159+14, 1, :r, "cos() PFMin_ SF Setpoint for minimum power factor value in quadrant 1. Default to PFRtgQ1"
  field :pf_min_q2,      :int16,   40159+15, 1, :r, "cos() PFMin_ SF Setpoint for minimum power factor value in quadrant 2. Default to PFRtgQ2 Not supported"
  field :pf_min_q3,      :int16,   40159+16, 1, :r, "cos() PFMin_ SF Setpoint for minimum power factor value in quadrant 3. Default to PFRtgQ3 Not supported"
  field :pf_min_q4,      :int16,   40159+17, 1, :r, "cos() PFMin_ SF Setpoint for minimum power factor value in quadrant 4. Default to PFRtgQ4"
  field :var_act,        :enum16,  40159+18, 1, :r, "VAR action on change between charging and discharging. Not supported", ~w(nil switch maintain)a
  field :clc_tot_va,     :enum16,  40159+19, 1, :r, "Calculation method for total apparent power. Not supported", ~w(nil vector arithmetic)a
  field :max_rmp_rte,    :uint16,  40159+20, 1, :r, "% WGra MaxRmpRte_S F Setpoint for maximum ramp rate as percentage of nominal maximum ramp rate. This setting will limit the rate that watts delivery to the grid can increase or decrease in response to intermittent PV generation Not supported"
  field :ecp_nom_hz,     :uint16,  40159+21, 1, :r, "Hz ECPNomHz_SF Setpoint for nominal frequency at the ECP Not supported"
  field :conn_ph,        :enum16,  40159+22, 1, :r, "Identity of connected phase for single phase inverters. Not supported", ~w(nil A B C)a
  field :w_max_sf,       :sunssf,  40159+23, 1, :r, "Scale factor for maximum power output 1"
  field :vref_sf,        :sunssf,  40159+24, 1, :r, "Scale factor for voltage at the PCC 0"
  field :vref_ofs_sf,    :sunssf,  40159+25, 1, :r, "Scale factor for offset voltage 0"
  field :v_min_max_sf,   :sunssf,  40159+26, 1, :r, "Scale factor for min/max voltages 0"
  field :va_max_sf,      :sunssf,  40159+27, 1, :r, "Scale factor for voltage at the PCC 1"
  field :var_max_sf,     :sunssf,  40159+28, 1, :r, "Scale factor for reactive power 1"
  field :wgra_sf,        :sunssf,  40159+29, 1, :r, "Scale factor for default ramp rate Not supported"
  field :pf_min_sf,      :sunssf,  40159+30, 1, :r, "Scale factor for minimum power factor -3"
  field :max_rmp_rte_sf, :sunssf,  40159+31, 1, :r, "Scale factor for maximum ramp percentage Not supported"
  field :ecp_nom_hz_sf,  :sunssf,  40159+32, 1, :r, "Scale factor for nominal frequency Not supported"

  # Extended Measurements & Status Model (IC122)
  field :pv_conn,        :bitfield16, 40237+3,  1, :r, "PV inverter present/ available status. Enumerated value Connected Available Operating Test Bit 0 = 1 Bit 1 = 1 Bit 2 = 1 Bit 3 = 1"
  field :stor_conn,      :bitfield16, 40237+4,  1, :r, "Storage inverter present/available status. Enumerated value Not supported"
  field :ecp_conn,       :bitfield16, 40237+5,  1, :r, "ECP connection status Connected Bit 0 = 1"
  field :act_wh,         :uint64,     40237+6,  4, :r, "Wh AC lifetime active (real) energy output (acc64)"
  field :act_vah,        :uint64,     40237+10, 4, :r, "VAh AC lifetime apparent energy output Not supported (acc64)"
  field :act_varh_q1,    :uint64,     40237+14, 4, :r, "varh AC lifetime reactive energy output in quadrant 1 Not supported (acc64)"
  field :act_varh_q2,    :uint64,     40237+18, 4, :r, "varh AC lifetime reactive energy output in quadrant 2 Not supported (acc64)"
  field :act_varh_q3,    :uint64,     40237+22, 4, :r, "varh AC lifetime negative energy output in quadrant 3 Not supported (acc64)"
  field :act_varh_q4,    :uint64,     40237+26, 4, :r, "varh AC lifetime reactive energy output in quadrant 4 Not supported (acc64)"
  field :var_aval,       :int16,      40237+30, 1, :r, "var VArAval_SF Number of VARs available without impacting watts output Not supported"
  field :var_aval_sf,    :sunssf,     40237+31, 1, :r, "Scale factor for available VARs Not supported"
  field :waval,          :uint16,     40237+32, 1, :r, "W WAval_ SF Number of Watts available Not supported"
  field :waval_sf,       :sunssf,     40237+33, 1, :r, "Scale factor for available Watts Not supported"
  field :st_set_lim_msk, :bitfield32, 40237+34, 2, :r, "Bit mask indicating setpoint limit(s) reached. Bits are persistent and must be cleared by the controller Not supported"
  field :st_act_ctl,     :bitfield32, 40237+36, 2, :r, "Bit mask indicating which inverter controls are currently active FixedW FixedVAR FixedPF Bit 0 = 1 Bit 1 = 1 Bit 2 = 1"
  field :tm_src,         :string,     40237+38, 4, :r, "Source of time synchronization RTC"
  field :tms,            :uint32,     40237+42, 2, :r, "Secs Seconds since 01-012000 00:00 UTC"
  field :rt_st,          :bitfield16, 40237+44, 1, :r, "Bit mask indicating which voltage ride through modes are currently active 0"
  field :riso,           :uint16,     40237+45, 1, :r, "Ohm Riso_S F Isolation resistance Not supported"
  field :riso_sf,        :int16,      40237+46, 1, :r, "Scale factor for isolation resistance Not supported"

  # Immediate Control Model (IC123)
  field :conn_win_tms,           :uint16,   40240, 1, :rw, "Time window for connect/disconnect (0-300 seconds)"
  field :conn_rvrt_tims,         :uint16,   40241, 1, :rw, "Timeout window for connect/disconnect (0-300 seconds)"
  field :conn,                   :enum16,   40242, 1, :rw, "Enumerated value. Connection control", ~w(disconnected connected)a
  field :wmax_lim_pct,           :uint16,   40243, 1, :rw, "Set power output to specified level (%WMax)"
  field :wmax_lim_pct_win_tims,  :uint16,   40244, 1, :rw, "Time window for power limit change (0-300 seconds)"
  field :wmax_lim_pct_rvrt_tims, :uint16,   40245, 1, :rw, "Timeout period for power limit change (0-28,800 seconds)"
  field :wmax_lim_pct_rmp_tims,  :not_impl, 40246, 1, :r,  "Ramp time for moving from current setpoint to new setpoint (Not Supported)"
  field :wmax_lim_ena,           :enum16,   40247, 1, :rw, "Enumerated value. Throttle enable/disable control", ~w(disabled enabled)a
  field :out_pf_set_win_tms,     :uint16,   40249, 1, :rw, "Secs Time window for power factor change 0–300"
  field :out_pf_set_rvrt_tms,    :uint16,   40250, 1, :rw, "Secs Timeout period for power factor 0–28800"
  field :out_pf_set_rmp_tms,     :uint16,   40251, 1, :r,  "Secs Ramp time for moving from current setpoint to new setpoint Not supported"
  field :out_pf_set_ena,         :enum16,   40252, 1, :rw, "Enumerated value. Fixed power factor enable/disable control", ~w(disabled enabled)a
  field :var_wmax_pct,           :int16,    40253, 1, :rw, "% WMax VArWMaxPct_SF Reactive power in percent of WMax Not supported"
  field :var_max_pct,            :int16,    40254, 1, :rw, "% VAr- Max VArPct _SF Reactive power in per- cent of VArMax"
  field :var_aval_pct,           :int16,    40255, 1, :rw, "% VAr- Aval VArPct _SF Reactive power in per- cent of VArAval Not supported"
  field :var_pct_win_tms,        :uint16,   40256, 1, :rw, "Secs Time window for VAR limit change 0–300"
  field :var_pct_rvrt_tms,       :uint16,   40257, 1, :r,  "Secs Timeout period for VAR limit 0–28800"
  field :var_pct_rmp_t,          :uint16,   40258, 1, :rw, "ms  Secs Ramp time for moving from current setpoint to new setpoint Not supported"
  field :var_pct_mod,            :enum16,   40259, 1, :r,  "Enumerated value. VAR limit mode 2: VAR limit as a % of VArMax",
    ~w(nil nil var_limit_as_pct_of_varmax)

  field :var_pct_ena,            :enum16,   40260, 1, :rw, "Enumerated value. Fixed VAR enable/disable control Disabled Enabled 0 1", ~w(disabled enabled)a
  field :wmax_lim_pct_sf,        :sunssf,   40261, 1, :r, "Scale factor for power output percent -2"
  field :out_pf_set_sf,          :sunssf,   40262, 1, :r, "Scale factor for power factor -3"
  field :var_pct_sf,             :sunssf,   40263, 1, :r, "Scale factor for reactive power 0"
end
