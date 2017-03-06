# defmodule ExModbus.Profiles.FroniusInt do
#   use ExModbus

#   # C001, Common
#   field :manufacturer,   :string32, 40005, 16, :r, "(Mn Units: SF:) Manufacturer Range: Fronius"
#   field :model,          :string32, 40021, 16, :r, "(Md Units: SF:) Device model Range: z. B. IG+150V [3p]"
#   field :options,        :string16, 40037,  8, :r, "(Opt Units: SF:) Options Range: Firmware version of Datamanager"
#   field :version,        :string16, 40045,  8, :r, "(Vr Units: SF:) SW version of inverter Range:"
#   field :serial,         :string32, 40053, 16, :r, "(SN Units: SF:) Serialnumber of the inverter Range:"
#   field :device_address, :uint16,   40069,  1, :r, "(DA Units: SF:) Modbus Device Address Range: 1-247"

#   # Inverter Model INT+SF
#   field :ac,                :uint16,  40072, 1, :r,  "(A) AC total current value"
#   field :aph_a,             :uint16,  40073, 1, :r,  "(A) AC phase A current value"
#   field :aph_b,             :uint16,  40074, 1, :r,  "(A) AC phase B current value"
#   field :aph_c,             :uint16,  40075, 1, :r,  "(A) AC phase C current value"
#   field :a_sf,              :sunssf,  40076, 2, :r,  "AC current scale factor"

#   field :ppv_ph_ab,         :uint16,  40077, 1, :r,  "(V) AC voltage phase AB value"
#   field :ppv_ph_bc,         :uint16,  40078, 1, :r,  "(V) AC voltage phase BC value"
#   field :ppv_ph_ca,         :uint16,  40079, 1, :r,  "(V) AC voltage phase CA value"
#   field :ph_vph_a,          :uint16,  40080, 1, :r,  "(V) AC voltage phase-A-toneutral value"
#   field :ph_vph_b,          :uint16,  40081, 1, :r,  "(V) AC voltage phase-B-toneutral value"
#   field :ph_vph_c,          :uint16,  40082, 1, :r,  "(V) AC voltage phase-C-toneutral value"
#   field :v_sf,              :sunssf,  40083, 1, :r,  "AC voltage scale factor"

#   field :w,                 :uint16,  40084, 1, :r,  "(W) AC power value"
#   field :w_sf,              :uint16,  40085, 1, :r,  "AC power scale factor"

#   field :hz,                :uint16,  40086, 1, :r,  "(Hz) AC frequency value"
#   field :hz_sf,             :uint16,  40087, 1, :r,  "Scale factor"

#   field :va,                :uint16,  40088, 1, :r,  "(VA) Apparent power"
#   field :va_sf,             :sunssf,  40089, 1, :r,  "Scale Factor"

#   field :var,               :int16,   40090, 1, :r,  "(VAr) Reactive power"
#   field :var_sf,            :sunssf,  40091, 1, :r,  "Scale Factor"

#   field :pf,                :int16,   40092, 1, :r,  "(%) Power factor"
#   field :pf_sf,             :sunssf,  40093, 1, :r,  "Scale Factor"

#   field :wh,                :uint32,  40094, 2, :r,  "(Wh) AC lifetime energy production"
#   field :wh_sf,             :sunssf,  40096, 1, :r,  "Scale Factor"

#   field :dca,               :uint16,  40097, 1, :r,  "(A) DC current value DC current only if one MPPT available; with multiple MPPT 'not implemented'"
#   field :dca_sf,            :sunssf,  40098, 1, :r,  "Scale Factor"

#   field :dcv,               :uint16,  40099, 1, :r,  "V DC voltage value DC voltage only if one MPPT available; with multiple MPPT “not implemented”"
#   field :dcv_sf,            :sunssf,  40100, 1, :r,  "Scale Factor"

#   field :dcw,               :int16,   40101, 1, :r,  "W DC power value Total DC power of all available MPPT"
#   field :dcw_sf,            :sunssf,   40102, 1, :r,  "Scale Factor"

