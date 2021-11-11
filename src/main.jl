using LibSerialPort
using Dates

function config_port(myport)
    port = LibSerialPort.sp_get_port_by_name(myport)
    LibSerialPort.sp_open(port, SP_MODE_READ_WRITE)
    config = LibSerialPort.sp_get_config(port)
    LibSerialPort.sp_set_config_baudrate(config, 9600)
    LibSerialPort.sp_set_config_parity(config, SP_PARITY_NONE)
    LibSerialPort.sp_set_config_bits(config, 8)
    LibSerialPort.sp_set_config_stopbits(config, 1)
    LibSerialPort.sp_set_config_rts(config, SP_RTS_OFF)
    LibSerialPort.sp_set_config_cts(config, SP_CTS_IGNORE)
    LibSerialPort.sp_set_config_dtr(config, SP_DTR_OFF)
    LibSerialPort.sp_set_config_dsr(config, SP_DSR_IGNORE)

    LibSerialPort.sp_set_config(port, config)
    return port
end

@isdefined(port) || (port = config_port("/dev/ttyUSB0"))

for i = 1:100
nbytes_read, bytes = LibSerialPort.sp_nonblocking_read(port, 1000)
c = String(bytes)
println(now(),",",c)
sleep(1.0)
end


open("foo1.csv", "w") do file
    for i = 1:100
    nbytes_read, bytes = LibSerialPort.sp_nonblocking_read(port, 1000)
    c = String(bytes)
    d = split(c, ",")
    a = d[21]
    b = parse(Float64, a)
    println(b) 
    write(file, string(now()), ",", c)
    sleep(1.0)
    end
end