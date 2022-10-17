module DropletMeasurementTechnologiesCCN

using LibSerialPort
using Dates
using DataStructures
using Chain

const dataBuffer = CircularBuffer{UInt8}(5000)

function config(portname::String)
    port = LibSerialPort.sp_get_port_by_name(portname)

    LibSerialPort.sp_open(port, SP_MODE_READ_WRITE)
    config = LibSerialPort.sp_get_config(port)
    LibSerialPort.sp_set_config_baudrate(config, 9600)
    LibSerialPort.sp_set_config_parity(config, SP_PARITY_NONE)
    LibSerialPort.sp_set_config_bits(config, 8)
    LibSerialPort.sp_set_config_stopbits(config, 1)

    return port
end

function stream(port::Ptr{LibSerialPort.Lib.SPPort}, file::String)
    Godot = @task _ -> false

    run(`touch $(file)`)

    function read(port, file)
        try
            nbytes_read, bytes = LibSerialPort.sp_nonblocking_read(port, 512)
            str = String(bytes[1:nbytes_read])
            filter(x -> x .== "\n", str)
            open(file, "a") do io
                write(io, str)
            end
            append!(dataBuffer, bytes[1:nbytes_read])
        catch
            println("I fail")
        end
    end

    while(true)
        read(port, file)
        sleep(1)
    end

    wait(Godot)
end

function is_valid(x) 
    try
        @chain x String (_[1] == 'H') & (_[end] == '\r')
    catch
        false
    end
end

function get_current_record()
    @chain deepcopy(DropletMeasurementTechnologiesCCN.dataBuffer[1:end]) begin
        String(_) 
        split(_, "\n") 
        filter(is_valid, _)
        _[end]
    end
end

end