#   field :temp_heat_sink,    :int16,   40104, 1, :r,  "°C Tmp_SF Coolant or heat sink temperature Not supported"
#   field :temp_transformer,  :int16,   40105, 1, :r,  "°C Transformer temperature"
#   field :temp_other,        :int16,   40106, 1, :r,  "°C Other temperature"
#   field :temp_sf,           :sunssf,  40107, 1, :r,  "Scale Factor"
#   # SunSpec State Codes
#   # Name                  Value  Description
#   # I_STATUS_OFF            1    Inverter is off
#   # I_STATUS_SLEEPING       2    Auto shutdown
#   # I_STATUS_STARTING       3    Inverter starting
#   # I_STATUS_MPPT           4    Inverter working normally
#   # I_STATUS_THROTTLED      5    Power reduction active
#   # I_STATUS_SHUTTING_DOWN  6    Inverter shutting down
#   # I_STATUS_FAULT          7    One or more faults present, see St*or Evt* register
#   # I_STATUS_STANDBY        8    Standby
#   field :st,                :enum16,  40108, 1, :r, "Enumerated Operating state (see SunSpec State Codes)",
#         %{1 => "off", 2 => "sleeping"}


#   # Fronius State Codes
#   # Name                  Value Description
#   # I_STATUS_OFF            1   Inverter is off
#   # I_STATUS_SLEEPING       2   Auto shutdown
#   # I_STATUS_STARTING       3   Inverter starting
#   # I_STATUS_MPPT           4   Inverter working normally
#   # I_STATUS_THROTTLED      5   Power reduction active
#   # I_STATUS_SHUTTING_DOWN  6   Inverter shutting down
#   # I_STATUS_FAULT          7   One or more faults present, see St*or Evt* register
#   # I_STATUS_STANDBY        8   Standby
#   # I_STATUS_NO_BUSINIT     9   No SolarNet communication
#   # I_STATUS_NO_COMM_INV    10  No communication with inverter possible
#   # I_STATUS_SN_OVERCURRENT 11  Overcurrent detected on SolarNet plug
#   # I_STATUS_BOOTLOAD       12  Inverter is currently being updated
#   # I_STATUS_AFCI           13  AFCI event arcdetection
#   # field :st_vnd, :enum16, 40109, 1, :r, "Enumerated Vendor defined operating state (See Fronius State Codes))",
#   #   ~w(nil off sleeping starting mppt throttled shutting_down fault standby no_businit no_comm_inv sn_overcurrent bootload afci)a
#   field :evt1,              :uint32,  40110, 2, :r, "Bit field Event flags (bits 0–31) (custom can be downloaded from Fronius website)"
#   field :evt2,              :uint32,  40112, 2, :r, "Bit field Event flags (bits 32–63) (custom can be downloaded from Fronius website)"
#   field :evt_vnd1,          :uint32,  40114, 2, :r, "Bit field Vendor defined event flags (bits 0–31) (custom can be downloaded from Fronius website)"
#   field :evt_vnd2,          :uint32,  40116, 2, :r, "Bit field Vendor defined event flags (bits 32–63) (custom can be downloaded from Fronius website)"
#   field :evt_vnd3,          :uint32,  40118, 2, :r, "Bit field Vendor defined event flags (bits 64–95) (custom can be downloaded from Fronius website)"
#   field :evt_vnd4,          :uint32,  40120, 2, :r, "Bit field Vendor defined event flags (bits 96–127) (custom can be downloaded from Fronius website)"

#   # Nameplace Model (IC120) INT+SF
#   @nameplace_start 40121
#   field :der_type,        :uint16, @nameplace_start + 3, 1, :r, "Type of DER device. Default value is 4 to indicate PV device"
#   field :w_rtg,           :uint16, @nameplace_start + 4, 1, :r, "W WRtg_SF Continuous power output capability of the inverter"
#   field :w_rtg_sf,        :sunssf, @nameplace_start + 5, 1, :r, "Scale factor 1"
#   field :vartg,           :uint16, @nameplace_start + 6, 1, :r, "VA VARtg_SF Continuous volt-ampere capability of the inverter"
#   field :vartg_sf,        :sunssf, @nameplace_start + 7, 1, :r, "Scale factor 1"
#   field :var_rtg_q1,      :int16,  @nameplace_start + 8, 1, :r, "var VArRtg_SF Continuous VAR capability of the inverter in quadrant 1"
#   field :var_rtg_q2,      :int16,  @nameplace_start + 9, 1, :r, "var VArRtg_SF Continuous VAR capability of the inverter in quadrant 2 Not supported"
#   field :var_rtg_q3,      :int16,  @nameplace_start + 10, 1, :r, "var VArRtg_SF Continuous VAR capability of the inverter in quadrant 3 Not supported 96"
#   field :VArRtgQ4,        :int16,  @nameplace_start + 11, 1, :r, "var VArRt- g_SF Continuous VAR capa- bility of the inverter in quadrant 4"
#   field :VArRtg_SF,       :sunssf, @nameplace_start + 12, 1, :r, "Scale factor 1"
#   field :ARtg,            :uint16, @nameplace_start + 13, 1, :r, "A ARtg_SF Maximum RMS AC current level capability of the inverter"
#   field :ARtg_SF,         :sunssf, @nameplace_start + 14, 1, :r, "Scale factor -2"
#   field :PFRtgQ1,         :int16,  @nameplace_start + 15, 1, :r, "cos() PFRtg_SF Minimum power factor capability of the inverter in quadrant 1"
#   field :PFRtgQ2,         :int16,  @nameplace_start + 16, 1, :r, "cos() PFRtg_SF Minimum power factor capability of the inverter in quadrant 2 Not supported"
#   field :PFRtgQ3,         :int16,  @nameplace_start + 17, 1, :r, "cos() PFRtg_SF Minimum power factor capability of the inverter in quadrant 3 Not supported"
#   field :PFRtgQ4,         :int16,  @nameplace_start + 18, 1, :r, "cos() PFRtg_SF Minimum power factor capability of the inverter in quadrant 4"
#   field :PFRtg_SF,        :sunssf, @nameplace_start + 19, 1, :r, "Scale factor -3"
#   field :WHRtg,           :uint16, @nameplace_start + 20, 1, :r, "Wh WHRtg_SF Nominal energy rating of storage device Not supported"
#   field :WHRtg_SF,        :sunssf, @nameplace_start + 21, 1, :r, "Scale factor Not supported"
#   field :AhrRtg,          :uint16, @nameplace_start + 22, 1, :r, "AH AhrRtg_SF The usable capacity of the battery. Maximum charge minus minimum charge from a technology capability perspective (amp-hour capacity rating) Not supported"
#   field :AhrRtg_SF,       :sunssf, @nameplace_start + 23, 1, :r, "Scale factor for amphour rating Not supported"
#   field :MaxChaRte,       :uint16, @nameplace_start + 24, 1, :r, "W MaxChaRte _SF Maximum rate of energy transfer into the storage device Not supported"
#   field :MaxChaRte_SF,    :sunssf, @nameplace_start + 25, 1, :r, "Scale factor Not supported"
#   field :MaxDisChaRte,    :uint16, @nameplace_start + 26, 1, :r, "W MaxDisChaRte _SF Maximum rate of energy transfer out of the storage device Not supported"
#   field :MaxDisChaRte_SF, :sunssf, @nameplace_start + 27, 1, :r, "Scale factor Not supported"

#   # Basic Settings (IC121)
#   @basic_start 40149
#   field :pf_min_q1,      :int16,   @basic_start + 14, 1, :r, "cos() PFMin_ SF Setpoint for minimum power factor value in quadrant 1. Default to PFRtgQ1"
#   field :pf_min_q2,      :int16,   @basic_start + 15, 1, :r, "cos() PFMin_ SF Setpoint for minimum power factor value in quadrant 2. Default to PFRtgQ2 Not supported"
#   field :pf_min_q3,      :int16,   @basic_start + 16, 1, :r, "cos() PFMin_ SF Setpoint for minimum power factor value in quadrant 3. Default to PFRtgQ3 Not supported"
#   field :pf_min_q4,      :int16,   @basic_start + 17, 1, :r, "cos() PFMin_ SF Setpoint for minimum power factor value in quadrant 4. Default to PFRtgQ4"
#   field :var_act,        :enum16,  @basic_start + 18, 1, :r, "VAR action on change between charging and discharging. Not supported" #, ~w(nil switch maintain)a
#   field :clc_tot_va,     :enum16,  @basic_start + 19, 1, :r, "Calculation method for total apparent power. Not supported" #, ~w(nil vector arithmetic)a
#   field :max_rmp_rte,    :uint16,  @basic_start + 20, 1, :r, "% WGra MaxRmpRte_S F Setpoint for maximum ramp rate as percentage of nominal maximum ramp rate. This setting will limit the rate that watts delivery to the grid can increase or decrease in response to intermittent PV generation Not supported"
#   field :ecp_nom_hz,     :uint16,  @basic_start + 21, 1, :r, "Hz ECPNomHz_SF Setpoint for nominal frequency at the ECP Not supported"
#   field :conn_ph,        :enum16,  @basic_start + 22, 1, :r, "Identity of connected phase for single phase inverters. Not supported" #, ~w(nil A B C)a
#   field :w_max_sf,       :sunssf,  @basic_start + 23, 1, :r, "Scale factor for maximum power output 1"
#   field :vref_sf,        :sunssf,  @basic_start + 24, 1, :r, "Scale factor for voltage at the PCC 0"
#   field :vref_ofs_sf,    :sunssf,  @basic_start + 25, 1, :r, "Scale factor for offset voltage 0"
#   field :v_min_max_sf,   :sunssf,  @basic_start + 26, 1, :r, "Scale factor for min/max voltages 0"
#   field :va_max_sf,      :sunssf,  @basic_start + 27, 1, :r, "Scale factor for voltage at the PCC 1"
#   field :var_max_sf,     :sunssf,  @basic_start + 28, 1, :r, "Scale factor for reactive power 1"
#   field :wgra_sf,        :sunssf,  @basic_start + 29, 1, :r, "Scale factor for default ramp rate Not supported"
#   field :pf_min_sf,      :sunssf,  @basic_start + 30, 1, :r, "Scale factor for minimum power factor -3"
#   field :max_rmp_rte_sf, :sunssf,  @basic_start + 31, 1, :r, "Scale factor for maximum ramp percentage Not supported"
#   field :ecp_nom_hz_sf,  :sunssf,  @basic_start + 32, 1, :r, "Scale factor for nominal frequency Not supported"

#   # Extended Measurements & Status Model (IC122)
#   @extended_start 40181
#   field :pv_conn,        :bitfield16, @extended_start + 3,  1, :r, "PV inverter present/ available status. Enumerated value Connected Available Operating Test Bit 0 = 1 Bit 1 = 1 Bit 2 = 1 Bit 3 = 1"
#   field :stor_conn,      :bitfield16, @extended_start + 4,  1, :r, "Storage inverter present/available status. Enumerated value Not supported"
#   field :ecp_conn,       :bitfield16, @extended_start + 5,  1, :r, "ECP connection status Connected Bit 0 = 1"
#   field :act_wh,         :uint64,     @extended_start + 6,  4, :r, "Wh AC lifetime active (real) energy output (acc64)"
#   field :act_vah,        :uint64,     @extended_start + 10, 4, :r, "VAh AC lifetime apparent energy output Not supported (acc64)"
#   field :act_varh_q1,    :uint64,     @extended_start + 14, 4, :r, "varh AC lifetime reactive energy output in quadrant 1 Not supported (acc64)"
#   field :act_varh_q2,    :uint64,     @extended_start + 18, 4, :r, "varh AC lifetime reactive energy output in quadrant 2 Not supported (acc64)"
#   field :act_varh_q3,    :uint64,     @extended_start + 22, 4, :r, "varh AC lifetime negative energy output in quadrant 3 Not supported (acc64)"
#   field :act_varh_q4,    :uint64,     @extended_start + 26, 4, :r, "varh AC lifetime reactive energy output in quadrant 4 Not supported (acc64)"
#   field :var_aval,       :int16,      @extended_start + 30, 1, :r, "var VArAval_SF Number of VARs available without impacting watts output Not supported"
#   field :var_aval_sf,    :sunssf,     @extended_start + 31, 1, :r, "Scale factor for available VARs Not supported"
#   field :waval,          :uint16,     @extended_start + 32, 1, :r, "W WAval_ SF Number of Watts available Not supported"
#   field :waval_sf,       :sunssf,     @extended_start + 33, 1, :r, "Scale factor for available Watts Not supported"
#   field :st_set_lim_msk, :bitfield32, @extended_start + 34, 2, :r, "Bit mask indicating setpoint limit(s) reached. Bits are persistent and must be cleared by the controller Not supported"
#   field :st_act_ctl,     :bitfield32, @extended_start + 36, 2, :r, "Bit mask indicating which inverter controls are currently active FixedW FixedVAR FixedPF Bit 0 = 1 Bit 1 = 1 Bit 2 = 1"
#   field :tm_src,         :string,     @extended_start + 38, 4, :r, "Source of time synchronization RTC"
#   field :tms,            :uint32,     @extended_start + 42, 2, :r, "Secs Seconds since 01-012000 00:00 UTC"
#   field :rt_st,          :bitfield16, @extended_start + 44, 1, :r, "Bit mask indicating which voltage ride through modes are currently active 0"
#   field :riso,           :uint16,     @extended_start + 45, 1, :r, "Ohm Riso_S F Isolation resistance Not supported"
#   field :riso_sf,        :int16,      @extended_start + 46, 1, :r, "Scale factor for isolation resistance Not supported"

#   # Immediate Control Model (IC123)
#   @immediate_start 40227
#   field :conn_win_tms,           :uint16,   @immediate_start + 3,  1, :rw, "Time window for connect/disconnect (0-300 seconds)"
#   field :conn_rvrt_tims,         :uint16,   @immediate_start + 4,  1, :rw, "Timeout window for connect/disconnect (0-300 seconds)"
#   field :conn,                   :enum16,   @immediate_start + 5,  1, :rw, "Enumerated value. Connection control" #, ~w(disconnected connected)a
#   field :wmax_lim_pct,           :uint16,   @immediate_start + 6,  1, :rw, "Set power output to specified level (%WMax)"
#   field :wmax_lim_pct_win_tims,  :uint16,   @immediate_start + 7,  1, :rw, "Time window for power limit change (0-300 seconds)"
#   field :wmax_lim_pct_rvrt_tims, :uint16,   @immediate_start + 8,  1, :rw, "Timeout period for power limit change (0-28,800 seconds)"
#   field :wmax_lim_pct_rmp_tims,  :not_impl, @immediate_start + 9,  1, :r,  "Ramp time for moving from current setpoint to new setpoint (Not Supported)"
#   field :wmax_lim_ena,           :enum16,   @immediate_start + 10, 1, :rw, "Enumerated value. Throttle enable/disable control" #, ~w(disabled enabled)a
#   field :out_pf_set_win_tms,     :uint16,   @immediate_start + 11, 1, :rw, "Secs Time window for power factor change 0–300"
#   field :out_pf_set_rvrt_tms,    :uint16,   @immediate_start + 12, 1, :rw, "Secs Timeout period for power factor 0–28800"
#   field :out_pf_set_rmp_tms,     :uint16,   @immediate_start + 13, 1, :r,  "Secs Ramp time for moving from current setpoint to new setpoint Not supported"
#   field :out_pf_set_ena,         :enum16,   @immediate_start + 14, 1, :rw, "Enumerated value. Fixed power factor enable/disable control", ~w(disabled enabled)a
#   field :var_wmax_pct,           :int16,    @immediate_start + 15, 1, :rw, "% WMax VArWMaxPct_SF Reactive power in percent of WMax Not supported"
#   field :var_max_pct,            :int16,    @immediate_start + 16, 1, :rw, "% VArMax VArPct _SF Reactive power in percent of VArMax"
#   field :var_aval_pct,           :int16,    @immediate_start + 17, 1, :rw, "% VArAval VArPct _SF Reactive power in percent of VArAval Not supported"
#   field :var_pct_win_tms,        :uint16,   @immediate_start + 18, 1, :rw, "Secs Time window for VAR limit change 0–300"
#   field :var_pct_rvrt_tms,       :uint16,   @immediate_start + 19, 1, :r,  "Secs Timeout period for VAR limit 0–28800"
#   field :var_pct_rmp_t,          :uint16,   @immediate_start + 20, 1, :rw, "ms  Secs Ramp time for moving from current setpoint to new setpoint Not supported"
#   field :var_pct_mod,            :enum16,   @immediate_start + 21, 1, :r,  "Enumerated value. VAR limit mode 2: VAR limit as a % of VArMax",
#     ~w(nil nil var_limit_as_pct_of_varmax)

#   field :var_pct_ena,            :enum16,   @immediate_start + 22, 1, :rw, "Enumerated value. Fixed VAR enable/disable control Disabled Enabled 0 1" #, ~w(disabled enabled)a
#   field :wmax_lim_pct_sf,        :sunssf,   @immediate_start + 23, 1, :r, "Scale factor for power output percent -2"
#   field :out_pf_set_sf,          :sunssf,   @immediate_start + 24, 1, :r, "Scale factor for power factor -3"
#   field :var_pct_sf,             :sunssf,   @immediate_start + 25, 1, :r, "Scale factor for reactive power 0"
# end
